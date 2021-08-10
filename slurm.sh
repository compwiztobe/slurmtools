#!/bin/bash

SCRIPT="$1"

PARTITION_TYPE=2080ti
# for slurm jobs, this is simply a device count, we do not specify which devices
# CUDA_VISIBLE_DEVICES will be set automatically by slurm based on the devices allocated on each node
GPUS=$2

# the rest of the arguments to be passed to $SCRIPT
# NO QUOTES IN ANY ARGS or the quote escaping below will mess up real bad
ARGS=("${@:3}")
ARGSTXT=${3:+$(printf -- "-%s" "${ARGS[@]//-}")}
ARGS=${3:+$(printf -- "\"%s\" " "${ARGS[@]}")}

JOBNAME="${SCRIPT%.sh}"-${GPUS}gpus"$ARGSTXT"

SBATCH="sbatch -J \"$JOBNAME\" -o \"$JOBNAME.%j.out\" -t 3-00:00:00 -p $PARTITION_TYPE --gres=gpu:$GPUS -n1 -N1 \"$SCRIPT\" $ARGS"

echo $SBATCH
eval $SBATCH
