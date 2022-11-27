#!/bin/bash -eu

cd "$(dirname "$0")"

ROOT_DIR="$PWD/.."
DATA_DIR="$HOME/data/"

sudo docker run --gpus all -it \
    -v "$ROOT_DIR":/root/batch_rl \
    -v "$DATA_DIR":/data \
    batch_rl bash