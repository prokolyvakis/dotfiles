#!/bin/bash

# update origin references in case it is stale
git fetch

# do not exit if following commands return non-zero exit code
# want to store and use these exit codes
set +e

# only update local git if no local changes uncommitted
(git --no-pager diff --quiet --exit-code)
local_changed_files=$?

# only update local git if local git is not ahead of master
(($(git rev-list --right-only --count origin/master..master) == 0))
ahead_of_origin_master=$?

# go back to exiting if any command fails
set -e

# update local git if zero local changes
if [[ ${local_changed_files} -eq 0 && ${ahead_of_origin_master} -eq 0 ]]; then
  git reset --hard origin/master
else
  echo 'Local git has changes or is ahead of origin/master, so not updating local git.'
fi