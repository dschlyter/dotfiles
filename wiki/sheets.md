Google sheets is not bad actually

# Making new shapes

Combine rows with ; and columns with ,

    {A3:C3; A5:C5}

    {A3:A5, C3:C5}

Use transpose to get a new shape

    TRANSPOSE({A3:C3; A5:C5})

# Stable Cells

Won't get relative change when being moved

    =A$1:A12

## Indirect cells

Useful if you want to SUM to the current row, and not have the sum messed up by drag and drop reordering of rows.

    =SUM(INDIRECT("G3:G" & ROW()))

# Queries

In general works kinda like expected. There are no joins.

A simple query

    =QUERY(A:D, "SELECT SUM(A) WHERE D IS NOT NULL")

Changing header rows, not standard SQL

    =QUERY(A:D, "SELECT SUM(A), SUM(B) WHERE D IS NOT NULL LABEL SUM(A) 'A Label', SUM(B) 'B Label'")

If you don't want header rows

    =QUERY(A:D, "SELECT A WHERE D IS NOT NULL", 0)

If you don't want header rows, but you use aggegations. (This also allows usage in formulas).

    =QUERY(A:D, "SELECT SUM(A) WHERE D IS NOT NULL LABEL SUM(A) ''", 0)

You can use new shapes, but you then need generic names `Col1`, `Col2` etc.

    =QUERY({C:C, E:E}, "SELECT Col1 WHERE Col2 IS NULL")

Getting the last value of a colum. Uses an ARRAYFORMULA for row number input.

    =QUERY({ARRAYFORMULA(ROW(G:G)), G:G}, "SELECT Col2 WHERE Col2 IS NOT NULL ORDER BY Col1 DESC LIMIT 1 LABEL Col2 'Last Val'", 0)