#! /usr/bin/env bash

set -e

BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

cd $BASEDIR

LOGNAME="logfile-$(date +"%Y%m%d%H%M%S")"
touch $LOGNAME

message() {
    case "$1" in
        yellow)
            color="[33m"
            ;;
        green)
            color="[32m"
            ;;
    esac

    echo -e "\e$color" 
    msg="# $2 #"
    edge=$(echo "$msg" | sed 's/./#/g')
    echo -e "$edge\n$msg\n$edge" | tee -a $LOGNAME
    echo -e "\e[0m" 
}

sudo apt-get install pv

message yellow "Updating package repositories..."
sudo apt-get update -y | pv >> $LOGNAME

while read -r package; do
    if [ -z "$(dpkg -s "$package")" ] ; then
        message yellow "Installing $package..." 
        sudo apt-get install -y "$package" | pv >> $LOGNAME
    else
        message green "$package already installed!"
    fi
done < "$BASEDIR/packages.list"

message yellow "Installing oh-my-zsh..."a
if [ ! -d "$HOME/.oh-my-zsh/" ] ; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh" | pv >> $LOGNAME
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] ; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" | pv >> $LOGNAME
fi

message yellow "Installing pywal..."
pip3 install pywal | pv >> $LOGNAME

export PATH="${PATH}:${HOME}/.local/bin/"

message yellow "Installing Vundle for Vim..."
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ] ; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vima | pv >> $LOGNAME
else 
    cd "$HOME/.vim/bundle/Vundle.vim"
    git pull
    cd "$BASEDIR"
fi

(vim +PluginInstall +qall)

if [ -z "$(command -v polybar)" ] ; then
    message yellow "Installing Polybar..."
    if [ ! -d "$BASEDIR/polybar" ] ; then
        git clone --branch 3.2 --recursive https://github.com/jaagr/polybar "$BASEDIR/polybar" | pv >> $LOGNAME
    else
        cd "$BASEDIR/polybar"
        git pull
        cd "$BASEDIR"
    fi
    mkdir -p "$BASEDIR/polybar/build"
    cd "$BASEDIR/polybar/build"
    cmake "$BASEDIR/polybar" | pv >> $LOGNAME
    sudo make install | pv >> $LOGNAME
    cd "$BASEDIR"
else
    message green "Polybar already installed!"
fi

rm -rf "$BASEDIR/polybar"

if [ -z "$(command -v i3)" ] ; then
    message yellow "Installing i3-gaps..."
    if [ ! -d "$BASEDIR/i3-gaps" ] ; then
        git clone https://www.github.com/Airblader/i3 i3-gaps | pv >> $LOGNAME
    else
        cd "$BASEDIR/i3-gaps"
        git pull
        cd "$BASEDIR"
    fi
    cd "$BASEDIR/i3-gaps"
    autoreconf --force --install >> $LOGNAME
    rm -rf build/
    mkdir -p build && cd build/
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers | pv >> $LOGNAME
    make | pv >> $LOGNAME
    sudo make install | pv >> $LOGNAME
else
    message green "i3-gaps already installed!"
fi

rm -rf "$BASEDIR/i3-gaps"

cd "$BASEDIR"

if ! fc-list | grep -q 'Hack'  ; then
    message yellow "Installing fonts..."
    wget -O fonts.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Hack.zip | pv >> $LOGNAME
    mkdir fonts
    unzip fonts.zip -d ./fonts | pv >> $LOGNAME && rm fonts.zip 
    wait
    cp -R fonts/ ~/.local/share/fonts/
    rm -rf fonts/
    fc-cache -f -v | pv >> $LOGNAME
    wait
    fc-list | grep "Hack" |& tee -a $LOGNAME
else
    message green "fonts already instaleed!"
fi

message yellow "Applying config files..."

Files=(
    '.zshrc'
    '.vimrc'
    '.Xresources'
    '.config/i3'
    '.config/polybar'
    '.config/ranger'
    '.config/rofi'
    '.config/compton'
    '.config/mpd'
    '.config/ncmpcpp'
)

for i in "${Files[@]:0:3}"; do
    echo "rm -f $HOME/$i"
    rm -f "${HOME:?}/$i"
	echo "ln -srf $BASEDIR/$i $HOME/$i"
	ln -srf "$BASEDIR/$i" "$HOME/$i"
done

for i in "${Files[@]:3:7}"; do
    echo "rm -rf $HOME/$i"
    rm -rf "${HOME:?}/$i"
    echo "ln -srf $BASEDIR/$i $HOME/.config/"
    ln -srf "$BASEDIR/$i" "$HOME/.config/"
done

message yellow "Applying theme..."
wal -n -i "$BASEDIR/wallpapers/mountain.jpg" |& tee -a $LOGNAME

message yellow "Changing shell..."
chsh -s /bin/zsh

message green "FINISHED - Now log out and choose i3 environment"
