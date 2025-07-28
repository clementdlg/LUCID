#!/usr/bin/env bash

set -euo pipefail

readonly _ARGS=("$@")
readonly _SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

file_exists() {
	file="$1"
	if [[ ! -f "$file" ]]; then
		log e "'$file' does not exist"
	fi
}

# includes
utils_src="$_SCRIPT_DIR/src/utils.sh"
modules_src="$_SCRIPT_DIR/src/modules.sh"
file_exists "$utils_src" && . "$utils_src"
file_exists "$modules_src" && . "$modules_src"

# defines the order of execution of the modules
readonly _PREFIXES=(
	"pkg"
	"fw"
	"dotfiles"
	"flatpak"
)

declare -A _CONFIG # config as array
_CONFIG_FILE=""

main() {
	declare -A buffer

	# show help
	if (( ${#_ARGS[@]} == 0 )) || is_in_array "--help" "${_ARGS[@]}" ; then
		usage
		exit 0
	fi

	get_config

	check_config_syntax
	
	if is_in_array "--check" "${_ARGS[@]}" || is_in_array "-c" "${_ARGS[@]}"; then
		exit 0
	fi

	echo "config keys = ${!_CONFIG[@]}" # debug
	printf "\n\n" # debug

	# set -x

	# execute all modules
	for prefix in "${_PREFIXES[@]}"; do
		# buffer stores every that matches the prefix
		set_buffer "$prefix"

		if declare -F "${prefix}_module" >/dev/null; then
			${prefix}_module buffer
			printf "\n\n" # debug
		fi
	done
}

main
