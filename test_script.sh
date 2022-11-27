#!/bin/bash -eu

python -um batch_rl.tests.fixed_replay_runner_test \
  --replay_dir=/data/dqn/Breakout/1
