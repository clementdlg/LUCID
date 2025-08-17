pkg_module() {
	log d "pkg module"
	local -n config="$1"

	# TODO :Remove this and implement deps install for each module
	script_deps=(
		"git"
	)
	log i "Installing script dependencies"
	pkg_installer "${script_deps[@]}"

	for pkg_group in "${!config[@]}"; do
		local pkg_names="$(echo "${config["$pkg_group"]}" | tr ":" " ")"

		if [[ -z "$pkg_names" ]]; then
			continue
		fi

		pkg_installer "$pkg_names"
	done
}

pkg_installer() {
	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} Missing param #1 : package names"
		return 1
	fi

	local pkg_names="$1"

	if ! [[ -v "_PKG_INSTALL" ]]; then
		get_pkg_install_cmd
	fi

	log i "Installing package(s) : $pkg_names"
	$_PKG_INSTALL $pkg_names

}

get_pkg_install_cmd() {
	if silent command -v apt; then
		_PKG_INSTALL="apt install -y --no-install-recommends"
	elif silent command -v dnf; then
		_PKG_INSTALL="dnf install -y --setopt=install_weak_deps=False"
	elif silent command -v pacman; then
		_PKG_INSTALL="pacman -S --noconfirm"
	else
		log e "Unsupported package manager."
		return 1
	fi

	log d "pkg_install = $_PKG_INSTALL"
}
