# config helper
parse_config() {
	local current_line=""
	local line_nr=0
	local has_warning=0
	seen_keys=()

	while IFS= read -r current_line; do
		line_nr=$(( line_nr + 1 ))

		local trimmed_line="$( echo "$current_line" | xargs)"

		# skip comments and blank lines
		if [[ "$trimmed_line" =~ ^# || -z "$trimmed_line" ]]; then
			continue;
		fi

		# check format
		if ! [[ "$trimmed_line" =~ ^[a-z][a-z_]+\ *=.*$ ]]; then
			log e "Config l${line_nr}: Invalid key/value pair"
			return 1
		fi

		local trimmed_key="$(echo "$trimmed_line" | cut -d= -f1 | xargs)"
		local trimmed_value="$(echo "$trimmed_line" | cut -d= -f2 | xargs)"

		# check for duplicate
		if is_in_array "$trimmed_key" "${seen_keys[@]}"; then
			log w "Config l${line_nr}: Found duplicate key '$trimmed_key'"
			has_warning=1
		else
			seen_keys+=("$trimmed_key")
		fi

		if [[ "$trimmed_value" == *"::"* || "$trimmed_value" == *":" ]]; then
			log w "Config l${line_nr}: Extra separator in value"
			has_warning=1
		fi

		_CONFIG["$trimmed_key"]="$trimmed_value"

	done < "$_CONFIG_FILE"

	(( has_warning == 00 )) && log i "Config is valid"
}

# config helper
set_buffer() {
	local prefix="$1"

	# empty buffer
	for key in "${!buffer[@]}"; do
		unset "buffer[$key]"
	done

	# keys that match the prefix are sent to the buffer 
	for key in "${!_CONFIG[@]}"; do
		if [[ "$key" == "$prefix"* ]]; then
			buffer["$key"]="${_CONFIG["$key"]}"
			unset "_CONFIG[$key]"
		fi
	done
}


# config helper
check_required_keys() {
	local -n keys_to_check="$1"
	local -n mod_config="$2"

	for item in "${keys_to_check[@]}"; do
		if ! [[ -v mod_config["$item"] ]]; then
			log e "Missing key '$item' from config file"
			return 1
		fi
	done
}
