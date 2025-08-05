# Description : create user if needed and add it to specified groups
user_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
	
	local required_keys=("user_login")

	check_required_keys required_keys config
	_LOGIN="${config["user_login"]}"

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

		set -x
		useradd ${useradd_args[@]} "$_LOGIN"
		set +x
	else
		log i "Found user '$_LOGIN'. Not creating a user"
	fi

}

groups_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"

	# add groups
	if [[ ! -v config["groups"] || -z "${config["groups"]}" ]]; then
		return
	fi

	local groups_str="$(echo "${config["groups"]}" | tr ":" " ")"

	local groups_changed=0

	for grp in $groups_str; do
		if ! id -nG "$_LOGIN" | grep -qw "$grp"; then
			set -x
			usermod -aG "$grp" "$_LOGIN"
			groups_changed=1
			set +x
		fi
	done

	if (( groups_changed )); then
		log i "User $_LOGIN have been added to groups"
	else
		log i "User $_LOGIN was already member of all requested groups"
	fi

}

# Description: clone a git repository and make it the new ~/.config
# 				old ~/.config is moved to ~/.config.old.<timestamp>
dotfiles_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}" # debug

	local required_keys=(
		"dotfiles_branch"
		"dotfiles_repo"
	)

	check_required_keys required_keys config

	branch="${config["dotfiles_branch"]}"
	url="${config["dotfiles_repo"]}"
	target="/home/$SUDO_USER/.config" # TODO:: replace sudo_user by my own sanitized user variable
	timestamp="$(date +%y-%m-%d-%H-%M-%S)"

	if [[ -z "$url" ]]; then
		log e "${required_keys[1]} cannot be empty"
		return 1
	fi

	url="https://github.com/${url}.git"

	# fallback : git branch
	if [[ -z "$branch" ]]; then
		branch="main"	
	fi

	is_installed git

	if [[ -d "$target" ]]; then
		rootless mv "$target" "$target.old.$timestamp"
	fi

	silent rootless git clone --branch="$branch" "$url" "$target"

	log i "Cloned branch $branch of $url into $target"
}

pkg_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"


	for pkg_group in "${!config[@]}"; do
		local pkg_names="$(echo "${config["$pkg_group"]}" | tr ":" " ")"
		log i "Installing package group ${pkg_group/pkg_/}"
		log d "installing '$pkg_names'"

		do_weak_deps="True"
		dnf install -y --setopt=install_weak_deps=${do_weak_deps} $pkg_names
	done
}

flatpak_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

pipx_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

repos_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

libvirt_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

systemd_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

disk_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

fw_module() {
	local -n config="$1"
	echo "${FUNCNAME} config keys  = ${!config[@]}"
}

