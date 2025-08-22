# Description : Ensure user exists. Creates it if necessary.
# Ensure home dir exists, creates one if not.
user_module() {
	log d "${FUNCNAME} : entering"

	local required_keys=("user.login")

	check_required_keys required_keys
	_LOGIN="${_CONFIG["user.login"]}"

	if [[ ! "$_LOGIN" =~ ^[a-z_][a-z0-9_-]*$ || "$_LOGIN" == "root" ]]; then
		log e "Invalid username '$_LOGIN'"
		return 1
	fi

	# ensure user exists
	if ! silent getent passwd "$_LOGIN"; then
		local uid="-1"

		if [[ -v "_CONFIG[user_id]" \
			&& -n "${_CONFIG["user_id"]}" ]]; then
			uid="${_CONFIG["user_id"]}"
		fi

		create_user "$_LOGIN" "$uid"
	fi

	# ensure home is created
	if [[ ! -d "/home/$_LOGIN" ]]; then
		create_home_manually "$_LOGIN"
	fi

	log d "${FUNCNAME} : success"
}

create_user() {
	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} Missing param #1 username"
		return 1
	fi

	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} Missing param #2 uid"
		return 1
	fi

	local username="$1"
	local uid="$2"

	local useradd_args=(
		"--create-home"
		"--user-group"
	)

	if [[ "$uid" != "-1" ]]; then
		if silent getent passwd "$uid"; then
			log e "Invalid UID $uid. Already in use."
			return 1
		fi

		useradd_args+=("--uid $uid")
	fi

	useradd ${useradd_args[@]} "$username"
	log i "Created user '$username'. "
}

create_home_manually() {
	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} Missing param #1 username"
		return 1
	fi

	local username="$1"
	local home="/home/$_LOGIN"

	mkdir -p "$home"
	cp -a /etc/skel/. "$home"
	chown -R "$username:" "$home"
	chmod 755 "$home"

	log i "Created and populated $home"
}
