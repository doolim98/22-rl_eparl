# COPA
## Setup
```sh
$ docker/build.sh
$ docker/run.sh
# in docker 
$ download.sh
```

## Data partitioning
```sh
$ ./split_script.sh Breakout
```

# Origianl README

This is the implementation of the ICLR 4064 submission "COPA: Certifying Robust Policies for Offline Reinforcement Learning against Poisoning Attacks". The code is adapted on the basis of the offline RL training repo https://github.com/google-research/batch_rl.

Basically, we provide two certification (**per-state action certification** and **reward certification**) for three aggregation protocols (**PARL, TPARL, DPARL**). Below we present the example commands for running these certifications.

## Dataset Partitioning via Hashing

1. Generate the trajectory indices for each hash num in $[50]$: 

```bash
python split.py --train-data-folder /data/common/kahlua/dqn_replay/$1/$2/replay_logs \
                --output-folder /data/common/kahlua/dqn_replay/hash_split/$1_$2
```

With the above command in ``split_script.sh``, simply run the following commands, e.g., for the game Pong.

```bash
bash split_script.sh Pong 1
bash split_script.sh Pong 2
bash split_script.sh Pong 3
bash split_script.sh Pong 4
bash split_script.sh Pong 5
```

2. For each hash number, generate the corresponding datasets

```bash
python gen_split.py --train-data-folder /data/common/kahlua/dqn_replay/$3/$1/replay_logs \
                    --epi-index-path /data/common/kahlua/dqn_replay/hash_split/$3_$1/partition_$2.pt \
                    --output-folder /data/common/kahlua/dqn_replay/hash_split/$3_$1/dataset/hash_$2 \
                    --start-id 0 --end-id 50
```

With the above command in ``gen_split_script.sh``, simply run the following commands, e.g., for the game Pong.

```bash
bash gen_split_script.sh 1 0 Pong
bash gen_split_script.sh 2 0 Pong
bash gen_split_script.sh 3 0 Pong
bash gen_split_script.sh 4 0 Pong
bash gen_split_script.sh 5 0 Pong
```

The above commands generate the $5$ datasets for hash number $0$. We would repeat the above commands for $50$ times to generate the datasets for hash number $0\sim49$.

3. For each hash number, merge the $5$ Datasets

```bash
python merge_splits.py --input-folder /data/common/kahlua/dqn_replay/hash_split/Pong --hash-num 0
```

The above command merges the $5$ Datasets for hash number $0$. Repeat it for $50$ times for all hash numbers.

## Model Training

The following command trains the model based on the datasets Pong of hash number $1$ using RL algorithm DQN for $100$ iterations.

```bash
CUDA_VISIBLE_DEVICES=2 python -um batch_rl.fixed_replay.train   \
		--base_dir=/data/common/kahlua/COPA/Pong/hash_1  \
    --replay_dir=/data/common/kahlua/dqn_replay/hash_split/Pong/hash_1/ \
    --gin_files='batch_rl/fixed_replay/configs/dqn.gin' \
    --gin_bindings='atari_lib.create_atari_environment.game_name = "Pong"' \
    --gin_bindings='FixedReplayRunner.num_iterations=100'
```

## Certifying Per-State Action

1. PARL

```bash
python -um batch_rl.fixed_replay.test \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg tight \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \
      --gin_files='copa/fixed_replay/configs/dqn.gin' \                                                                                                                                 			  --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'
```

where `base_dir` is the path for storing experimental logs and results, and `model_dir` is the path of trained $u$ subpolicies.

2. TPARL

```bash
python -um batch_rl.fixed_replay.test \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg window --window_size 4 \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \
       --gin_files='copa/fixed_replay/configs/dqn.gin' \ 
       --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'

```

For TPARL, we explicitly pass the `cert_alg` option as `window` and configure the predetermined window size $W$.

3. DPARL

```bash
python -um batch_rl.fixed_replay.test \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg dynamic --max_window_size 5 \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \
       --gin_files='copa/fixed_replay/configs/dqn.gin' \                                                                                                                                 			  --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'
```

For DPARL, we explicitly pass the `cert_alg` option as `dynamic` and configure the maximum window size $W_{\rm max}$.

## Certifying Cumulative Reward

1. PARL

```bash
python -um batch_rl.fixed_replay.test_reward \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg tight \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \
       --gin_files='copa/fixed_replay/configs/dqn.gin' \                                                                                                                                 			  --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'
```

where `base_dir` is the path for storing experimental logs and results, and `model_dir` is the path of trained $u$ subpolicies.

2. TPARL

```bash
python -um batch_rl.fixed_replay.test_reward \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg window --window_size 4 \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \                                                                                                                             			 --gin_files='copa/fixed_replay/configs/dqn.gin' \                                                                                                                                 			  --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'
```

For TPARL, we explicitly pass the `cert_alg` option as `window` and configure the predetermined window size $W$.

3. DPARL

```bash
python -um batch_rl.fixed_replay.test_reward \
			 --base_dir [base_dir] --model_dir [model_dir] \
			 --cert_alg dynamic --max_window_size 5 \
			 --total_num 50 --max_steps_per_episode 1000 \
			 --agent_name dqn \                                                                                                                             			 --gin_files='copa/fixed_replay/configs/dqn.gin' \                                                                                                                                 			  --gin_bindings='atari_lib.create_atari_environment.game_name = "Freeway"'
```

For DPARL, we explicitly pass the `cert_alg` option as `dynamic` and configure the maximum window size $W_{\rm max}$.

# An Optimistic Perspective on Offline Reinforcement Learning (ICML, 2020)

This project provides the open source implementation using the
[Dopamine][dopamine] framework for running experiments mentioned in [An Optimistic Perspective on Offline Reinforcement Learning][paper].
In this work, we use the logged experiences of a DQN agent for training off-policy
agents (shown below) in an offline setting (*i.e.*, [batch RL][batch_rl]) without any new
interaction with the environment during training. Refer to
[offline-rl.github.io][project_page] for the project page.

<img src="https://i.imgur.com/Ntgcecq.png" width="95%"
     alt="Architechture of different off-policy agents" >

[paper]: https://arxiv.org/pdf/1907.04543.pdf
[dopamine]: https://github.com/google/dopamine

# How to train offline agents on 50M dataset without RAM errors?
Please refer to https://github.com/google-research/batch_rl/issues/10.

## DQN Replay Dataset (Logged DQN data)

The DQN Replay Dataset was collected as follows:
We first train a [DQN][nature_dqn] agent, on all 60 [Atari 2600 games][ale]
with [sticky actions][stochastic_ale] enabled for 200 million frames (standard protocol) and save all of the experience tuples
of *(observation, action, reward, next observation)* (approximately 50 million)
encountered during training.

This logged DQN data can be found in the public [GCP bucket][gcp_bucket]
`gs://atari-replay-datasets` which can be downloaded using [`gsutil`][gsutil].
To install gsutil, follow the instructions [here][gsutil_install].

After installing gsutil, run the command to copy the entire dataset:

```
gsutil -m cp -R gs://atari-replay-datasets/dqn ./
```

To run the dataset only for a specific Atari 2600 game (*e.g.*, replace `GAME_NAME`
by `Pong` to download the logged DQN replay datasets for the game of Pong),
run the command:

```
gsutil -m cp -R gs://atari-replay-datasets/dqn/[GAME_NAME] ./
```

This data can be generated by running the online agents using
[`batch_rl/baselines/train.py`](https://github.com/google-research/batch_rl/blob/master/batch_rl/baselines/train.py) for 200 million frames
(standard protocol). Note that the dataset consists of approximately 50 million
experience tuples due to frame skipping (*i.e.*, repeating a selected action for
`k` consecutive frames) of 4. The stickiness parameter is set to 0.25, *i.e.*,
there is 25% chance at every time step that the environment will execute the
agent's previous action again, instead of the agent's new action.

#### Publications using DQN Replay Dataset (please open a pull request for missing entries):
- [Revisiting Fundamentals of Experience Replay](https://arxiv.org/abs/2007.06700) 
- [RL Unplugged: A Suite of Benchmarks for Offline Reinforcement Learning](https://arxiv.org/abs/2006.13888)
- [Conservative Q-Learning for Offline Reinforcement Learning](https://arxiv.org/abs/2006.04779) 
- [Implicit Under-Parameterization Inhibits Data-Efficient Deep Reinforcement Learning](https://arxiv.org/abs/2010.14498) 
- [Acme: A new framework for distributed reinforcement learning](https://arxiv.org/abs/2006.00979) 
- [Regularized Behavior Value Estimation](https://arxiv.org/abs/2103.09575)
- [Online and Offline Reinforcement Learning by Planning with a Learned Model](https://arxiv.org/abs/2104.06294)
- [Provable Representation Learning for Imitation with Contrastive Fourier Features](https://arxiv.org/abs/2105.12272)
- [Decision Transformer: Reinforcement Learning via Sequence Modeling](https://arxiv.org/abs/2106.01345)
- [Pretraining Representations for Data-Efficient Reinforcement Learning](https://arxiv.org/abs/2106.04799)


[nature_dqn]: https://www.nature.com/articles/nature14236?wm=book_wap_0005
[gsutil_install]: https://cloud.google.com/storage/docs/gsutil_install#install
[gsutil]: https://cloud.google.com/storage/docs/gsutil
[batch_rl]: http://tgabel.de/cms/fileadmin/user_upload/documents/Lange_Gabel_EtAl_RL-Book-12.pdf
[stochastic_ale]: https://arxiv.org/abs/1709.06009
[ale]: https://github.com/mgbellemare/Arcade-Learning-Environment
[gcp_bucket]: https://console.cloud.google.com/storage/browser/atari-replay-datasets
[project_page]: https://offline-rl.github.io

## Asymptotic Performance of offline agents on Atari-replay dataset

<div>
  <img src="https://i.imgur.com/gAWGgJx.png" width="49%" 
       alt="Number of games where a batch agent outperforms online DQN">
  <img src="https://i.imgur.com/QJiCg37.png" width="49%" 
       alt="Asymptotic Performance of offline agents on DQN data">
</div>

## Installation
Install the dependencies below, based on your operating system, and then
install Dopamine, *e.g*.

```
pip install git+https://github.com/google/dopamine.git
```

Finally, download the source code for batch RL, *e.g.*

```
git clone https://github.com/google-research/batch_rl.git
```

### Ubuntu

If you don't have access to a GPU, then replace `tensorflow-gpu` with
`tensorflow` in the line below (see [Tensorflow
instructions](https://www.tensorflow.org/install/install_linux) for details).

```
sudo apt-get update && sudo apt-get install cmake zlib1g-dev
pip install absl-py atari-py gin-config gym opencv-python tensorflow-gpu
```

### Mac OS X

```
brew install cmake zlib
pip install absl-py atari-py gin-config gym opencv-python tensorflow
```

## Running Tests

Assuming that you have cloned the
[batch_rl](https://github.com/google-research/batch_rl.git) repository,
follow the instructions below to run unit tests.

#### Basic test
You can test whether basic code is working by running the following:

```
cd batch_rl
python -um batch_rl.tests.atari_init_test
```

#### Test for training an agent with fixed replay buffer
To test an agent using a fixed replay buffer, first generate the data for the
Atari 2600 game of `Pong` to `$DATA_DIR`.

```
export DATA_DIR="Insert directory name here"
mkdir -p $DATA_DIR/Pong
gsutil -m cp -R gs://atari-replay-datasets/dqn/Pong/1 $DATA_DIR/Pong
```

Assuming the replay data is present in `$DATA_DIR/Pong/1/replay_logs`, run the `FixedReplayDQNAgent` on `Pong` using the logged DQN data:

```
cd batch_rl
python -um batch_rl.tests.fixed_replay_runner_test \
  --replay_dir=$DATA_DIR/Pong/1
```

## Training batch agents on DQN data

The entry point to the standard Atari 2600 experiment is
[`batch_rl/fixed_replay/train.py`](https://github.com/google-research/batch_rl/blob/master/batch_rl/fixed_replay/train.py).
Run the batch `DQN` agent using the following command:

```
python -um batch_rl.fixed_replay.train \
  --base_dir=/tmp/batch_rl \
  --replay_dir=$DATA_DIR/Pong/1 \
  --gin_files='batch_rl/fixed_replay/configs/dqn.gin'
```

By default, this will kick off an experiment lasting 200 training iterations
(equivalent to experiencing 200 million frames for an online agent).

To get finer-grained information about the process,
you can adjust the experiment parameters in
[`batch_rl/fixed_replay/configs/dqn.gin`](https://github.com/google-research/batch_rl/blob/master/batch_rl/fixed_replay/configs/dqn.gin),
in particular by increasing the `FixedReplayRunner.num_iterations` to see
the asymptotic performance of the batch agents. For example,
run the batch `REM` agent for 800 training iterations on the game of Pong 
using the following command:

```
python -um batch_rl.fixed_replay.train \
  --base_dir=/tmp/batch_rl \
  --replay_dir=$DATA_DIR/Pong/1 \
  --agent_name=multi_head_dqn \
  --gin_files='batch_rl/fixed_replay/configs/rem.gin' \
  --gin_bindings='FixedReplayRunner.num_iterations=1000' \
  --gin_bindings='atari_lib.create_atari_environment.game_name = "Pong"'
```

More generally, since this code is based on Dopamine, it can be
easily configured using the
[gin configuration framework](https://github.com/google/gin-config).


## Dependencies

The code was tested under Ubuntu 16 and uses these packages:

- tensorflow-gpu>=1.13
- absl-py
- atari-py
- gin-config
- opencv-python
- gym
- numpy

The python version upto `3.7.9` has been [reported to work](https://github.com/google-research/batch_rl/issues/21).

Citing
------
If you find this open source release useful, please reference in your paper:

> Agarwal, R., Schuurmans, D. & Norouzi, M.. (2020).
> An Optimistic Perspective on Offline Reinforcement Learning
> *International Conference on Machine Learning (ICML)*.

    @inproceedings{agarwal2020optimistic,
      title={An Optimistic Perspective on Offline Reinforcement Learning},
      author={Agarwal, Rishabh and Schuurmans, Dale and Norouzi, Mohammad},
      journal={International Conference on Machine Learning},
      year={2020}
    }


Note: A previous version of this work was titled "Striving for Simplicity in Off
Policy Deep Reinforcement Learning" and was presented as a contributed talk at
NeurIPS 2019 DRL Workshop.

Disclaimer: This is not an official Google product.
