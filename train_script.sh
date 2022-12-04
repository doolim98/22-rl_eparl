#!/bin/bash -eu


export CUDA_VISIBLE_DEVICES=0

NUM_ITER=50

train(){
    AGENT_NAME=$1 # dqn,quantile
    PART_SIZE=$2
    EPARL_SIZE=$3
    DATA_ID=$4
    PART_ID=$5

    HASH_ID=$((PART_ID + (DATA_ID-1)*EPARL_SIZE ))

    BASE_DIR=/root/batch_rl/out/"${AGENT_NAME}_${PART_SIZE}_${EPARL_SIZE}"/"hash_${HASH_ID}"
    REPLAY_DIR=/data/dqn/Breakout/$DATA_ID
    if [[ -f "$BASE_DIR/checkpoints/ckpt.$((NUM_ITER-1))" ]];then
        echo "$0: already trained $NUM_ITER iterations. skip" 1>&2
        return
    fi

    python -um batch_rl.fixed_replay.train \
        --part_size=$PART_SIZE --eparl_size=$EPARL_SIZE --part_id=$PART_ID \
        --base_dir=$BASE_DIR \
        --replay_dir=$REPLAY_DIR \
        --agent_name=$AGENT_NAME \
        --gin_files="batch_rl/fixed_replay/configs/$AGENT_NAME.gin" \
        --gin_bindings='atari_lib.create_atari_environment.game_name = "Breakout"' \
        --gin_bindings="FixedReplayRunner.num_iterations=${NUM_ITER}" 
}

train_quantile_6_4(){
    train quantile 6 4 $1 $2
}

train_dqn_6_4(){
    train dqn 6 4 $1 $2
}

train "$@"

# trap 'trap " " SIGTERM; kill 0; wait;' SIGINT SIGTERM

# train_dqn_6_4 1 0 &
# train_dqn_6_4 1 1 &
# train_dqn_6_4 1 2 &
# train_dqn_6_4 1 3 &
# train_dqn_6_4 1 4 &
# wait

# CUDA_VISIBLE_DEVICES=1 train_quantile_6_4 1 1
# train_quantile_6_4 1 2
# train_quantile_6_4 1 2 &
# train_quantile_6_4 1 3 &
# train_quantile_6_4 1 4 &
