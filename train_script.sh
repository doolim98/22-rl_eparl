#!/bin/bash -eu

AGENT_NAME=$1 # dqn,
TAG=$2

export CUDA_VISIBLE_DEVICES=0


BASE_DIR=/root/batch_rl/out/$TAG
REPLAY_DIR=/data/dqn/Breakout/1

python -um batch_rl.fixed_replay.train \
    --part_size=10 --part_id=0 \
    --base_dir=$BASE_DIR \
    --replay_dir=$REPLAY_DIR \
    --agent_name=$AGENT_NAME \
    --gin_files='batch_rl/fixed_replay/configs/dqn.gin' \
    --gin_bindings='atari_lib.create_atari_environment.game_name = "Breakout"' \
    --gin_bindings='FixedReplayRunner.num_iterations=100'


# python -um batch_rl.fixed_replay.train   \
# 		--base_dir=/data/common/kahlua/COPA/Pong/hash_1  \
#     --replay_dir=/data/common/kahlua/dqn_replay/hash_split/Pong/hash_1/ \
#     --gin_files='batch_rl/fixed_replay/configs/dqn.gin' \
#     --gin_bindings='atari_lib.create_atari_environment.game_name = "Pong"' \
#     --gin_bindings='FixedReplayRunner.num_iterations=100'