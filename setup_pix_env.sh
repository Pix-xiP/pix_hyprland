#!/bin/bash

set -e # Exit on error

LOG="pix_install.log"

echo "Running quick bootstrap..."
# For some reason arch gum doesn't come with log -_-
sudo pacman -Sy gum --noconfirm
# May need to do this method..
# sudo pacman -Sy git go --noconfirm
# git clone https://github.com/charbracelet/gum.git
# cd gum || return
# go build
# sudo cp ./gum /usr/bin
# cd .. || return

if ! command -v gum log; then
	echo "Uncomment the extended bootstrap"
	exit 1
fi

p() {
	gum log -t kitchen -s -l none "$1"
}

info() {
	gum log -t kitchen -s -l info "$1"
}

success() {
	gum log -t kitchen -s -l info --prefix="SUCCESS" "$1"
}

warn() {
	gum log -t kitchen -s -l warn "$1"
}

error() {
	gum log -t kitchen -s -l error "$1"
}

fatal() {
	gum log -t kitchen -s -l fatal "$1"
	exit 1
}

# # Easy Colour printing!
# SUCCUSS="$(tput setaf 2)[S]:$(tput sgr0)"
# ERROR="$(tput setaf 1)[!]:$(tput sgr0)"
# INFO="$(tput setaf 4)[+]:$(tput sgr0)"
# WARN="$(tput setaf 3)[W]:$(tput sgr0)"
# INPUT="$(tput setaf 6)[>]:$(tput sgr0)"
#
# info() {
# 	printf "%s%s%s\n" "$INFO" "$1" "$NC"
# }
#
# success() {
# 	printf "%s%s%s\n" "$SUCCUSS" "$1" "$NC"
# }
#
# warn() {
# 	printf "%s%s%s\n" "$WARN" "$1" "$NC"
# }
#
# error() {
# 	printf "%s%s%s\n" "$ERROR" "$1" "$NC" >&2
# }

info "Running Pix's Arch Linux Hyprland and Development Environment Script\n"
sleep 1
warn "Please remember to backup your files if this isn't a fresh install! " \
	"\nThis script will pave over your config files\n"
sleep 1
warn "Some commands require you to enter a password to execute, you may need " \
	"to baby sit this script.\n"
warn "CTRL C or CTRL Q can quit this script if you need to!\n"
sleep 1

HAS_YAY=/sbin/yay

if [ -f "$HAS_YAY" ]; then
	info "'yay' was located, using it to install.\n"
else
	warn "Unable to locate 'yay' \n"
	p "Would you like to install?"
	USER_IN=$(gum input --placeholder "[Y/n]")
	if [[ $USER_IN =~ ^[Nn]$ ]]; then
		error "An AUR helper is required for this script, feel free to update to " \
			"your AUR Helper of choice. Now exiting\n"
		exit 1
	else
		info "Installing YAY"
		git clone https://aur.archlinux.org/yay.git | tree -a "$LOG"
		cd yay
		makepkg -si --noconfirm 2>&1 | tee -a "$LOG"
		cd ..
	fi
	# Update System now.
	info "Updating system to avoid issues"
	yay -Sy archlinux-keyring --noconfirm 2>&1 | tee -a $LOG
	yay -Syu --noconfirm 2>&1 | tee -a $LOG
fi
USER_IN=""

### Install Packages ###
p "Would you like to install packages?"
USER_IN=$(gum input --placeholder "[Y/n]")
if [[ $USER_IN =~ ^[Nn]$ ]]; then
	warn "No packages installed. Ending Script"
	exit 1
else

	## Use Midori Browser but download from the side direct, the AUR is a full major version behind.
	#
	#
	# Need the Git version specifically.
	# grimblast - Screenshot Utility
	# SDDM - Simple Display Manager
	# Hyprpicker - Pick colours from something!
	# Waybar-Hyprland - Waybar but for Hyprland :>
	GIT_PKGS="grimblast-git sddm-git hyprpicker-git waybar-hyprland-git"

	# Specific to Hyprland Programs
	# Hyprland - Window Manager.
	# Hyprpaper - Wallpapers for Hyprland.
	# wl-clipboard - Clipboard manager for Wayland.
	# wf-recorder -
	# Rofi - GUI Launcher program
	# wlogout - Wayland logout.
	# Swaylock-effects - Make swaylock look pretty <3
	# dunst - Notification System :D
	# Swappy - Screenshot / basic picture editor.
	HYPR_PKGS="hyprland hyprpaper wl-clipboard wf-recorder rofi wlogout swaylock-effects dunst swappy"

	FONT_PKGS="ttf-fira-code ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font otf-sora " \
		"noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd adobe-source-code-pro-fonts"

	# General APPS I like to use :>
	# Discord - #TalkingToPeople
	# btop/htop - Fancy looking top
	APP_PKGS="discord wg-look-bin qt5ct btop gvfs ffmpegthumbs swww mousepad mpv playerctl pamixer " \
		" noise-suppression-for-voice polkit-gnome ffmpeg viewnior pavucontrol thunar ffmpegthumbnailer" \
		" tumbler thunar-archive-plugin xdg-user-dirs"
	#
	THEME_PKGS="nordic-theme papirus-icon-theme starship tree-sitter-cli tree-sitter"

	# Terminal Packages for Dev and general everything else.
	# See the Toolset.MD for information.
	TERM_PKGS="alacritty axel bat bear btop croc curl duf dust eza fastmod fd fish fzf glow go go-task gum htop jq" \
		" jujutsu lazygit less lua meson navi neofetch neovim pixz procs ripgrep rm-improved rsync sd tealdeer" \
		" tokei trippy unzip vim wezterm wget zerotier-one zoxide pacman-contrib"

	if ! yay -S --noconfirm "$GIT_PKGS" "$HYPR_PKGS" "$FONT_PKGS" \
		"$APP_PKGS" "$TERM_PKGS" "$THEME_PKGS" 2>&1 | tee -a "$LOG"; then
		error "Failed to install additional packages - please check the install log\n"
		exit 1
	fi
	xdg-user-dirs-update
	success "All packages installed successfully!"
fi
USER_IN=""
### Config Files ###

# p "Would you like to copy config files?"
# USER_IN=$(gum input --placeholder "[Y/n]")
# if [[ $USER_IN =~ ^[Nn]$ ]]; then
# 	info "Config files not installed"
# else

p "====================="
p "Whad would you like to do with config files?"
p "====================="
USER_IN=$(gum choose "Copy" "Symlink" "Skip")
if [[ $USER_IN == "Skip" ]]; then
	info "Skipping configuration files"
else
	if [[ $USER_IN == "Copy" ]]; then
		info "Copying configuration files into .config"
		cp -r pixconfig/dunst ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/fish ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/hypr ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/nvim ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/pipewire ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/rofi ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/swaylock ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/waybar ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/wezterm ~/.config/ 2>&1 | tee -a $LOG
		cp -r pixconfig/wlogout ~/.config/ 2>&1 | tee -a $LOG
	elif [[ $USER_IN == "Symlink" ]]; then
		## Experiment with just doing a symlink?
		# SYMLINK EXPERIMENT
		info "Symlinking config files"
		ln -b -n pixconfig/dunst ~/.config/dunst
		ln -b -n pixconfig/fish ~/.config/fish 2>&1 | tee -a $LOG
		ln -b -n pixconfig/hypr ~/.config/hypr 2>&1 | tee -a $LOG
		ln -b -n pixconfig/nvim ~/.config/nvim 2>&1 | tee -a $LOG
		ln -b -n pixconfig/pipewire ~/.config/pipewire 2>&1 | tee -a $LOG
		ln -b -n pixconfig/rofi ~/.config/rofi 2>&1 | tee -a $LOG
		ln -b -n pixconfig/swaylock ~/.config/swaylock 2>&1 | tee -a $LOG
		ln -b -n pixconfig/waybar ~/.config/waybar 2>&1 | tee -a $LOG
		ln -b -n pixconfig/wezterm ~/.config/wezterm 2>&1 | tee -a $LOG
		ln -b -n pixconfig/wlogout ~/.config/wlogout 2>&1 | tee -a $LOG
	fi
	# Set some files as executable!
	chmod +x ~/.config/hypr/xdg-portal-hyprland
	chmod +x ~/.config/waybar/scripts/waybar-wttr.py
fi

### Fonts for Waybar! ###
mkdir -p ./waybar-setup/nerdfonts
cd ./waybar-setup || return
axel -n 4 https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.1/CascadiaCode.zip
unzip '*.zip' -d ./nerdfonts
rm -rf ./*.zip
sudo cp -R ./nerdfonts/ /usr/share/fonts/

fc-cache -rv

USER_IN=""
p "Would you like to enable SDDM autologin?"
USER_IN=$(gum input --placeholder "[Y/n]")
if [[ $USER_IN =~ ^[nN]$ ]]; then
	info "Not enabling auto login!"
else
	LOC="/etc/sddm.conf"
	info "Adding the following to $LOC"
	echo -e "[Autologin]\nUser = $(whoami)\nSession=hyprland" | sudo tee -a $LOC
	info "Enabling SDDM service..."
	sudo systemctl enable sddm
	sleep 3
fi
USER_IN=""

### Bluetooth ###
p "Optional! - Would you like to install bluetooth packages?"
USER_IN=$(gum input --placeholder "[y/N]")
if [[ $USER_IN =~ ^[yY]$ ]]; then
	info "Instaling Bluetooth Packages!..."
	BLUE_PKG="bluez bluez-utils blueman"
	if ! yay -S --noconfirm "$BLUE_PKG" 2>&1 | tee -a "$LOG"; then
		error "Failed to install bluetooth packages - please check the install log."
	else
		sudo systemctl enable --now bluetooth.service
		sleep 3
	fi
else
	info "Not installing bluetooth!"
fi

success "Installation Completed!"
USER_IN=""
p "Would you like to start Hyprland now?"
USER_IN=$(gum input --placeholder "[Y/n]")
if [[ $USER_IN =~ ^[Nn]$ ]]; then
	info "Finishing..."
	exit 0
else
	if command -v Hyprland >/dev/null; then
		exec Hyprland
	else
		error "Hyprland not found, please make sure Hyprland is installed after all this."
		exit 1
	fi
fi
