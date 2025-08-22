# L.U.C.I.D
**Linux Universal Config-driven Idempotent Deployement**


## Description
- LUCID is a modular deployment engine designed to automate the setup of Linux workstations and servers in a safe, reproducible, and cross-distro manner.
- Its goal is to transform a fresh installation into a fully configured, production-ready system with a single, repeatable execution.
- LUCID is configurable : Nothing is hardcoded, the script will only act upon what is inside of the config. You can design the environment you want
- LUCID is universal : It supports RHEL-based distro, Debian-based distros and Arch based distros
- LUCID has no dependencies : 100% pure bash, run it on a barebone install. No Python required
- LUCID is safe : Each module checks system state before acting, ensuring repeated runs do not break or duplicate changes.
- LUCID is extensible : Every action is handled by specialized modules to create the system you want. You can easily contribute your own module to the project.

## Modules
- Modules can modify your system to get the desired state. Modules included are :
    - User management
    - Native Distro packages installation
    - Dotfile repository setup
    - Adding 3rd-party repositories
    - Flatpak packages installation 
    - Pipx packages installation 
    - Cargo packages installation 
    - NPM packages installation 
    - Systemd service management
    - Firewall ports and service management
    - Libvirt management
