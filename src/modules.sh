fw_module() {
	local -n config="$1"
	echo "fw_module config keys  = ${!config[@]}"

}

dotfiles_module() {
	local -n config="$1"
	echo "dotfiles_module config keys  = ${!config[@]}"

}

pkg_module() {
	local -n config="$1"
	echo "pkg_module config keys  = ${!config[@]}"

}

