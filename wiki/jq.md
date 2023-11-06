Cheatsheet
==========

[Cheatsheet](https://lzone.de/cheat-sheet/jq)

Just extracting fields

    head data.json | jq ".field1"
    head data.json | jq "{field1, field2}"

Extracting keys from array

    head data.json | jq ".[].field1"
    head data.json | jq ".[] | {field1, field2}"

Transforming the array (output is also an array)

    head data.json | jq 'map({title, label})'

Keys

    head data.json | jq keys
    head data.json | jq ".field | keys"

List all keys, including nested

    jq '[path(..)|map(if type=="number" then "[]" else tostring end)|join(".")|split(".[]")|join("[]")]|unique|map("."+.)|.[]'

Or more simply but less powerful (-s combines all inputs into one array)

    jq -s '.[0] | paths | join(".")'

Select

    jq '.results[] | select((.name == "Joe") and (.age = 10))' # Get complete records for all 'Joe' aged 10
    jq '.results[] | select(.name | contains("Jo"))'           # Get complete records for all names with 'Jo'
    jq '.results[] | select(.name | test("Joe\s+Smith"))'      # Get complete records for all names matching PCRE regex 'Joe\+Smith'

