# Description: clone a git repository and make it the new ~/.config
# old ~/.config is moved to ~/.config.old.<timestamp>
dotfiles_module() {
	log d "dotfiles module"

	local -n config="$1"
	local required_keys=(
		"dotfiles_branch"
		"dotfiles_repo"
	)

	check_required_keys required_keys config

	branch="${config["dotfiles_branch"]}"
	url="${config["dotfiles_repo"]}"
	target="/home/$_LOGIN/.config"
	timestamp="$(date +%y-%m-%d-%H-%M-%S)"

	if [[ -z "$url" ]]; then
		log e "${required_keys[1]} cannot be empty"
		return 1
	fi

	# fallback : git branch
	if [[ -z "$branch" ]]; then
		branch="main"	
	fi

	is_installed git


	# idempotency check
	if [[ -d "$target" ]]; then
		if [[ "$(git -C "$target" remote get-url origin)" == "$url" && "$(git -C "$target" branch --show-current)" == "$branch" ]]; then
			log i "Dotfiles repo already cloned. Skipping"
			return
		else
			log i "Directory at /home/$_LOGIN/.config already exist. Performing a backup"
			rootless mv "$target" "$target.old.$timestamp"
		fi
	fi

	silent rootless git clone --branch="$branch" "$url" "$target"

	log i "Cloned branch $branch of $url into $target"
}

