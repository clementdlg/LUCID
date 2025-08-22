#!/usr/bin/env bash

set -xeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
readonly _ARGS=("$@")
readonly _SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

main() {
	# DECLARATIONS 
	declare -A _CONFIG # config as array
	declare -A _CONFIG_INDEX # enable fast lookup
	_CONFIG_FILE=""

	# defines the order of execution of the modules
	readonly _PREFIXES=(
		# "disk"
		"user"
		# "repo"
		"pkg"
		# "systemd"
		"git-clone"
		"dotfiles"
		# "pipx"
		# "flatpak"
		# "libvirt"
		# "fw"
		"groups"
	)

	# INCLUDES
	source "$_SCRIPT_DIR/src/utils.sh"
	source "$_SCRIPT_DIR/src/config-parse.sh"

	for prefix in "${_PREFIXES[@]}"; do
		mod_file="${_SCRIPT_DIR}/src/modules/${prefix}.sh"

		if [[ -f "$mod_file" ]]; then
			source "$mod_file"
		else
			log e "Source file does not exist : $mod_file"
			exit 1
		fi
	done
	check_privileges

	# show help
	if (( ${#_ARGS[@]} == 0 )) || is_in_array "--help" "${_ARGS[@]}" ; then
		usage
		exit 0
	fi

	get_config

	parse_config
	
	print_config # debug

	if is_in_array "--check" "${_ARGS[@]}" || is_in_array "-c" "${_ARGS[@]}"; then
		exit 0
	fi

	# execute all modules
	for prefix in "${_PREFIXES[@]}"; do
		local function="${prefix}_module"

		if declare -F "$function" >/dev/null; then
			eval "$function"
		else
			log e "Missing module $function in source files"
			exit 1
		fi
	done
}

main
