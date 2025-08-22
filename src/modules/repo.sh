repo_module() {
	log d "${FUNCNAME} : entering"

	log d " index[repo] = ${_CONFIG_INDEX[repo]}"
	local distro="${_CONFIG_INDEX[repo]}"
	read -r -a distro_array <<< "$distro"

	if [[ "${#distro_array[@]}" != "1" ]]; then
		log e "Cannot add package repo from several distros"
		return 1
	fi

	local repo_names="${_CONFIG_INDEX[repo.$distro]}"

	for i_repo in $repo_names; do
		case "$distro" in
			fedora)
				fedora_dispatcher "$i_repo"
				;; 
			debian)
				add_debian_repo "$i_repo"
				;; 
			arch)
				add_arch_repo "$i_repo"
				;; 
			*)
				log e "Cannot add repository for distro '$distro'"
				return 1
				;; 
		esac
	done

	log d "${FUNCNAME} : success"
}

fedora_dispatcher() {
	log d "${FUNCNAME} : entering"

	if [[ -z "$1" ]]; then
		log e "${FUNCNAME} : Missing param #1 fedora repo type"
		return 1
	fi

	case "$1" in
		rpmfusion)
			add_rpmfusion_repo
			;;
		copr)
			add_copr_repo
			;;
		*)
			log e "Fedora repo type '$1' is unsupported"
			return 1
			;;
	esac

	log d "${FUNCNAME} : success"
}

add_rpmfusion_repo() {
	log d "${FUNCNAME} : entering"

	local key=("repo.fedora.rpmfusion")
	check_required_keys key

	local repos="$(value_formatter "${_CONFIG[$key]}")"

	for repo in $repos; do
		if [[ "$repo" != "free" && "$repo" != "nonfree" ]]; then
			log e "config : repo.fedora.rpmfusion : invalid repo '$repo'"
			return 1
		fi

		local rpmfusion="https://download1.rpmfusion.org/${repo}/fedora/rpmfusion-${repo}-release-$(rpm -E %fedora).noarch.rpm"

		if ! dnf list --installed | grep -qw "rpmfusion-${repo}-release.noarch"; then
			dnf install -y "$rpmfusion"
			log i "Added rpmfusion $repos"
		fi
	done

	log d "${FUNCNAME} : success"
}

add_copr_repo() {
	log d "${FUNCNAME} : entering"

	local repo_names="${_CONFIG_INDEX[repo.fedora.copr]}"

	for repo_name in $repo_names; do
		local k_user="repo.fedora.copr.${repo_name}.user"
		local k_project="repo.fedora.copr.${repo_name}.project"

		local keys=("$k_user"
			"$k_project"
		)

		check_required_keys keys

		local user="${_CONFIG[$k_user]}"
		local project="${_CONFIG[$k_project]}"

		if dnf copr list | grep -qw "copr.fedorainfracloud.org/$user/$project"; then
			continue
		fi

		local copr_url="https://copr.fedorainfracloud.org/api_3/project/?ownername=${user}&projectname=${project}"

		code="$(curl -s -o /dev/null -X 'GET' -w "%{http_code}" "$copr_url")"
		if (( code != 200 )); then
			log e "Invalid corp repo '$repo_name'"
			return 1
		fi

		dnf copr enable "$user/$project" -y 1>&2
		log i "Copr repo added : $user/$project"
	done

	log d "${FUNCNAME} : success"
}
