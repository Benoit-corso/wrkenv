#! /usr/bin/env bash

id=`id -un`
group=`id -gn`

if [ `id -u` -ne 0 ]; then
	echo "this script shoud be run as root."
	exit 1
fi

user_name="${USER}"
user_group="${GROUP}"

if [ -z "${user_name}" ] || [ -z "${user_group}" ]; then
	echo "failed to get your current username or group."
	echo "please start this command with USER={username} GROUP={group} $0"
fi

declare -a fontlist=("https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf" "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf" "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf" "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf")
declare -a packages=(ttf-mscorefonts-installer fonts-recommended zsh git curl wget vim ca-certificates dialog expect binutils file wget rpm2cpio cpio zstd jq)

# disable apt cdrom sources.
sed 's/^\(deb cdrom:.*\)$/#\1$/' /etc/apt/sources.list > /etc/apt/sources.list
# enable for current user NOPASSWD: for sudo
sudo sed -i '/^%sudo\\tALL=(ALL:ALL) ALL/a %'${user_group}'\tALL=(ALL:ALL) NOPASSWD:ALL' /etc/sudoers

mkdir -p /usr/share/fonts/truetype/nerdfonts

for font in ${fontlist[@]}; do
	wget $font -q --show-progress -P /usr/share/fonts/truetype/nerdfonts
done

apt update
apt install -y "${packages[@]}"

echo "Inside your current terminal, you should now change your font to \"MesloLGS NF\""
read -p "Please type any key when it's done."

echo "Great! now installing every plugins for your fresh shell..."

for user in ("${user_name} root"); do
	/usr/bin/expect<<EOD
spawn sudo -H -u $user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
expect "[Y/n]"
send -- "Y\r"
interact
EOD
	echo "for shell theme: pretending you're not chinese."
	sudo -H -u $user zsh -c '. ~/.zshrc; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k; git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions; git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting; git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use; git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat;'
	echo "Modifying default theme..."
	sudo -H -u $user zsh -c "sed 's/^plugins=(\(.*\))$/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)$/' ~/.zshrc > ~/.zshrc"
	sudo -H -u $user zsh -c "sed 's/^ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc > ~/.zshrc"
	echo "Now we'll starting shell theme configuration."
	echo "If you don't changed the font you'll not see special symbols."
	read -p "You can do it now. ready ? [any key]"
	sudo -H -u $user zsh
done

apt remove -y expect
