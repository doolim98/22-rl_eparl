#!/bin/bash -eu

# python -um batch_rl.tests.fixed_replay_runner_test \
#   --replay_dir=/data/dqn/Breakout/1

export CUDA_VISIBLE_DEVICES=0
MODEL_DIR=$1
BASE_DIR=$2
AGENT_NAME=$3
TOTAL_NUM=$4

MAX_STEP=1000

python -um batch_rl.fixed_replay.test \
    --base_dir "$BASE_DIR" --model_dir "$MODEL_DIR/" \
    --cert_alg vanilla \
    --total_num $TOTAL_NUM --max_steps_per_episode $MAX_STEP \
    --agent_name $AGENT_NAME \
    --gin_files='batch_rl/fixed_replay/configs/dqn.gin' \
    --gin_bindings='atari_lib.create_atari_environment.game_name = "Breakout"'

    # --gin_bindings='LoggedDQNAgent.tf_device = "/cpu:0"' \