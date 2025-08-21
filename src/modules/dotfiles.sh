dotfiles_module() {
	log d "${FUNCNAME} : entering"

	# CHECKS
	silent command -v git || pkg_installer "git"

	local required_keys=(
		"dotfiles.repo"
	)

	check_required_keys required_keys

	# WRITE CONFIG ENTREE
	local timestamp="$(date +%y-%m-%d-%H-%M-%S)"
	local repo_name="dotfiles-${timestamp}"
	local k_url="git-clone.${repo_name}.url"
	local k_branch="git-clone.${repo_name}.branch"
	local k_path="git-clone.${repo_name}.path"

	_CONFIG[$k_url]="${_CONFIG[dotfiles.repo]}"
	_CONFIG[$k_path]="/home/${_LOGIN}/.config"
	
	if [[ -v _CONFIG[dotfiles.branch] ]]; then
		_CONFIG[$k_branch]="${_CONFIG[dotfiles.branch]}"
	fi

	# CALL REPO CLONE FUNC
	safe_clone_repo "$repo_name"

	# CLEAN CONFIG
	unset "_CONFIG[$k_url]"
	unset "_CONFIG[$k_path]"

	if [[ -v "_CONFIG[$k_branch]" ]]; then
		unset "_CONFIG[$k_branch]"
	fi

	log d "${FUNCNAME} : success"
}
