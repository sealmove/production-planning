#!/bin/bash
# Requires bash version >= 4 and GNU grep
# mzn2fzn and fzn-gecode should be added to PATH 
# Result: test.log file, where every line says if the test has been passed

GREP="grep"
is_grep_gnu=$(grep --version | grep "GNU grep")
if [ -z "$is_grep_gnu" ]; then 
    # on macos ggrep is a popular alias for gnu grep
    GREP="ggrep"
fi

declare -A test_cases=( 
    ["data/tiny.dzn"]="677" 
    ["data/tiny_mixed_change.dzn"]="759"
    ["data/tiny_mixed_storage.dzn"]="761"
    ["data/tiny_broken.dzn"]="unsat" 
    )

model_basename="production-planning" 
model="$model_basename.mzn"
output_fzn="$model_basename.fzn"
output_ozn="$model_basename.ozn"
compile_test="data/small.dzn"
timelimit=2000

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

syntax_errors=$(minizinc --instance-check-only $model $compile_test 2>&1)
test_result="FAIL"
if [ -z "$syntax_errors" ]; then
    test_result="PASS"
fi
echo "building: $test_result"

for data in "${!test_cases[@]}"; do
    [ -e "$data" ] || continue
    expected=${test_cases["$data"]}
    full_result=$(minizinc -c --ozn $output_ozn --solver Gecode 2>&1 $model $data && fzn-gecode -time $timelimit $output_fzn | minizinc --ozn-file $output_ozn)
    test_result=""
    error=$(echo "$full_result" | $GREP "Error:")
    if [ -n "$error" ]; then 
        test_result="FAIL (bulding error)"
    fi
    
    timeout=$(echo "$full_result" | $GREP "=====UNKNOWN=====")
    if [ -z "$test_result" ] && [ -n "$timeout" ]; then 
        test_result="FAIL (timeout - no solution at all)"
    fi

    unsatisfiable=$(echo "$full_result" | $GREP "=====UNSATISFIABLE=====")
    if [ -z "$test_result" ] && [ -n "$unsatisfiable" ]; then 
        if [ "$expected" == "unsat" ]; then 
            test_result="PASS"
        else 
            test_result="FAIL (got unexpected unsatisfiable)"
        fi 
    fi

    timeout=$(echo "$full_result" | $GREP "==========")
    if [ -z "$test_result" ] && [ -z "$timeout" ]; then 
        test_result="FAIL (timeout - no optimal solution)"
    fi

    if [ -z "$test_result" ]; then
        result=$(echo "$full_result" | $GREP -P 'obj\s*=\s*\d+' | $GREP -Po '\d+')
        test_result="FAIL (expected optimum solution should have obj = $expected, got $result)"
        if [ "$expected" == "$result" ]; then
            test_result="PASS"
        elif [ -z "$result" ]; then
            test_result="FAIL (output is missing 'obj = <objective>' line)"
        fi
    fi

    echo -e "$data: $test_result"
done

rm $output_fzn 2>/dev/null || true 
rm $output_ozn 2>/dev/null || true