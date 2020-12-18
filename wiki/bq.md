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
