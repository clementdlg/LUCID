systemd_module() {
	log d "${FUNCNAME} : entering"

	k_srv_sys="systemd.service.system"
	k_srv_user="systemd.service.user"
	k_target="systemd.target"

	if [[ -v _CONFIG[$k_srv_sys] ]]; then
		local unit_list="$(value_formatter "${_CONFIG[$k_srv_sys]}")"

		for unit in $unit_list; do
			# TODO :check if unit is not already enabled
			systemctl enable ${unit}.service
		done
	fi

	if [[ -v _CONFIG[$k_srv_user] ]]; then
		local unit_list="$(value_formatter "${_CONFIG[$k_srv_user]}")"

		loginctl enable-linger "$_LOGIN"

		for unit in $unit_list; do
			# TODO :check if unit is not already enabled
			systemctl --user --machine=${_LOGIN}@.host enable ${unit}.service
		done
	fi

	if [[ -v _CONFIG[$k_target] ]]; then
		systemctl set-default ${_CONFIG[$k_target]}
	fi

	log d "${FUNCNAME} : success"
}

# systemd_enable_unit() {
# 	if [[ -z "$1" ]]; then
# 		log e "${FUNCNAME} : Missing param #1 : config unit list"
# 		return 1
# 	fi
#
# 	if [[ -z "$2" ]]; then
# 		log e "${FUNCNAME} : Missing param #2 : unit type"
# 		return 1
# 	fi
#
# 	if [[ -z "$3" ]]; then
# 		log e "${FUNCNAME} : Missing param #3 : user flag"
# 		return 1
# 	fi
#
# 	local unit_list="$(value_formatter "$1")"
# 	local type="$2"
#
# 	for unit in $unit_list; do
# 		# TODO :check if unit is not already enabled
# 		case "$3" in
# 			true)
# 				systemctl --user --machine=${_LOGIN}@.host enable ${unit}.${type} ;;
# 			*)
# 				systemctl enable ${unit}.${type} ;;
# 		esac
# 	done
# }
