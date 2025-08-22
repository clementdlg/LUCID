flatpak_module() {
	log d "${FUNCNAME} : entering"

	keys=("flatpak.packages")
	check_required_keys keys

	silent command -v flatpak || pkg_installer flatpak

	flathub_url="https://dl.flathub.org/repo/flathub.flatpakrepo"
	flatpak remote-add --if-not-exists flathub "$flathub_url"

	flatpak_list="$(echo "${_CONFIG[flatpak.packages]}" | tr ";" " ")"

	log i "Installing flatpaks : $flatpak_list"
	if ! flatpak install -y --noninteractive ${flatpak_list}; then
		log e "${FUNCNAME} : Invalid package name among list"
		return 1
	fi

	log d "${FUNCNAME} : success"
}
