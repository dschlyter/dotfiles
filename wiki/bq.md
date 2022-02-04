## Sampling stuff easily (to speed up queries)

    WHERE mod(farm_fingerprint(user_id), 100) = 0
    WHERE mod(farm_fingerprint(to_hex(user_id)), 100) = 0

Note: If you are doing a LEFT JOIN, make sure to do this filtering in a subquery or WITH statement.

# Arrays

## Arrays select

    SELECT list, list[OFFSET(0)] as first_elem

    SELECT list, list[SAFE_OFFSET(0)] as first_elem

    SELECT list, list[SAFE_OFFSET(ARRAY_LENGTH(list))-1] as last_elem

## Arrays select a field

Note: This is safe even when the array element is null - result will just be null

    SELECT repeated_record[SAFE_OFFSET(1)].field

## Mapping an array

    SELECT ARRAY(SELECT repeated_record.field FROM UNNEST(repeated_record))
    FROM table

## Filtering an array

    SELECT ARRAY(SELECT repeated_record.field FROM UNNEST(repeated_record) WHERE field = 'value')
    FROM table

## Getting offsets

    SELECT * FROM UNNEST([1,2,3]) a WITH OFFSET AS offset_a

# Timestamps

## Unix timestamp

*Converting from unix*

    SELECT TIMESTAMP_MILLIS(1230219000)

    SELECT DATE(TIMESTAMP_SECONDS(1230219000))

    SELECT DATE(TIMESTAMP_MILLIS(1230219000))

*Creating*

    SELECT UNIX_DATE(date)

    SELECT UNIX_MILLIS(CURRENT_TIMESTAMP())

    SELECT UNIX_MILLIS(timestamp)

    SELECT UNIX_MILLIS(TIMESTAMP("2021-12-25 15:30:00+00"))

## Date formatted as YYYYMMDD

Yesterday, where data is usually available.

    FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))

# Select

## Exclude and replace

    SELECT * EXCEPT(a, b, c)

    SELECT * REPLACE(a * 100 AS a, b * 100 AS b)

## Exclude nested

    SELECT (SELECT AS STRUCT nested_struct.* EXCEPT(nested_field)

# Deduplication

For all fields, except repeated which do not support this.

    SELECT DISTINCT * EXCEPT (repeated1, repeated2)
    FROM table

On some fields

    SELECT *
    FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY interaction_id) row_number FROM table)
    WHERE row_number = 1

This can also be written with QUALIFY

    SELECT * FROM table
    WHERE TRUE -- implementation limitation of QUALIFY requires a WHERE
    QUALIFY ROW_NUMBER() OVER(PARTITION BY interaction_id) = 1

Or

    SELECT dedup_field, ANY_VALUE(col1), ANY_VALUE(col2)
    FROM table
    GROUP BY dedup_field

It seems that ANY_VALUE returns what would be in the first row in the result, but this is probably not guaranteed.

# Functions

Commonly useful if you have duplicated boolean logic. Note the semicolon in the end.

    CREATE TEMP FUNCTION pred(x STRING) RETURNS BOOL AS (x = 'expected');

# Bucketing

Quickly calculating quantiles. Cast to a json string to avoid 100 result rows.

    SELECT TO_JSON_STRING(APPROX_QUANTILES(numeric_field, 100)) quantiles

This is also cool

    SELECT APPROX_TOP_COUNT(a, 10)

## Explicit bucketing

A quick bucketing. On the top-level using GROUP BY

    SELECT POWER(10, CEIL(LOG10(x))) less_than, COUNT(1) cnt FROM data GROUP BY less_than

Inside another GROUP BY with a subquery with a one line hack (this might be slow)

    SELECT
        key, COUNT(1) cnt,
        ARRAY(SELECT AS STRUCT POWER(10, CEIL(LOG10(x))) less_than, COUNT(1) cnt FROM data d WHERE d.key = a.key GROUP BY less_than) bucketing
    FROM data a
    GROUP BY key

But the proper way to do this is probably nested GROUP BYs:

    SELECT key, ARRAY_AGG(STRUCT(less_than, cnt)) bucketing FROM (
        SELECT key, POWER(10, CEIL(LOG10(x))) less_than, COUNT(1) cnt
        FROM data
        GROUP BY key, less_than
    )
    GROUP BY key

# Window functions

## Finding rows that are near in time to interesting event

3 prev and 3 next rows

    SELECT
        time,
        IF(field = 'weird', "BAD", "GOOD") AS type,
        ...
    FROM ...
    ORDER BY near_interesting DESC, time
    WHERE TRUE -- needed for QUALIFY
    QUALIFY MAX(type = 'BAD') OVER (PARTITION BY user_id ORDER BY time ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING) = TRUE
    ORDER BY user_id, time

Rows after event_id = 1337 by time

You can use RANGE instead of ROWS to create the window by value.

    SELECT
        time,
        COUNTIF(type = 'bad') OVER (ORDER BY timestamp_seconds RANGE BETWEEN 10 PRECEDING AND CURRENT ROW) >= 1 AS near_interesting
    FROM ...
    ORDER BY near_interesting DESC, time

Rows before event_id = 1337 by time

    SELECT
        time,
        COUNTIF(type = 'bad') OVER (ORDER BY timestamp_seconds RANGE BETWEEN CURRENT ROW AND 10 FOLLOWING) >= 1 AS near_interesting
    FROM ...
    ORDER BY near_interesting DESC, time

## Comparing with next/previous event

    SELECT LAG(v) OVER seq, v, LEAD(v) OVER seq
    FROM table
    WINDOW seq AS (PARTITION BY user_id ORDER BY time)

## Finding the percentage, cumulative sum or cumulative percentage, on a GROUP BY

    COUNT(1) / SUM(COUNT(1)) OVER () percent,

    SUM(COUNT(1)) OVER (ORDER BY COUNT(1) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cum_sum,

    SUM(COUNT(1)) OVER (ORDER BY [SAME AS QUERY] DESC) / SUM(COUNT(1)) OVER () cum_percent

## Finding increase over time

    SELECT COUNT(1) / FIRST_VALUE(COUNT(1)) OVER (PARTITION BY grouping_id ORDER BY day) increase
    FROM ...
    GROUP BY grouping_id, day

## Danger: ORDER BY

Somewhat unintuitively ORDER BY will change the default window frame from all rows to all rows up until current.

This seems to *usually* be what you want, since ordering itself is kind of pointless for aggregations like SUM or AVG, but for some like ARRAY_AGG and LAST_VALUE they break.
And for some reason you are not allowed to use ORDER BY inside the ARRAY_AGG for window functions.

    SELECT
        a, ARRAY_AGG(a) OVER () other_values, -- this has all values
        ARRAY_AGG(a) OVER (ORDER BY a DESC) other_values_sorted, -- !! this returns [[1], [1,2]], using a sliding window
        ARRAY_AGG(a) OVER (ORDER BY a DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) other_values_sorted_explicit -- this has all values
    FROM (SELECT 1 a UNION ALL SELECT 2 a)

## Danger: WHERE

Be careful so you don't remove result from the window using WHERE, since it runs before the window.

# Wildcards

Combining string comparisons and table suffix allows for precise table selection of date-suffixed tables.

    SELECT ...
    FROM `project.dataset.table_2021*`
    WHERE _TABLE_SUFFIX > '0325' AND _TABLE_SUFFIX < '0513'

# Partitions

## Finding all

    SELECT _PARTITIONTIME as pt, FORMAT_TIMESTAMP("%Y%m%d", _PARTITIONTIME) as partition_id
    FROM `project.dataset.table`
    GROUP BY _PARTITIONTIME
    ORDER BY _PARTITIONTIME

Or you can view the metadata table.

    SELECT *
    FROM `project.dataset.INFORMATION_SCHEMA.PARTITIONS`
    -- WHERE table_name = 'table'
    ORDER BY partition_id DESC

## DANGER: WHERE _PARTITIONTIME

## Preview partition

Ddoes not work on the web UI, so you need to use console.

    bq head -n 1 --format prettyjson 'project:dataset.table$20210404'


## Combining GROUP BY and UNNEST

Subquery inside aggregation fn, note you need double parens to make it work.

    SELECT group_key, min((SELECT avg(client_timestamp) FROM UNNEST(array) i WHERE i.key = 'active')) FROM ... GROUP BY group_key

## Comparing result

    SELECT * FROM tmpA
    EXCEPT DISTINCT SELECT * FROM tmpB

This cannot diff arrays but you can use `TO_JSON_STRING` to encode them.

This will not show rows that only exist in tmpB, so for more power you can use.

    WITH a AS (SELECT 1 UNION ALL SELECT 2),
    b AS (SELECT 2 UNION ALL SELECT 3)
    (SELECT * FROM a EXCEPT DISTINCT SELECT * FROM b) UNION ALL (SELECT * FROM b EXCEPT DISTINCT SELECT * FROM a)

Note: This will not handle duplicate rows with different counts

    SELECT *
    FROM UNNEST([1,1,2])
    EXCEPT DISTINCT SELECT * FROM UNNEST([1,2])
    -- returns empty despite there being a diff

## Inline example data for playing around

Pro tip: You only need col names on the first row

    (
        SELECT 1 as id, 'a' as join_key 
        UNION ALL
        SELECT 2, 'a' 
        UNION ALL
        SELECT 3, 'a'
    )

Or you could do this. Slightly more setup but less stuff per new element. 

    UNNEST([
        STRUCT(1 as id, 'a' as join_key),
        (2, 'a'),
        (3, 'a')
    ])

# CLI

## Configure bq cli

`vim $HOME/.bigqueryrc`

    --location=EU

    [query]
    --use_legacy_sql=false

    [mk]
    --use_legacy_sql=false

## Loading data from terminal

    bq load --location=EU --source_format=AVRO --autodetect project:dataset.table 'gs://bucket/path/to/part-*'

## Cancel a job from terminal

    bq --project_id project-id cancel 'job-id'

## Renaming a table

    ALTER TABLE `project.dataset.table`
    RENAME TO `new_table`

## Search past queries with jq

    bq ls --format prettyjson -n 1000 -j <PROJECT> | jq '.[].configuration.query.query' | fzf | jq -r "."

# Pro tip

Don't mix `OUTER JOIN` (or left, right) and `WHERE table._TABLE_SUFFIX = ...`. Since `_TABLE_SUFFIX` will be null when the join does not match, split this out into subqueries.

Same thing goes for _PARTITIONTIME 