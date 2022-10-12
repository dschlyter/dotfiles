References
----------

    foo: &anchor
        K1: "One"
        K2: "Two"
    bar: *anchor

## Extensions

    foo: &anchor
        K1: "One"
        K2: "Two"
    bar:
        <<: *anchor
        K2: "I Changed"
        K3: "Three"

(This might not be in the yaml standard, but instead be a common function in parsers)

## Using extensions for partial anchors

    foo:
        <<: &anchor
            K1: "One"
        K2: "Two"
    bar:
        <<: *anchor
        K3: "Three"

More info https://blog.daemonl.com/2016/02/yaml.html

## Extensions for lists

Does not work :(
