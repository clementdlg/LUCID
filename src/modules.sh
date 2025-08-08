# Description : Ensure user exists. Creates it if necessary.
# 				Ensure home dir exists, creates one if not.
user_module() {
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

		set -x
		useradd ${useradd_args[@]} "$_LOGIN"
		set +x
		log i "User $_LOGIN created"
	else
		log i "Found user '$_LOGIN'. Skipping user creation"

		# ensure home is created
		local home="/home/$_LOGIN"
		if [[ ! -d "$home" ]]; then
			set -x 
			mkdir -p "$home"
			cp -a /etc/skel/. "$home"
			chown -R "$_LOGIN:" "$home"
			chmod 755 "$home"

			set +x 
			log i "Created and populated $home"
		fi

	fi

}

# Description : Add user to groups if needed. Does not create any groups. Must run at the end of the script to ensure service groups are created by their respective packages
groups_module() {
	local -n config="$1"

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
	local required_keys=(
		"dotfiles_branch"
		"dotfiles_repo"
	)

	check_required_keys required_keys config

	branch="${config["dotfiles_branch"]}"
	url="${config["dotfiles_repo"]}"
	target="/home/$_LOGIN/.config"
	timestamp="$(date +%y-%m-%d-%H-%M-%S)"

	if [[ -z "$url" ]]; then
		log e "${required_keys[1]} cannot be empty"
		return 1
	fi

	# fallback : git branch
	if [[ -z "$branch" ]]; then
		branch="main"	
	fi

	is_installed git

	set -x

	# idempotency check
	if [[ -d "$target" ]]; then
		if [[ "$(git -C "$target" remote get-url origin)" == "$url" && "$(git -C "$target" branch --show-current)" == "$branch" ]]; then
			log i "Dotfiles repo already cloned. Skipping"
		else
			log i "Directory at /home/$_LOGIN/.config already exist. Doing a backup"
			rootless mv "$target" "$target.old.$timestamp"
		fi
	fi

	silent rootless git clone --branch="$branch" "$url" "$target"

	set +x
	log i "Cloned branch $branch of $url into $target"
}

pkg_module() {
	local -n config="$1"

	if silent command -v apt; then
		pkg_install="apt install -y --no-install-recommends"
	elif silent command -v dnf; then
		pkg_install="dnf install -y --setopt=install_weak_deps=False"
	elif silent command -v pacman; then
		pkg_install="pacman -S --noconfirm"
	else
		log e "Unsupported package manager."
	fi

	script_deps=(
		"git"
		"which"
	)

	log d "pkg_install = $pkg_install"
	log i "Installing script dependencies"

	$pkg_install "${script_deps[@]}"

	for pkg_group in "${!config[@]}"; do
		local pkg_names="$(echo "${config["$pkg_group"]}" | tr ":" " ")"
		log i "Installing package group ${pkg_group/pkg_/}"

		$pkg_install $pkg_names
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
