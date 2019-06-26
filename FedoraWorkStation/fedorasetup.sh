#Fedora Workstation Setup
#Script to be used to install software used on my Fedora workstations

#Setting Up Extra Repos
sudo dnf install fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

#Setup Snap Support in Fedora
sudo dnf install snapd
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install snap-store
echo "Done"

#Update Machine
echo "Installing System Updates...(this will take awhile)"
sudo dnf update -y &> /dev/null
echo "Done"

#Install Software
##Software in Repos
echo "Installing Repo Software...(this will take awhile)"
sudo dnf install google-chrome-stable gimp gnome-tweaks virt-manager filezilla keepassx xournal evolution evolution-ews audacity gnumeric vlc chromium git calibre nmap vim virtualbox openssh-askpass vagrant ansible zsh powerline powerline-fonts zsh-syntax-highlighting nextcloud-client -y &> /dev/null
echo "Done"

##Install Snap Packages
echo "Installing Snap Packages..."
sudo snap install qownnotes &> /dev/null
sudo snap install --classic code &> /dev/null
sudo snap install --classic powershell &> /dev/null
echo "Done"

#Customizations for ZSH
echo "Setting up ZSH..."
##Set ZSH to Default Shell for Current User
sudo usermod -s /usr/bin/zsh $(whoami) &> /dev/null
##Download oh-my-zsh Add-on for ZSH
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh &> /dev/null
##Copy the .zshrc template from oh-my-zsh to user's home
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &> /dev/null
##Enable PowerLevel9K theme
#echo "source /usr/share/powerlevel9k/powerlevel9k.zsh-theme" >> ~/.zshrc
##Add Syntax Highlighting
#echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
echo "Done"
#Install Pulse Secure VPN (deb file in git repo)
echo "Install Pulse Secure..."
sudo dpkg -i pulse-9.0R1.x86_64.deb &> /dev/null
sudo apt install libwebkitgtk-1.0-0 -y &> /dev/null
echo "Done"

##Still in progress - CURRENTLY NONE

