# used for loging
readonly green="\e[32m"
readonly yellow="\e[33m"
readonly red="\e[31m"
readonly purple="\033[95m"
readonly reset="\e[0m"

log() {
	local msg="$2"
	[[ ! -z "$msg" ]]

	local timestamp="[$(date +%H:%M:%S)]"

	local label=""
	local color=""
	case "$1" in
		e) label="[ERROR]" ; color="$red" ;;
		w) label="[WARNING]" ; color="$yellow" ;;
		d) label="[DEBUG]" ; color="$purple" ;;
		i) label="[INFO]" ; color="$green" ;;
	esac

	local log="$timestamp$color$label$reset $msg "
	echo -e "$log"

	log="$timestamp$label $msg "

	# if [[ -f ${_LOGFILE} ]]; then
	# 	echo "$log" >> ${_LOGFILE}
	# fi
}

usage() {
		cat <<EOF
NAME : arch-deploy
SYNOPSIS :
	arch-deploy [--config <CONFIG> ] [--help]

DESCRIPTION
	Deploy and configure any customized linux environment.

	--help
		display this screen

	--config <CONFIG>
		Set the config file to use (required)

	-c, --check
		Check the config file for valid format

AUTHOR
	Clément de la Genière
	2025
EOF
}

silent() {
	"$@" &>/dev/null
}

rootless() {
	sudo -u "$_LOGIN" "$@"
}

check_privileges() {
	if [[ $EUID -ne 0 ]]; then
		log e "Run this script using sudo"
		return 1
	fi
}

is_in_array() {
	local query="$1"
	shift
	read -r -a array <<< "$@"

	echo "${array[@]}" | grep -qw -- "$query"
}

# arg parsing : will be replaced later
get_next_arg() {
	query="$1"

	for ((i = 0; i < ${#_ARGS[@]} - 1; i++)); do
		if [[ "${_ARGS[$i]}" == "$query" ]]; then
			echo "${_ARGS[$i + 1]}"
			return
		fi
	done
}

# arg parsing : will be replaced later
get_config() {
	# get config
	if ! is_in_array "--config" "${_ARGS[@]}"; then
		log e "You must provide a config using --config"
		exit 1
	fi

	_CONFIG_FILE="$(get_next_arg "--config")"

	if ! [[ -f "$_CONFIG_FILE" ]]; then 
		log e "Not a config file : '$_CONFIG_FILE'"
		exit 1
	fi

	log i "Found config file '$_CONFIG_FILE'"
}

check_required_keys() {
	if [[ -z "$1" ]]; then 
		log e "${FUNCNAME} : Missing param #1 : required keys array"
		return 1
	fi

	local -n keys="$1"

	for key in "${keys[@]}"; do
		if ! [[ -v _CONFIG[$key] ]]; then
			log e "Missing config param '$key'"
			return 1
		fi
	done
}

value_formatter() {
	if [[ -z "$1" ]]; then
		log e "Missing param #1 : config value"
	fi
	echo "$1" | tr ";" " "
}
