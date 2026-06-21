# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

## USER SETTING

# Set prompt with user, host, and working directory
PS1='[\u@\h \W]\$ '

# Wrap with OSC 133 markers for tmux copy-mode prompt navigation (J/K) 
export PS1='\[\033]133;A\033\\\]'"$PS1"'\[\033]133;B\033\\\]'

# use vi-mode
set -o vi

# alias
alias vim='nvim'
alias as='ls'

