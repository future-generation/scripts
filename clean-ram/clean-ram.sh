#!/bin/bash
# Needs flock via Homebrew
# https://github.com/discoteq/flock
# brew tap discoteq/discoteq
# brew install flock
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -n "$0" "$0" "$@" || :
FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')
FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS)*4096/1048576))
if [[ $FREE -lt 1024 ]]; then
	purge
else
	echo "No purge needed. Free RAM greater 1GB"
fi
