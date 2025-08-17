# Description : Ensure user exists. Creates it if necessary.
# Ensure home dir exists, creates one if not.
user_module() {
	log d "User module"

	local -n config="$1"
	local required_keys=("user_login")

	check_required_keys required_keys config
	_LOGIN="${config["user_login"]}"

	if [[ ! "$_LOGIN" =~ ^[a-z_][a-z0-9_-]*$ || "$_LOGIN" == "root" ]]; then
		log e "Invalid username '$_LOGIN'"
		return 1
	fi

	# user creation with/out uid
	if ! silent getent passwd "$_LOGIN"; then
		local uid=""
		local useradd_args=(
			"--create-home"
			"--user-group"
		)

		if [[ -v config["user_id"] && -n "${config["user_id"]}" ]]; then
			uid="${config["user_id"]}"
			if silent getent passwd "$uid"; then
				log e "Invalid UID $uid. Already in use."
				return 1
			fi

			useradd_args+=("--uid $uid")
		fi

		useradd ${useradd_args[@]} "$_LOGIN"
		log i "User $_LOGIN created"
	else
		log i "Found user '$_LOGIN'. Skipping user creation"

		# ensure home is created
		local home="/home/$_LOGIN"
		if [[ ! -d "$home" ]]; then
			mkdir -p "$home"
			cp -a /etc/skel/. "$home"
			chown -R "$_LOGIN:" "$home"
			chmod 755 "$home"

			log i "Created and populated $home"
		fi

	fi

}
