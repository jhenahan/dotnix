#!/bin/bash
SESSION=$USER

tmux -2 new-session -d -s $SESSION

tmux new-window -t $SESSION:1 -n 'Stuff'
tmux split-window -h
tmux split-window -v
tmux set-window-option synchronize-panes on

# Attach to session
tmux -2 attach-session -t $SESSION
