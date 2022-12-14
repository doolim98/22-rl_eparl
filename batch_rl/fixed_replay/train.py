# coding=utf-8
# Copyright 2021 The Google Research Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

r"""The entry point for running experiments with fixed replay datasets.

"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import functools
import json
import os


from absl import app
from absl import flags

from batch_rl.fixed_replay import run_experiment
from batch_rl.fixed_replay.agents import dqn_agent
from batch_rl.fixed_replay.agents import multi_head_dqn_agent
from batch_rl.fixed_replay.agents import quantile_agent
from batch_rl.fixed_replay.agents import rainbow_agent

from dopamine.discrete_domains import run_experiment as base_run_experiment
import tensorflow.compat.v1 as tf

# from dopamine.google import xm_utils

flags.DEFINE_integer('part_size', 50,'total partition num')
flags.DEFINE_integer('eparl_size', 50,'eparl partition num')
flags.DEFINE_integer('part_id', None,'partition id')
flags.DEFINE_string('agent_name', 'dqn', 'Name of the agent.')
flags.DEFINE_string('base_dir', None,
                    'Base directory to host all required sub-directories.')
flags.DEFINE_multi_string(
    'gin_files', [], 'List of paths to gin configuration files (e.g.'
    '"third_party/py/dopamine/agents/dqn/dqn.gin").')                    
flags.DEFINE_multi_string(
    'gin_bindings', [],
    'Gin bindings to override the values set in the config files '
    '(e.g. "DQNAgent.epsilon_train=0.1",'
    '      "create_environment.game_name="Pong"").')
flags.DEFINE_string('replay_dir', None, 'Directory from which to load the '
                    'replay data')
flags.DEFINE_string('init_checkpoint_dir', None, 'Directory from which to load '
                    'the initial checkpoint before training starts.')

FLAGS = flags.FLAGS


def create_agent(sess, environment, replay_data_dir, summary_writer=None):
  """Creates a DQN agent.

  Args:
    sess: A `tf.Session`object  for running associated ops.
    environment: An Atari 2600 environment.
    replay_data_dir: Directory to which log the replay buffers periodically.
    summary_writer: A Tensorflow summary writer to pass to the agent
      for in-agent training statistics in Tensorboard.

  Returns:
    A DQN agent with metrics.
  """
  if FLAGS.agent_name == 'dqn':
    agent = dqn_agent.FixedReplayDQNAgent
  elif FLAGS.agent_name == 'c51':
    agent = rainbow_agent.FixedReplayRainbowAgent
  elif FLAGS.agent_name == 'quantile':
    agent = quantile_agent.FixedReplayQuantileAgent
  elif FLAGS.agent_name == 'multi_head_dqn':
    agent = multi_head_dqn_agent.FixedReplayMultiHeadDQNAgent
  else:
    raise ValueError('{} is not a valid agent name'.format(FLAGS.agent_name))

  def ckpt_chooser(ckpts):
    psz = int(FLAGS.part_size)
    epsz = int(FLAGS.eparl_size)
    pid = int(FLAGS.part_id)
    print(f"EPARL: part chooser: psz:{psz}, epsz:{epsz}, pid:{pid}")
    assert pid < epsz
    if psz == epsz:
      print("normal partition")
      ckpts = [x for x in ckpts if int(x) %
              psz == pid]
    else:
      print("eparl partition")
      p_ckpts = []
      d_ckpts = []
      for x in ckpts:
        if int(x) % psz == pid:
          p_ckpts += [x]
        elif int(x) % psz >= epsz:
          d_ckpts += [x]
      d_csz = len(d_ckpts)//epsz
      d_idx = d_csz*pid
      print(f"EPARL: d_csz:{d_csz}, d_idx:{d_idx}, d_ckpts:{d_ckpts}")
      d_ckpts = d_ckpts[d_idx:d_idx+d_csz]
      ckpts = p_ckpts + d_ckpts
    """
    [1,2,3,4,5,6,7,8]
    [1,5][2,6][3,7][4,8]

    s: atomic set size
    p: preserved set num
    d: distributed set num
    total = s*p + s*d
    poison in preserved: Kp < p
    poison in distributed: Kd < d

    (Kp+Kd)/(p+d)
    
    > after parition
    partition num: p
    max poision: Kp+Kd
    (Kp+Kd)/p

    """

    print(ckpts)
    return ckpts

  return agent(sess, num_actions=environment.action_space.n, ckpt_chooser=ckpt_chooser,
               replay_data_dir=replay_data_dir, summary_writer=summary_writer,
               init_checkpoint_dir=FLAGS.init_checkpoint_dir)




def main(unused_argv):
  tf.logging.set_verbosity(tf.logging.INFO)
  base_run_experiment.load_gin_configs(FLAGS.gin_files, FLAGS.gin_bindings)
  replay_data_dir = os.path.join(FLAGS.replay_dir, 'replay_logs')
  create_agent_fn = functools.partial(
      create_agent, replay_data_dir=replay_data_dir)
  runner = run_experiment.FixedReplayRunner(FLAGS.base_dir, create_agent_fn, evaluation_steps=30000)
  runner.run_experiment()


if __name__ == '__main__':
  flags.mark_flag_as_required('replay_dir')
  flags.mark_flag_as_required('base_dir')
  app.run(main)
