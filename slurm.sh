#!/bin/bash

SCRIPT="$1"

PARTITION_TYPE=$2
# for slurm jobs, this is simply a device count, we do not specify which devices
# CUDA_VISIBLE_DEVICES will be set automatically by slurm based on the devices allocated on each node
GPUS=$3

# the rest of the arguments to be passed to $SCRIPT
# NO QUOTES IN ANY ARGS or the quote escaping below will mess up real bad
ARGS=("${@:4}")
ARGSTXT=${4:+$(printf -- "-%s" "${ARGS[@]//-}")}
ARGS=${4:+$(printf -- "\"%s\" " "${ARGS[@]}")}

JOBNAME="${SCRIPT%.sh}"-${GPUS}x$PARTITION_TYPE"$ARGSTXT"

SBATCH="sbatch -J \"$JOBNAME\" -o \"$HOME/slurmlogs/$JOBNAME.%j.out\" -t 3-00:00:00 -p $PARTITION_TYPE --gres=gpu:$GPUS -n1 -N1 $SLURM_ARGS \"$SCRIPT\" $ARGS"

echo $SBATCH
eval $SBATCH
