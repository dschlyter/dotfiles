## Arrays

Because I always forget how they work
    
    # Create and append, note array is zero indexed
    arr=()
    arr=(0 1 2 "three (3)")
    arr+=(4 5)
    
    # When using the array you must always add [@] or [index] at the end, otherwise you just use the first element
    echo "explicitly accessing the first element:" ${arr[0]}
    echo "using without index also gets the first element:" $arr
    
    # Pass the array elements as args into a program - use "" to avoid word sliting in elements
    ls "${arr[@]}"
    
    for a in "${arr[@]}"; do
      echo "iterating over elements:" $a
    done
    
    echo "Starting at 1, take three elements:" "${arr[@]:1:3}"
    echo "Starting at 3, take all elements:" "${arr[@]:3}"
    echo "Taking three elements, implicitly starting at 0:" "${arr[@]::3}"
    echo "Without [@] you pick the first element, and then do character search": "${arr:0:3}"
    
    echo "Number of elements in the array:" "${#arr[@]}"
    
    # Copy array into another - () = don't convert to string, "" don't word split in elements, [@] copy all the elements
    arr2=("${arr[@]}")
    
    # Args can be converted to an array
    args=("$@")
    
    # Without conversion, arguments is a bit like an array - but different
    echo "${@:1:2}" # - works
    echo "${@[1]}" # - does not work
    echo "${@}" # - gets the entire array instead of just the first element
    
    sparse_array=()
    sparse_array[5]="you"
    sparse_array[20]="arbitrary indices"
    sparse_array[10]="can use"
    echo "sparse array values:" "${sparse_array[@]}"
    echo "sparse array keys:" "${!sparse_array[@]}"
    echo "sparse array count" "${#sparse_array[@]}"
    
    # In bash 4+ you can use associative arrays with  (in bash 3 everything gets assigned to 0)
    obj=([foo]=foov [bar]=barv)
    obj[hej]=hejsan
    obj[tja]=tjaba
    obj["with spaces"]="with spaces"
    echo "associative array values" "${obj[@]}"
    echo "associative array keys" "${!obj[@]}"

