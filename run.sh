#!/bin/bash

SCRIPT="$1"
SCRIPTDIR="./${SCRIPT%${SCRIPT##*/}}"

# CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES=$2

# the rest of the arguments to be passed to $SCRIPT
# NO QUOTES IN ANY ARGS or the quote escaping below will mess up real bad
ARGS=("${@:3}")
ARGSTXT=${3:+$(printf -- "-%s" "${ARGS[@]//-}")}
ARGS=${3:+$(printf -- "\"%s\" " "${ARGS[@]}")}

SCRIPTNAME="${SCRIPT##*/}"
JOBNAME="$SCRIPTNAME"-gpus${CUDA_VISIBLE_DEVICES//,}"$ARGSTXT"
#JOBNAME="${SCRIPTNAME%.sh}"-gpus${CUDA_VISIBLE_DEVICES//,}"$ARGSTXT"

SHEBANG=$(head -n1 "$SCRIPT")
SHEBANG=${SHEBANG#\#!}
COMMAND="$SHEBANG \"$SCRIPT\" $ARGS"

# sh -c "exec $COMMAND" &> "$JOBNAME.out" &
# OUTFILE="$JOBNAME.$!"
# mv "$JOBNAME.out" "$OUTFILE.out"
# echo $COMMAND "&> \"$OUTFILE.out\""

OUTFILE="$HOME/runlogs/$JOBNAME.out.tmp"

date --iso=s >> "$OUTFILE"

(echo; echo "Current working directory:"; pwd; echo) >> "$OUTFILE"

if GITHASH=$(git -C "$SCRIPTDIR" rev-parse --short HEAD 2> /dev/null); then
  echo "$SCRIPTDIR currently at commit $GITHASH" >> "$OUTFILE"
  if output=$(git -C "$SCRIPTDIR" status --porcelain) && [ -z "$output" ]; then
    (echo "Working directory is clean (no unstaged changes or untracked files)") >> "$OUTFILE"
  else
    (echo; echo "WARNING: Working directory is not clean! There are uncommited changes.") >> "$OUTFILE"
  fi
else
  echo "No git repository found." >> "$OUTFILE"
fi
echo >> "$OUTFILE"

if [[ ! -z $VIRTUAL_ENV ]]; then
  (echo "Current virtual environment:"; echo "$VIRTUAL_ENV"; echo "(another may be activated later by your script)"; echo) >> "$OUTFILE"
else
  (echo "No virtual environment activated (yet)"; echo) >> "$OUTFILE"
fi

echo "$COMMAND" >> "$OUTFILE"
eval $COMMAND &>> "$OUTFILE" &
PARENT_PID=$!
# $! is only the PID of the eval, its direct child is the shebang + script
# and we presume the script has a single direct child that we want to kill
# so that's the PID we use in the output file
#sleep 0.5 # to make sure python starts
#PYTHON_PID=$(pgrep -P $(pgrep -P $PARENT_PID))
# or only go a single level if spawning python directly from the eval (as SCRIPT)
PYTHON_PID=$(pgrep -P $PARENT_PID)
echo $COMMAND "&> \"$HOME/runlogs/$JOBNAME.$PYTHON_PID.out\""
mv "$OUTFILE" "$HOME/runlogs/$JOBNAME.$PYTHON_PID.out"
