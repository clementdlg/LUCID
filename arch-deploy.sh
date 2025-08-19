#!/usr/bin/env bash

set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
readonly _ARGS=("$@")
readonly _SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

main() {
	# INCLUDES

	source "$_SCRIPT_DIR/src/utils.sh"
	source "$_SCRIPT_DIR/src/config-parse.sh"

	for prefix in "${_PREFIXES[@]}"; do
		mod_file="${_SCRIPT_DIR}/src/modules/${prefix}.sh"
		if [[ -f "$mod_file" ]]; then
			source "${_SCRIPT_DIR}/src/modules/${prefix}.sh"
		else
			log e "Source file does not exist : $mod_file"
			exit 1
		fi
	done

	# DECLARATIONS 
	declare -A _CONFIG # config as array
	declare -A _CONFIG_INDEX # enable fast lookup
	# declare -A buffer
	_CONFIG_FILE=""

	# defines the order of execution of the modules
	readonly _PREFIXES=(
		# "disk"
		"user"
		"pkg"
		"dotfiles"
		# "pipx"
		# "flatpak"
		# "systemd"
		# "libvirt"
		# "fw"
		# "repos"
		"groups"
	)

	check_privileges

	# show help
	if (( ${#_ARGS[@]} == 0 )) || is_in_array "--help" "${_ARGS[@]}" ; then
		usage
		exit 0
	fi

	get_config

	parse_config
	
	declare -p _CONFIG # print
	declare -p _CONFIG_INDEX # print

	# if is_in_array "--check" "${_ARGS[@]}" || is_in_array "-c" "${_ARGS[@]}"; then
	# 	exit 0
	# fi
	#
	# # execute all modules
	# for prefix in "${_PREFIXES[@]}"; do
	# 	# buffer stores every key that matches the prefix
	# 	set_buffer "$prefix"
	#
	# 	if declare -F "${prefix}_module" >/dev/null; then
	# 		${prefix}_module buffer
	# 	else
	# 		log e "Missing module ${prefix}_module in source files"
	# 		exit 1
	# 	fi
	# done
}

main
