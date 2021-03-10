## Sampling stuff easily (to speed up queries)

    WHERE mod(farm_fingerprint(to_hex(user_id)), 100) = 0

## Arrays select

    SELECT list, list[OFFSET(0)] as first_elem

    SELECT list, list[SAFE_OFFSET(0)] as first_elem

## Arrays select a field

Note: This is safe even when the field is null - result will just be null

    SELECT repeated_record[SAFE_OFFSET(1)].field

## Mapping an array

    SELECT ARRAY(SELECT repeated_record.field FROM UNNEST(repeated_record))
    FROM table

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

    WITH data AS
    (SELECT * FROM UNNEST([
        STRUCT(1 as id, 'a' as join_key),
        STRUCT(2 as id, 'a' as join_key),
        STRUCT(3 as id, 'a' as join_key),
        STRUCT(4 as id, 'a' as join_key),
        STRUCT(5 as id, 'a' as join_key),
        STRUCT(60 as id, 'b' as join_key)
    ]))
    SELECT * FROM data a INNER JOIN data b USING(join_key)

## Loading data from terminal

    bq load --location=EU --source_format=AVRO --autodetect project:dataset.table 'gs://bucket/path/to/part-*'