# config helper
parse_config() {
	local line=""
	local line_nr=0
	local has_warning=0
	seen_keys=()

	while IFS= read -r line; do
		line_nr=$(( line_nr + 1 ))

		# SANITIZE
		local trimmed_line="$(echo "$line" | xargs)"

		# skip comments and blank lines
		if [[ "$trimmed_line" =~ ^# || -z "$trimmed_line" ]]; then
			continue;
		fi

		# verify nr of k/v delimiter
		num_delimiter="$(echo "$trimmed_line" | tr -cd "=" | wc -c)"
		if [[ "$num_delimiter" != "1" ]]; then
			log e "Config l${line_nr}: Invalid key=value delimiter"
			return 1
		fi

		local key="$(echo "$trimmed_line" | cut -d= -f1 | xargs)"
		local value="$(echo "$trimmed_line" | cut -d= -f2 | xargs)"

		# VALIDATE KEY
		local k_token="[a-z0-9-]+"
		local k_regex="^${k_token}(\.${k_token}){1,4}$"
		if ! [[ "$key" =~ $k_token ]]; then
			log e "Config l${line_nr}: Invalid key format"
			return 1
		fi

		# check for key duplication
		if is_in_array "$key" "${seen_keys[@]}"; then
			log w "Config l${line_nr}: Found duplicate key '$key'"
			has_warning=1
		else
			seen_keys+=("$key")
		fi

		# VALIDATE VALUE
		if [[ -z "$value" ]]; then
			log w "Config l${line_nr}: Empty key, ignoring"
			continue
		fi

		local v_token="[a-zA-Z0-9/_.:-]+"
		local v_regex="^${v_token}(;${v_token})*$"

		if ! [[ "$value" =~ $v_regex ]]; then
			log e "Config l${line_nr}: Invalid value format"
			return 1
		fi
		
		_CONFIG["$key"]="$value"
		index_config_key "$key"

	done < "$_CONFIG_FILE"

	if (( has_warning == 00 )); then
		log i "Config : Valid"
	else
		log i "Config : Found warning but proceeding"
	fi
}

index_config_key() {
	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} : Missing param #1 : config key"
		return 1
	fi

	key_array=($(echo "$1" | tr "." " "))
	set -x

	for i in $(seq 0 $(( ${#key_array} - 2 ))); do
		new_key=""

		for j in $(seq 0 $i); do
			if [[ -z "$new_key" ]]; then
				new_key="${key_array[j]}"
			else
				new_key="${new_key}.${key_array[j]}"
			fi
		done

		_CONFIG_INDEX[${new_key}]="${key_array[i + 1]}"
		echo "hey"

	done
	set +x

}

