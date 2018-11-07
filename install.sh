#! /usr/bin/env bash

BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

set -e

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
    edge=$(echo $msg | sed 's/./#/g')
    echo -e "$edge\n$msg\n$edge"
    echo -e "\e[0m"
}

message yellow "Updating package repositories..."
sudo apt update -y

cat $BASEDIR/packages.list | while read package; do
    if [ -z "$(dpkg -s $package)" ] ; then
        message yellow "Installing $package..." 
        sudo apt install -y $package
    else
        message green "$package already installed!"
    fi
done

message yellow "Installing oh-my-zsh..."a
if [ ! -d "$HOME/.oh-my-zsh/" ] ; then
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

echo "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] ; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

message yellow "Installing pywal..."
pip3 install pywal

message yellow "Installing Vundle for Vim..."
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ] ; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else 
    cd $HOME/.vim/bundle/Vundle.vim
    git pull
    cd $BASEDIR
fi

vim +PluginInstall +qall

if [ -z "$(command -v polybar)" ] ; then
    message yellow "Installing Polybar..."
    if [ ! -d "$BASEDIR/polybar" ] ; then
        git clone --branch 3.2 --recursive https://github.com/jaagr/polybar $BASEDIR/polybar
    else
        cd $BASEDIR/polybar
        git pull
        cd $BASEDIR
    fi
    mkdir -p $BASEDIR/polybar/build
    cd $BASEDIR/polybar/build
    cmake $BASEDIR/polybar
    sudo make install
    cd $BASEDIR
else
    message green "Polybar already installed!"
fi

rm -rf $BASEDIR/polybar

if [ -z "$(command -v i3)" ] ; then
    message yellow "Installing i3-gaps..."
    if [ ! -d "$BASEDIR/i3-gaps" ] ; then
        git clone https://www.github.com/Airblader/i3 i3-gaps
    else
        cd $BASEDIR/i3-gaps
        git pull
        cd $BASEDIR
    fi
    cd $BASEDIR/i3-gaps
    autoreconf --force --install
    rm -rf build/
    mkdir -p build && cd build/
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
    make
    sudo make install
else
    message green "i3-gaps already installed!"
fi

rm -rf $BASEDIR/i3-gaps

cd $BASEDIR

if [ -z "$(fc-list | grep "Hack Nerd Font")" ] ; then
    message yellow "Installing fonts..."
    wget -O fonts.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
    unzip fonts.zip && rm fonts.zip
    cp -R ttf/ ~/.local/share/fonts/
    rm -rf ttf/
    fc-cache -f -v
    fc-list } grep "Hack"
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
    rm -f $HOME/$i
	echo "ln -srf $BASEDIR/$i $HOME/$i"
	ln -srf $BASEDIR/$i $HOME/$i
done

for i in "${Files[@]:3:7}"; do
    echo "rm -rf $HOME/$i"
    rm -rf $HOME/$i
    echo "ln -srf $BASEDIR/$i $HOME/.config/"
    ln -srf $BASEDIR/$i $HOME/.config/
done

message yellow "Applying theme..."
wal -n -a "93" -i "$BASEDIR/outrun.png"

message green "FINISHED - Now log out and choose i3 environment"
