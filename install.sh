#!/bin/sh

### sudo password argument

echo -e "Testing sudo password ..."
echo $1 | sudo -S pwd > /dev/null

### OPTIONS AND VARIABLES ###

dotfilesrepo="https://github.com/hillenr14/.dotfiles.git"
progsfile="https://github.com/hillenr14/.dotfiles/raw/master/progs.csv"
aurhelper="yay"
repobranch="master"

### FUNCTIONS ###

if type xbps-install >/dev/null 2>&1; then
	installpkg(){ sudo xbps-install -y "$1" >/dev/null 2>&1 ;}
	grepseq="\"^[PGV]*,\""
elif type apt >/dev/null 2>&1; then
	installpkg(){ sudo apt-get install -y "$1" >/dev/null 2>&1 ;}
	grepseq="\"^[PGU]*,\""
else
	distro="arch"
	installpkg(){ sudo pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}
	uninstallpkg(){ sudo pacman --noconfirm -R "$1" >/dev/null 2>&1 ;}
	grepseq="\"^[PGA]*,\""
fi

error() { printf "ERROR:\\n%s\\n" "$1"; exit;}

refreshkeys() { \
	echo -e "Refreshing Arch Keyring...\n"
	echo sudo pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
	}

manualinstall() { # Installs $1 manually if not installed. Used only for AUR helper here.
	[ -f "/usr/bin/$1" ] || (
	echo -e "Installing \"$1\", an AUR helper...\n"
	cd /tmp || exit
	rm -rf /tmp/"$1"*
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
	tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
	cd "$1" &&
	makepkg --noconfirm -si >/dev/null 2>&1
	cd /tmp || return) ;}

maininstall() { # Installs all needed programs from main repo.
	echo "Installing \`$1\` ($n of $total). $1 $2"
	installpkg "$1"
	}

gitmakeinstall() {
	progname="$(basename "$1" .git)"
	dir="$repodir/$progname"
	echo "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2"
	sudo -u "$name" git clone --depth 1 "$1" "$dir" >/dev/null 2>&1 || { cd "$dir" || return ; sudo -u "$name" git pull --force origin master;}
	cd "$dir" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return ;}

aurinstall() { \
	echo "Installing \`$1\` ($n of $total) from the AUR. $1 $2"
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	$aurhelper -S --noconfirm "$1" >/dev/null 2>&1
	}

pipinstall() { \
	echo "Installing the Python package \`$1\` ($n of $total). $1 $2"
	command -v pip || installpkg python-pip >/dev/null 2>&1
	yes | pip install "$1"
	}

installationloop() { \
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' | eval grep "$grepseq" > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	aurinstalled=$(pacman -Qqm)
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"A") aurinstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
			*) maininstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;}
    echo -e "\n"

putgitrepo() { # Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts
	echo -e "Downloading and installing config files from $1 to $2...\n"
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2"
	chown -R "$name":wheel "$dir" "$2"
	sudo -u "$name" git clone --recursive -b "$branch" --depth 1 "$1" "$dir" >/dev/null 2>&1
	sudo -u "$name" cp -rfT "$dir" "$2"
	}

gitclone() {
	progname="$(basename "$1" .git)"
	if [[ -d "$progname" ]]
	then
		echo "Git repo \`$progname\` already cloned"
	else
		echo "Cloning \`$progname\` ($n of $total) via \`git\`"
		git clone "$1" >/dev/null 2>&1
	fi
	}

slink(){ \
	if [ -e $1 ] || [ -L $1 ]; then
		echo "Replacing $1 with link to $2"
		rm $1
		ln -s $2 $1
	elif [ ! -e $1 ]; then
		echo "Creating $1 link to $2"
		ln -s $2 $1
	fi
	}

### THE ACTUAL SCRIPT ###

# Refresh Arch keyrings.
# refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

# Update Arch
echo "Updating and Upgrading"
sudo pacman -Suyy >/dev/null 2>&1
echo "Installing \`basedevel\` and \`git\` for installing other software required for the installation of other programs."
installpkg curl
uninstallpkg fakeroot-tcp
installpkg base-devel
installpkg git
installpkg ntp

echo "Synchronizing system time to ensure successful and secure installation of software..."
ntpdate 0.us.pool.ntp.org >/dev/null 2>&1

[ "$distro" = arch ] && { \

	# Make pacman and yay colorful and adds eye candy on the progress bar because why not.
	grep "^Color" /etc/pacman.conf >/dev/null || sudo sed -i "s/^#Color$/Color/" /etc/pacman.conf
	grep "ILoveCandy" /etc/pacman.conf >/dev/null || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

	# Use all cores for compilation.
	sudo sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

	manualinstall $aurhelper || error "Failed to install AUR helper."
	}

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

cd ~
gitclone $dotfilesrepo

# Make zsh the default shell for the user.
sudo sed -i "s/^$name:\(.*\):\/bin\/.*/$name:\1:\/bin\/zsh/" /etc/passwd

# Creating links

mkdir -p ~/.local/bin
mkdir -p ~/.cache/zsh
touch ~/.cache/zsh/history
slink .config/nvim/init.vim ~/.dotfiles/nvim/init.vim
slink .zshrc .dotfiles/zsh/.zshrc
slink .zprofile .dotfiles/.zprofile
