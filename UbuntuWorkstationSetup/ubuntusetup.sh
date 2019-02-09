#Ubuntu Workstation Setup
#Script to be used to install software used on my ubuntu workstations

#Update Machine
echo "Installing System Updates...(this will take awhile)"
sudo apt update -y &> /dev/null
sudo apt upgrade -y &> /dev/null
echo "Done"

#Install Software
##Software in Default Repos
echo "Installing Repo Software...(this will take awhile)"
sudo apt install gimp gnome-tweaks virt-manager filezilla vim gdebi keepassx xournal evolution evolution-ews audacity gnumeric vlc chromium-browser git calibre zenmap vim virtualbox vagrant ansible zsh powerline fonts-powerline zsh-theme-powerlevel9k zsh-syntax-highlighting -y &> /dev/null
echo "Done"
##Install Nextcloud Client
echo "Installing Nextcloud Client from PPA..."
sudo add-apt-repository ppa:nextcloud-devs/client -y &> /dev/null
sudo apt update &> /dev/null 
sudo apt install nextcloud-client -y &> /dev/null
echo "Done"
##Install Google Chrome
echo "Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb  &> /dev/null
sudo dpkg -i google-chrome-stable_current_amd64.deb &> /dev/null
rm google-chrome-stable_current_amd64.deb &> /dev/null
echo "Done"
##Install Snap Packages
echo "Installing Snap Packages..."
sudo snap install qownnotes &> /dev/null
sudo snap install --classic vscode &> /dev/null
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
echo "source /usr/share/powerlevel9k/powerlevel9k.zsh-theme" >> ~/.zshrc
##Add Syntax Highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
echo "Done"
#Install Pulse Secure VPN (deb file in git repo)
echo "Install Pulse Secure..."
sudo dpkg -i pulse-9.0R1.x86_64.deb &> /dev/null
sudo apt install libwebkitgtk-1.0-0 -y &> /dev/null
echo "Done"

##Still in progress - CURRENTLY NONE

