set -xeuo pipefail

err() {
	echo "ERROR : $1" 1>&2
}

as_user() {
	su "$user" -c "$1"
}

check_root() {
	if [[ "$EUID" != "0" ]]; then
		err "Run this script as root"
		exit 1
	fi
}

source_cfg() {
	if [ -f ./config.sh ]; then
		source ./config.sh
	elif [ -v "$LUCID_CFG" ]; then
		source "$LUCID_CFG"
	else
		err "Could not locate config file. Try to set LUCID_CFG variable"
	fi
}

fedora_setup() {
	dnf install --setopt=install_weak_deps=False -y \
		${firmware[@]} \
		${cli[@]} \
		${network[@]} \
		${desktop[@]} \
		${other_pkgs[@]} \
		${containers[@]}

	systemctl set-default graphical.target
}

dotfiles() {
	local repo="$(basename "$dotfiles")"
	local path="~/.local/share/${repo}"

	as_user "\
		rm -rf ~/.config/* ~/.bashrc ${path} &&\
		git clone $dotfiles ${path} &&\
		cd ${path} &&\
		stow -t ~ common &&\
		stow -t ~/.config $environment"
}

flatpak_setup() {
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub -y --noninteractive ${flatpaks[@]}
}

nix() {
	curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm

	as_user "source /etc/profile.d/nix.sh && \
		nix run nixpkgs#home-manager -- init --switch"
}

main() {
	check_root
	source_cfg
	fedora_setup
	dotfiles
	flatpak_setup
	nix
}

time main "$@"
