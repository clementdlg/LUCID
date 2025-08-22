flatpak_module() {
	log d "${FUNCNAME} : entering"

	if ! [[ -v _CONFIG[flatpak.packages]} ]]; then
		return
	fi

	silent command -v flatpak || pkg_installer flatpak

	flathub_url="https://dl.flathub.org/repo/flathub.flatpakrepo"
	flatpak remote-add --if-not-exists flathub 

	flatpak_list="$(echo "${_CONFIG[flatpak.packages]}" | tr ";" " ")"

	log i "Installing flatpaks : $flatpak_list"
	flatpak install -y --noninteractive ${flatpak_list}

	log d "${FUNCNAME} : success"
}
