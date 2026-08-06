#!/bin/sh
# Prints the working directory the way starship's [directory] module would with
# truncation_length=3, truncate_to_repo=true, truncation_symbol="…/".
#
# Why this exists: [directory]'s `style` is static — starship has no way to vary
# it by git state. To get a path that changes colour when the working tree is
# dirty, [directory] is disabled and custom.dir_clean / custom.dir_dirty render
# the path instead, sharing this script so the two can't drift apart.
#
# Keep in sync with the truncation settings documented in starship.toml.

max=3
truncated=0

root=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -n "$root" ]; then
	# In a repo: path relative to, and including, the repo root directory.
	# Always counts as truncated — the leading path to the repo is dropped.
	rel="$(basename "$root")${PWD#"$root"}"
	truncated=1
else
	case $PWD in
		"$HOME") rel='~' ;;
		"$HOME"/*) rel="~${PWD#"$HOME"}" ;;
		*) rel=$PWD ;;
	esac
fi

# Keep only the last $max components, flagging that we dropped some.
comps=1
s=$rel
while [ "$s" != "${s#*/}" ]; do
	s=${s#*/}
	comps=$((comps + 1))
done
while [ "$comps" -gt "$max" ]; do
	rel=${rel#*/}
	comps=$((comps - 1))
	truncated=1
done

if [ "$truncated" -eq 1 ]; then
	printf '…/%s' "$rel"
else
	printf '%s' "$rel"
fi
