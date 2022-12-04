#!/bin/bash -eu
cd "$(dirname "$0")"

# download replay datasets
gsutil -m cp -R gs://atari-replay-datasets/dqn/Breakout /data/dqn
gsutil -m cp -R gs://atari-replay-datasets/dqn/Freeway /data/dqn
