systemd_module() {
	log d "${FUNCNAME} : entering"

	k_srv_sys="systemd.service.system"
	k_srv_user="systemd.service.user"
	k_target="systemd.target"

	if [[ -v _CONFIG[$k_srv_sys] ]]; then
		systemctl_system "${_CONFIG[$k_srv_sys]}"
	fi

	if [[ -v _CONFIG[$k_srv_user] ]]; then
		local unit_list="$(value_formatter "${_CONFIG[$k_srv_user]}")"
		systemctl_user "${_CONFIG[$k_srv_user]}"

	fi

	if [[ -v _CONFIG[$k_target] ]]; then
		systemctl set-default ${_CONFIG[$k_target]}
	fi

	log d "${FUNCNAME} : success"
}

systemctl_user() {
	local val="$1"

	if [[ -z "$1" ]]; then
		log e "Missing paremeter #1 systemctl user keys"
		return 1
	fi

	local unit_list="$(value_formatter "$val")"
	local path="/home/${_LOGIN}/.config/systemd/user"

	mkdir -p "$path/default.target.wants"

	for unit in $unit_list; do
		ln -sv "${path}/${unit}.service" "${path}/default.target.wants/${unit}.service"
	done
}


systemctl_system() {
	local val="$1"

	if [[ -z "$1" ]]; then
		log e "Missing paremeter #1 systemctl keys"
		return 1
	fi

	local unit_list="$(value_formatter "$val")"

	for unit in $unit_list; do
		# TODO :check if unit is not already enabled
		systemctl enable ${unit}.service
	done
}
