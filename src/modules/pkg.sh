pkg_module() {
	log d "pkg module"
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
