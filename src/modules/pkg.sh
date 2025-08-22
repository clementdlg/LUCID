pkg_module() {
	log d "${FUNCNAME} : entering"

	pkg_groups="${_CONFIG_INDEX[pkg]}"

	for group in ${pkg_groups}; do
		local group_fmt="$(value_formatter "${_CONFIG[pkg.${group}]}")"
		pkg_installer "$group_fmt"
	done

	log d "${FUNCNAME} : success"
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

	log i "Trying to install package(s) : $pkg_names"
	$_PKG_INSTALL $pkg_names 1>&2

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
