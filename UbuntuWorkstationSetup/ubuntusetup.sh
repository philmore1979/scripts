#Ubuntu Workstation Setup
#Last Updated : 11/12/2020
#Script to be used to install software used on my ubuntu workstations

##Setup Snapd
sudo apt install snapd -y

#Update Machine
echo "Installing System Updates...(this will take awhile)"
sudo apt update -y &> /dev/null
sudo apt upgrade -y &> /dev/null
echo "Done"

#Install Software
##Software in Default Repos
echo "Installing Repo Software...(this will take awhile)"
sudo apt install gimp gnome-tweaks virt-manager filezilla vim gdebi xournal evolution evolution-ews audacity gnumeric vlc git calibre nmap vim virtualbox ssh-askpass-gnome vagrant ansible zsh powerline fonts-powerline zsh-theme-powerlevel9k zsh-syntax-highlighting nextcloud-desktop -y &> /dev/null
echo "Done"

##Install Google Chrome
echo "Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb  &> /dev/null
sudo dpkg -i google-chrome-stable_current_amd64.deb &> /dev/null
rm google-chrome-stable_current_amd64.deb &> /dev/null
echo "Done"

##Install Edge Browser
echo "Installing Microsoft Edge"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo apt update -y
sudo apt install microsoft-edge-dev -y
rm microsoft.gpg
echo "Done"

##Install VSCode
wget https://go.microsoft.com/fwlink/?LinkID=760868  -O vscode.deb
sudo dpkg -i vscode.deb
rm vscode.debls
echo "Done"

##Install Brave Browser
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y

##Install Powershell
snap install powershell --classic
snap install mmex
snap install bitwarden

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

##TODO

##Script for VPN


