# Description: clone a git repository and make it the new ~/.config
# old ~/.config is moved to ~/.config.old.<timestamp>
dotfiles_module() {
	log d "dotfiles module"

	#### SETUP ####
	local -n config="$1"
	local required_keys=(
		"dotfiles_branch"
		"dotfiles_repo"
	)

	check_required_keys required_keys config

	silent command -v git || pkg_installer "git"

	local branch="${config["dotfiles_branch"]}"
	local fallback_branch="main"
	local url="${config["dotfiles_repo"]}"
	local target="/home/$_LOGIN/.config"
	local timestamp="$(date +%y-%m-%d-%H-%M-%S)"

	if [[ -z "$url" ]]; then
		log e "${required_keys[1]} cannot be empty"
		return 1
	fi

	if [[ -z "$branch" ]]; then
		branch="$fallback_branch"	
	fi

	#### IDEMPOTENCY CHECKS ####

	if check_repo_already_cloned "$target" "$url" "$branch"; then
		log i "Dotfiles repo already cloned. Skipping"
		return
	fi

	if [[ -d "$target" ]]; then
		log i "Directory at /home/$_LOGIN/.config already exist. Performing a backup"
		rootless mv "$target" "$target.old.$timestamp"
	fi

	#### ACTION ####
	silent rootless git clone --branch="$branch" "$url" "$target"

	log i "Cloned branch $branch of $url into $target"
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

	if [[ "$(rootless git -C "$target" remote get-url origin)" == "$url" && "$(rootless git -C "$target" branch --show-current)" == "$branch" ]]; then
		return 0
	else
		return 1
	fi
}
