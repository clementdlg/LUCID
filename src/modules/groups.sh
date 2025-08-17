# Description : 
# Add user to groups if needed. 
# Does not create any groups, as this module is intended for system groups. 
# Must run at the end of the script to ensure service groups are created by their respective packages
groups_module() {
	log d "groups module"
	set -x
	local -n config="$1"

	if [[ ! -v config["groups"] || -z "${config["groups"]}" ]]; then
		return
	fi

	local groups_str="$(echo "${config["groups"]}" | tr ":" " ")"

	local groups_changed=0

	for grp in $groups_str; do
		if ! silent getent group "$grp"; then
			log w "Not adding $_LOGIN to group $grp because $grp does not exist"
			continue
		fi

		if ! check_user_in_group "$_LOGIN" "$grp"; then
			usermod -aG "$grp" "$_LOGIN"
			groups_changed=1
		fi
	done

	if (( groups_changed )); then
		log i "User $_LOGIN have been added to groups"
	else
		log i "User $_LOGIN was already member of all valid requested groups"
	fi

}

check_user_in_group() {
	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} Missing param #1 : user"
		return 1
	fi

	if [[ -z "$2" ]]; then
		log e "${FUNCNAME} Missing param #2 : group"
		return 1
	fi

	local user="$1"
	local group="$2"

	if id -nG "$user" | grep -qw "$group"; then
		return 0
	else
		return 1
	fi
}
