#!/bin/bash

SCRIPT="$1"

# CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES=$2

# the rest of the arguments to be passed to $SCRIPT
# NO QUOTES IN ANY ARGS or the quote escaping below will mess up real bad
ARGS=("${@:3}")
ARGSTXT=${3:+$(printf -- "-%s" "${ARGS[@]//-}")}
ARGS=${3:+$(printf -- "\"%s\" " "${ARGS[@]}")}

JOBNAME="${SCRIPT%.sh}"-gpus${CUDA_VISIBLE_DEVICES//,}"$ARGSTXT"

SHEBANG=$(head -n1 "$SCRIPT")
SHEBANG=${SHEBANG#\#!}
COMMAND="$SHEBANG \"$SCRIPT\" $ARGS"

# sh -c "exec $COMMAND" &> "$JOBNAME.out" &
# OUTFILE="$JOBNAME.$!"
# mv "$JOBNAME.out" "$OUTFILE.out"
# echo $COMMAND "&> \"$OUTFILE.out\""

eval $COMMAND &> "$HOME/runlogs/$JOBNAME.out.tmp" &
# $! is only the PID of the eval, its direct child is the shebang + script
# and we presume the script has a single direct child that we want to kill
# so that's the PID we use in the output file
PARENT_PID=$!
sleep 0.5 # to make sure python starts
PYTHON_PID=$(pgrep -P $(pgrep -P $PARENT_PID))
echo $COMMAND "&> \"$HOME/runlogs/$JOBNAME.$PYTHON_PID.out\""
mv "$HOME/runlogs/$JOBNAME.out.tmp" "$HOME/runlogs/$JOBNAME.$PYTHON_PID.out"
