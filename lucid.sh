set -xeuo pipefail

err() {
	echo "ERROR : $1" 1>&2
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
	sudo dnf install --setopt=install_weak_deps=False -y \
		${firmware[@]} \
		${cli[@]} \
		${network[@]} \
		${desktop[@]} \
		${other_pkgs[@]} \
		${containers[@]}

	sudo systemctl set-default graphical.target
}

dotfiles() {
	rm -rf ~/.config/* ~/.bashrc
	git clone https://github.com/clementdlg/unidots
	cd unidots/
	stow -t ~ common
	stow -t ~/.config "$environement"
}

flatpak_setup() {
	flatpakremote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpakinstall -y --noninteractive ${flatpaks[@]}
}

nix() {
	curl -fsSL https://install.determinate.systems/nix | sh -s -- install
	source /etc/profile.d/nix.sh
	nix shell nixpkgs#home-manager
	home-manager switch
}

main() {
	source_cfg
	fedora_setup
	dotfiles
	flatpak_setup
	nix
}
