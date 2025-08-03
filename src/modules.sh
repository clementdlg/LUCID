fw_module() {
	local -n config="$1"
	echo "fw_module config keys  = ${!config[@]}"

}

# Description: clone a git repository and make it the new ~/.config
# 				old ~/.config is moved to ~/.config.old.<timestamp>
dotfiles_module() {
	local -n config="$1"
	echo "dotfiles_module config keys  = ${!config[@]}" # debug

	local required_keys=(
		"dotfiles_branch"
		"dotfiles_repo"
	)

	check_required_keys required_keys config

	branch="${config["dotfiles_branch"]}"
	url="${config["dotfiles_repo"]}"
	target="/home/$SUDO_USER/.config"
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
	echo "pkg_module config keys  = ${!config[@]}"


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
	echo "flatpak_module config keys  = ${!config[@]}"
}

pipx_module() {
	local -n config="$1"
	echo "pipx_module config keys  = ${!config[@]}"
}

repos_module() {
	local -n config="$1"
	echo "repos_module config keys  = ${!config[@]}"
}

libvirt_module() {
	local -n config="$1"
	echo "libvirt_module config keys  = ${!config[@]}"
}

systemd_module() {
	local -n config="$1"
	echo "systemd_module config keys  = ${!config[@]}"
}

user_module() {
	local -n config="$1"
	echo "user_module config keys  = ${!config[@]}"
}

disk_module() {
	local -n config="$1"
	echo "disk_module config keys  = ${!config[@]}"
}
