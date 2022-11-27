#!/bin/bash -eu

cd "$(dirname "$0")"

DIR=$PWD
ROM_DIR="$HOME/data/atari_roms"

IMAGE_LIST=$(sudo docker image ls)

cd ../dopamine
if ! sudo docker image ls | grep 'dopamine/core';then
    sudo docker build -f docker/core/Dockerfile -t dopamine/core .
        # --build-arg cuda_docker_tag=11.1.1-cudnn8-devel-ubuntu20.04 .
    sudo docker build -f docker/atari/Dockerfile -t dopamine/atari $ROM_DIR
fi

cd "$DIR"
sudo docker build -t batch_rl .