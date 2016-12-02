# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export RAZOR_HOSTNAME=razor.stlpug.com
export HTTP_PORT=8150
export HTTPS_PORT=8151
export RAZOR_API=https://razor.stlpug.com:8151/api
