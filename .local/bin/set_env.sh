#! /bin/bash
# ./set_env.sh

if [ ! -z "$USER" ]; then
	user=`/usr/bin/whoami`
	echo "export USER=$user" >> ~/.zshrc
fi

if [ ! -z "$GROUP" ]; then
	group=`/usr/bin/id -gn $user`
	echo "export GROUP=$group" >> ~/.zshrc
fi

if [ ! -z "$MAIL" ]; then
	mail="$user@laplateforme.io"
	echo "MAIL=$mail" >> ~/.zshrc
fi

if [ ! -e "~/.vim/plugin" ]; then
	mkdir -p ~/.vim/plugin
fi

if [ ! -e "~/.vim/plugin/header.vim" ]; then
	cp plugin/header.vim ~/.vim/plugin/
fi

source ~/.zshrc
