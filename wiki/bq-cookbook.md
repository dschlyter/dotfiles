## Comparing Data

Having two temp tables, comparing data between them.

You could use sampling to speed up for big datasets.

First sanity check a unique group key, for both tables. Should return empty.

    SELECT _KEY_COLUMNS_
    FROM _TEMP_TABLE_
    GROUP BY _KEY_COLUMNS_
    HAVING COUNT(1) > 1

Validate the join. Should return empty or will show diffing rows.

    WITH j AS (
        SELECT IF(prev._SOME_COL_ IS NOT NULL, IF(curr._SOME_COL_ IS NOT NULL, "join", "prev"), "curr") res, *
        FROM _PREV_TABLE_ prev
        FULL OUTER JOIN _CURR_TABLE_ curr
        USING(_KEY_COLUMNS_)
    )
    SELECT * FROM j
    WHERE res != "join"
    ORDER BY _KEY_COLUMNS_

Find rows with high diffs.

    WITH a AS (
        SELECT "prev" AS v, *
        FROM _PREV_TABLE_ prev
        UNION ALL
        SELECT "curr" AS v, *
        FROM _CURR_TABLE_ curr
    ),
    b AS (
        SELECT 
            COUNT(1) OVER pk AS matches,
            MAX(_COL1_) OVER pk - MIN(_COL1_) OVER pk diff1,
            MAX(_COL2_) OVER pk - MIN(_COL2_) OVER pk diff2,
            *
        FROM a
        WINDOW pk AS (PARTITION BY _KEY_COLUMNS_)
    )
    SELECT * FROM b
    ORDER BY GREATEST(diff1, diff2) DESC
