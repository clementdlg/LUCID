fw_module() {
	local -n config="$1"
	echo "fw_module config keys  = ${!config[@]}"

}

dots_module() {
	local -n config="$1"
	echo "dots_module config keys  = ${!config[@]}"

}

pkg_module() {
	local -n config="$1"
	echo "pkg_module config keys  = ${!config[@]}"

}

