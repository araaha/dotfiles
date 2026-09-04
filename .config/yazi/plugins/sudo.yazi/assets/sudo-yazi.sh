#!/usr/bin/env bash

set -o nounset
set -o pipefail

die() {
	printf 'sudo-yazi: %s\n' "$*" >&2
	exit 2
}

legit_name() {
	local name=$1 candidate=$1 stem ext i=1

	while [[ -e $candidate || -L $candidate ]]; do
		if [[ $name == *.* ]]; then
			stem=${name%%.*}
			ext=${name#*.}
			candidate="${stem}_${i}.${ext}"
		else
			candidate="${name}_${i}"
		fi
		((i++))
	done

	printf '%s\n' "$candidate"
}

relative_name() {
	local root=$1 path=$2 relative

	if [[ -z $root ]]; then
		printf '%s\n' "$path"
		return
	fi

	relative=${path#"$root"}
	relative=${relative#/}
	printf '%s\n' "$relative"
}

cmd_cp() {
	local force=false path name destination
	if [[ ${1-} == --force ]]; then
		force=true
		shift
	fi

	for path in "$@"; do
		name=$(basename -- "$path")
		if $force; then
			destination=$name
		else
			destination=$(legit_name "$name")
		fi
		cp -rfv -- "$path" "$destination"
	done
}

cmd_mv() {
	local force=false path name destination
	if [[ ${1-} == --force ]]; then
		force=true
		shift
	fi

	for path in "$@"; do
		name=$(basename -- "$path")
		if $force; then
			destination=$name
		else
			destination=$(legit_name "$name")
		fi
		mv -v -- "$path" "$destination"
	done
}

cmd_ln() {
	local relative=false path name destination
	if [[ ${1-} == --relative ]]; then
		relative=true
		shift
	fi

	for path in "$@"; do
		name=$(basename -- "$path")
		destination=$(legit_name "$name")
		if $relative; then
			ln -srv -- "$path" "$destination"
		else
			ln -sv -- "$path" "$destination"
		fi
	done
}

cmd_hardlink() {
	local path name destination
	for path in "$@"; do
		name=$(basename -- "$path")
		destination=$(legit_name "$name")
		ln -v -- "$path" "$destination"
	done
}

trash_path() {
	if command -v trash-put >/dev/null 2>&1; then
		trash-put -- "$1"
	elif command -v gio >/dev/null 2>&1; then
		gio trash -- "$1"
	else
		die 'non-permanent removal requires trash-put or gio'
	fi
}

cmd_rm() {
	local permanent=false path
	if [[ ${1-} == --permanent ]]; then
		permanent=true
		shift
	fi

	for path in "$@"; do
		if $permanent; then
			rm -rf -- "$path"
		else
			trash_path "$path"
		fi
	done
}

cmd_bulk_rename_prepare() {
	local root='' path buffer

	while (($#)); do
		case $1 in
			--root)
				(($# >= 2)) || die '--root requires a value'
				root=$2
				shift 2
				;;
			--root=*)
				root=${1#*=}
				shift
				;;
			--)
				shift
				break
				;;
			*) break ;;
		esac
	done

	buffer=$(mktemp "${TMPDIR:-/tmp}/sudo-yazi-bulk-rename.XXXXXX.txt") || exit
	for path in "$@"; do
		relative_name "$root" "$path" >>"$buffer"
	done

	# relative_name writes a newline; remove only the final one to match Nushell's
	# `str join (char newline)` output.
	if [[ -s $buffer ]]; then
		truncate -s -1 "$buffer"
	fi
	printf '%s\n' "$buffer"
}

cmd_bulk_rename_do() {
	local root='' mapping='' path old_relative new_relative new_path i
	local -a paths new_names

	while (($#)); do
		case $1 in
			--root)
				(($# >= 2)) || die '--root requires a value'
				root=$2
				shift 2
				;;
			--root=*)
				root=${1#*=}
				shift
				;;
			--mapping)
				(($# >= 2)) || die '--mapping requires a value'
				mapping=$2
				shift 2
				;;
			--mapping=*)
				mapping=${1#*=}
				shift
				;;
			--)
				shift
				break
				;;
			*) break ;;
		esac
	done

	[[ -n $mapping ]] || die 'bulk-rename-do requires --mapping'
	paths=("$@")
	mapfile -t new_names <"$mapping"
	rm -f -- "$mapping"

	for i in "${!paths[@]}"; do
		((i < ${#new_names[@]})) || break
		path=${paths[i]}
		old_relative=$(relative_name "$root" "$path")
		new_relative=${new_names[i]}

		if [[ -n $new_relative && $new_relative != "$old_relative" ]]; then
			if [[ -n $root ]]; then
				new_path=${root%/}/$new_relative
			else
				new_path=$new_relative
			fi
			mv -v -- "$path" "$new_path"
		fi
	done
}

main() {
	local command=${1-}
	[[ -n $command ]] || die 'missing command'
	shift

	case $command in
		cp)                  cmd_cp "$@" ;;
		mv)                  cmd_mv "$@" ;;
		ln)                  cmd_ln "$@" ;;
		hardlink)            cmd_hardlink "$@" ;;
		rm)                  cmd_rm "$@" ;;
		bulk-rename-prepare) cmd_bulk_rename_prepare "$@" ;;
		bulk-rename-do)      cmd_bulk_rename_do "$@" ;;
		*) die "unknown command: $command" ;;
	esac
}

main "$@"
