#!/bin/bash

local=.
remote="root@192.168.7.2:~/banjer"
dryrun=1

lineargs1="-auz"
lineargs2="-e ssh --exclude .git --exclude .gitignore --exclude build --exclude .DS_Store --progress"

# argument parsing
PARAMS=""
while (( "$#" )); do
  case "$1" in
    --) # end argument parsing
      shift
      break
      ;;
    --remote|-r)
      # Remote directory
      remote=$2
      shift 2
      ;;
    --nodry|-n)
      # Not doing a dry run!
      dryrun=0
      shift
      ;;
    push|pull)
      action=$1
      shift
      ;;
    *) # preserve positional arguments
      echo "Error: Unsupported argument $1" >&2
      exit 1
      ;;
  esac
done

if [ "$action" == "push" ]; then
  src=$local
  dest=$remote
  lineargs2=$lineargs2" --delete" # delete files on push, but not on pull
elif [ "$action" == "pull" ]; then
  src=$remote
  dest=$local
else
  echo "SYNTAX ERROR: expecting './update.sh push|pull --nodry? -r REMOTEPATH'"
  exit 1
fi

if [ $dryrun -eq 1 ]; then
  # dry run by default unless --nodry flag is specified
  lineargs1=$lineargs1"vni"
fi
cmdargs="$lineargs1 $lineargs2 $src/ $dest"
rsync $cmdargs
echo "rsync $cmdargs"
