#!/bin/bash -u

JN=4

parallel -j $JN './train_script.sh dqn 6 6 {1} {2} >> out/.log 2>&1' ::: $(seq 1 5) ::: $(seq 0 5)
parallel -j $JN './train_script.sh dqn 6 4 {1} {2} >> out/.log 2>&1' ::: $(seq 1 5) ::: $(seq 0 3)