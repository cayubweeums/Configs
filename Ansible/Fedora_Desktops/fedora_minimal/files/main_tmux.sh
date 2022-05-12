#!/bin/sh
tmux new-session -d
tmux split-window -h -p 63 'btop'
tmux -2 attach-session -d
