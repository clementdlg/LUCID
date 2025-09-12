# Description: clone a git repository and make it the new ~/.config
# old ~/.config is moved to ~/.config.old.<timestamp>
git-clone_module() {
	log d "${FUNCNAME} : entering"

	local repo_list="${_CONFIG_INDEX[git-clone]}"

	if [[ -z "$repo_list" ]]; then
		return 0
	fi

	local timestamp="$(date +%y-%m-%d-%H-%M-%S)"

	silent command -v git || pkg_installer "git"

	for repo in $repo_list; do
		safe_clone_repo "$repo"
	done

	# local target="/home/$_LOGIN/.config"

	log d "${FUNCNAME} : success"
}

safe_clone_repo() {
	if [[ -z "$1" ]]; then
		log e "Missing param #1 : repo name"
		return 1
	fi

	local repo="$1"

	# SETUP
	local k_path="git-clone.${repo}.path"
	local k_url="git-clone.${repo}.url"
	local k_branch="git-clone.${repo}.branch"
	local branch=""
	local required_keys=(
		"$k_path"
		"$k_url"
	)

	check_required_keys required_keys

	local path="${_CONFIG[$k_path]}"
	local url="${_CONFIG[$k_url]}"

	if ! check_repo_is_accessible "$url"; then
		log e "Invalid git repository url for '$repo'"
		return 1
	fi

	if [[ -v "_CONFIG[$k_branch]" ]]; then
		branch="${_CONFIG[$k_branch]}"

		if ! check_if_branch_exists "$url" "$branch"; then
			log e "Branch '$branch' does not exist for repo '$repo'"
			return 1
		fi
	else
		branch="$(get_repo_default_branch "$url")"
	fi

	# IDEMPOTENCY CHECKS
	if check_repo_already_cloned "$path" "$url" "$branch"; then
		log i "Repo '$repo' already cloned. skipping"
		return
	fi

	if [[ -d "$path" ]]; then
		log i "Directory at $path already exist. Performing a backup"
		rootless mv "$path" "$path.old.$timestamp"
	fi

	# ACTION
	# silent rootless git clone --branch="$branch" "$url" "$path"
	rootless git clone --branch="$branch" "$url" "$path"

	log i "Cloned branch $branch of repo '$repo' into $path"
}

check_repo_already_cloned() {
	if [[ -z $1 ]]; then
		log e "${FUNCNAME} Missing param #1 : target path"
		return 1
	fi

	if [[ -z $2 ]]; then
		log e "${FUNCNAME} Missing param #2 : repo url"
		return 1
	fi

	if [[ -z $3 ]]; then
		log e "${FUNCNAME} Missing param #3 : repo branch"
		return 1
	fi

	local target="$1"
	local url="$2"
	local branch="$3"

	if ! [[ -d "$target" ]]; then
		return 1
	fi

	if [[ "$(rootless git -C "$target" remote get-url origin)" == "$url" \
		&& "$(rootless git -C "$target" branch --show-current)" == "$branch" ]]; then
		return 0
	else
		return 1
	fi
}

check_repo_is_accessible() {
	if [[ -z "$1" ]]; then
		log e "Missing param #1 : repo url"
		return 1
	fi
	
	local url="$1"
	silent git -c credential.helper= -c core.askPass=true ls-remote "$url"
}

get_repo_default_branch() {
	if [[ -z "$1" ]]; then
		log e "Missing param #1 : repo url"
		return 1
	fi

	local ref="$(git ls-remote --symref "$1" HEAD 2>/dev/null | head -1 | xargs | cut '-d ' -f2)"
	basename "$ref"
}

check_if_branch_exists() {
	if [[ -z "$1" ]]; then
		log e "Missing param #1 : repo url"
		return 1
	fi

	if [[ -z "$2" ]]; then
		log e "Missing param #2 : repo branch"
		return 1
	fi

	local url="$1"
	local branch="$2"

	git ls-remote -b "$url" | awk '{ print $2 }' | sed 's/refs\/heads\///' | grep -qw "$branch"
}
