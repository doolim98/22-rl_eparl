#!/bin/bash -eu

# link test dirs, ex) test0, test1, 

NAME="$1-$(date +%s)"
MODEL_DIR="$PWD/out/models/$NAME"
BASE_DIR="$PWD/out/test_${NAME}"

# Move old models if already exists
# if [[ -d $MODEL_DIR ]];then
#     echo "backup old model"
#     mkdir -p "${MODEL_DIR}.old"
#     mv $MODEL_DIR "${MODEL_DIR}.old/$(date +%s)"
# fi

# Generate sub_models
mkdir -p "$MODEL_DIR"

count=1

for d in out/dqn_6_6/*/; do
    cp -al "$PWD/$d" $MODEL_DIR/test"$((count++))"
    # cp -r "$PWD/$d" $MODEL_DIR/test"$((count++))"
done

for d in out/dqn_6_4/*/; do
    cp -al "$PWD/$d" $MODEL_DIR/test"$((count++))"
done

total_num=$((count-1))
# total_num=5

echo total_num: $total_num

./test_script.sh "$MODEL_DIR" "$BASE_DIR" dqn $total_num