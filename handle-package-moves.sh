#!/bin/bash

# Updates particles using profiles/updates.
# Arguments: file name(s) to profiles/updates/*.
# example: this-script /usr/portage/profiles/updates/*-2012

# Assumes that packages with category foo-bar are in foo-bar.particle
# under $particles_dir.

# (C) 2012 Sławomir Nizio <slawomir.nizio#sabayon.org>
# this scripty is placed in public domain
# (C) 2014 if it's public domain, we cannot acknowledge the new author

# for example: particles.git/weekly
# default value is useful when it's run from particles.git directory
particles_dir=${particles_dir:-.}

# don't edit this
available_after_move=()

if [[ $# -eq 0 ]]; then
	# TODO: automatically generate a list of files, including those available
	# on the configured overlays
	echo "$0 FILE [FILE...]" >&2
	echo "FILE = 4Q-2012, for example" >&2
	exit 1
fi

start() {
	for file in "$@"; do
		readfileanddostuff "$file" || { echo "aborted"; exit 1; }
	done
}

pkgmove() {
	local target="${1}"
	local old="${2}"
	local new="${3}"

	# handle app-foo/bar,
	sed -i "s:$old,:$new,:g" "$target" || return 1
	# handle app-foo/bar:
	sed -i "s;$old:;$new:;g" "$target" || return 1
	# handle app-foo/bar$
	sed -i "s;${old}$;$new;g" "$target" || return 1
	# XXX: handle versioned <app-foo/bar-9999 without
	# rewriting wrong PN. app-foo/bar-baz-9999 != app-foo/bar-9999.
	sed -i "s;${old}-;${new}- # verify (was: move $old $new);g" "$target" || return 1
}

slotmove() {
	local target="${1}"
	local dep="${2}"
	local old="${3}"
	local new="${4}"

	# handle app-foo/bar:SLOT,
	sed -i "s;$dep:$old,;$dep:$new,;g" "$target" || return 1
	# handle app-foo/bar$
	sed -i "s;$dep:${old}$;$dep:$new;g" "$target" || return 1
	# XXX: handle versioned <app-foo/bar-9999 without
	# rewriting wrong PN. app-foo/bar-baz-9999 != app-foo/bar-9999.
	sed -i "s;$dep:$old;$dep:$new # verify (was: $dep $old $new);g" "$target" || return 1
}

readfileanddostuff() {
	local file=$1
	local old new
	local oldcat newcat

	echo "** $file **"
	if [[ ! -r $file ]]; then
		echo "$file doesn't exist or can't be read, or is invalid type" >&2
		return 1
	fi
	for particle in $(find "${particles_dir}" -name "*.particle" | sort); do
		while read op old new; do
			if [[ "$op" = "move" ]]; then
				pkgmove "$particle" "$old" "$new"
			elif [[ "$op" = "slotmove" ]]; then
				slotmove "$particle" "$old" $new # this contains 2 vals
			fi
		done < "$file"
	done
}

start "$@"
