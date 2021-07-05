## Sampling stuff easily (to speed up queries)

    WHERE mod(farm_fingerprint(to_hex(user_id)), 100) = 0

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


# Timestamps

## Unix timestamp

    SELECT UNIX_DATE(date)

    SELECT UNIX_SECONDS(CURRENT_TIMESTAMP())

    SELECT UNIX_SECONDS(timestamp)

*Converting from unix*

    SELECT DATE(TIMESTAMP_SECONDS(1230219000))

    SELECT DATE(TIMESTAMP_MILLIS(1230219000))

# Window functions

## Finding rows that are near in time to interesting event

Rows after event_id = 1337

    SELECT
        time,
        TIMESTAMP_DIFF(MIN(IF(event_id = 1337, time, NULL)) OVER (ORDER BY time ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING), time, SECONDS) < 10 AS near_interesting
    FROM ...
    ORDER BY near_interesting DESC, time

Rows before event_id = 1337

    SELECT
        time,
        TIMESTAMP_DIFF(time, MAX(IF(event_id = 1337, time, NULL)) OVER (ORDER BY time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), SECONDS) < 10 AS near_interesting
    FROM ...
    ORDER BY near_interesting DESC, time

The usage of ORDER BY could be a WHERE over a subquery, so this is a lazy/fast variant that can be improved

# Partitions

## Finding all

    SELECT _PARTITIONTIME as pt, FORMAT_TIMESTAMP("%Y%m%d", _PARTITIONTIME) as partition_id
    FROM `project.dataset.table`
    GROUP BY _PARTITIONTIME
    ORDER BY _PARTITIONTIME

## Preview partition

(does not work on the web UI)

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
        SELECT 1 as id, 'a' as join_key UNION ALL
        SELECT 2, 'a' UNION ALL
        SELECT 3, 'a'
    )

## Loading data from terminal

    bq load --location=EU --source_format=AVRO --autodetect project:dataset.table 'gs://bucket/path/to/part-*'

# Pro tip

Don't mix `OUTER JOIN` and `WHERE table._TABLE_SUFFIX = ...`. Since `_TABLE_SUFFIX` will be null when the join does not match, split this out into subqueries.