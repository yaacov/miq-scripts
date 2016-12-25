#!/bin/bash
# Instructions by Martin Hradil
# Original PR by Martin Hradil - https://github.com/ManageIQ/guides/pull/176/files
# [ Converted to script by Yaacov Zamir ]

if [ -z "$1" ]; then
    echo "Please provide a PR number"
fi

PR=$1
COMMITS=`wget -qO- https://api.github.com/repos/ManageIQ/manageiq/pulls/$PR/commits | jq -r .[].sha`
TITLE=`wget -qO- https://api.github.com/repos/ManageIQ/manageiq/pulls/$PR | jq -r .title`
DESCRIPTION=`wget -qO- https://api.github.com/repos/ManageIQ/manageiq/pulls/$PR | jq -r .body`

git remote add tmp https://github.com/ManageIQ/manageiq.git

git fetch tmp pull/$PR/head
git checkout -b miq_pr_$PR

echo "Running cherry-pick - if there's a conflict, resolve it, commit, and do git cherry-pick --continue"
git cherry-pick -x $COMMITS

git push -u origin miq_pr_$PR
[ -x "`which hub`" ] && hub pull-request -m "$TITLE

$DESCRIPTION

(converted from ManageIQ/manageiq#$PR)" || echo "hub not found, not creating PR"

git remote rm tmp

