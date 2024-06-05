#!/bin/bash

# Default configuration
default_session_name="my_session"
log_directory="logs/"
layout_directory="$HOME/.txm/layouts"
config_file="$HOME/.txm/config"

# Function to load configuration
load_config() {
  if [ -f "$config_file" ]; then
    source "$config_file"
  fi
}

# Function to set default options
set_option() {
  option=$1
  value=$2
  tmux set-option -g "$option" "$value"
  echo "Set option $option to $value"
}

# Function to create a new session
new_session() {
  session_name=$1
  if [ -z "$session_name" ]; then
    session_name=$default_session_name
  fi
  tmux new-session -d -s "$session_name"
  echo "Created new session: $session_name"
}

# Function to list all sessions
list_sessions() {
  tmux list-sessions
}

# Function to attach to a session
attach_session() {
  session_name=$1
  tmux attach-session -t "$session_name"
}

# Function to detach from a session
detach_session() {
  tmux detach-client
}

# Function to rename a session
rename_session() {
  old_name=$1
  new_name=$2
  tmux rename-session -t "$old_name" "$new_name"
  echo "Renamed session $old_name to $new_name"
}

# Function to kill a session
kill_session() {
  session_name=$1
  tmux kill-session -t "$session_name"
  echo "Killed session: $session_name"
}

# Function to switch between sessions
switch_session() {
  session_name=$1
  tmux switch-client -t "$session_name"
}

# Function to create a new window
new_window() {
  window_name=$1
  tmux new-window -n "$window_name"
  echo "Created new window: $window_name"
}

# Function to rename a window
rename_window() {
  old_name=$1
  new_name=$2
  tmux rename-window -t "$old_name" "$new_name"
  echo "Renamed window $old_name to $new_name"
}

# Function to close a window
close_window() {
  window_name=$1
  tmux kill-window -t "$window_name"
  echo "Closed window: $window_name"
}

# Function to switch between windows
switch_window() {
  window_name=$1
  tmux select-window -t "$window_name"
}

# Function to split pane vertically
vsplit_pane() {
  tmux split-window -v
}

# Function to split pane horizontally
hsplit_pane() {
  tmux split-window -h
}

# Function to navigate between panes
navigate_panes() {
  direction=$1
  case $direction in
    U)
      tmux select-pane -U
      ;;
    D)
      tmux select-pane -D
      ;;
    L)
      tmux select-pane -L
      ;;
    R)
      tmux select-pane -R
      ;;
    *)
      echo "Invalid direction. Use U, D, L, or R."
      ;;
  esac
}

# Function to resize panes
resize_pane() {
  direction=$1
  amount=$2
  case $direction in
    U)
      tmux resize-pane -U "$amount"
      ;;
    D)
      tmux resize-pane -D "$amount"
      ;;
    L)
      tmux resize-pane -L "$amount"
      ;;
    R)
      tmux resize-pane -R "$amount"
      ;;
    *)
      echo "Invalid direction. Use U, D, L, or R."
      ;;
  esac
}

# Function to close a pane
close_pane() {
  tmux kill-pane
  echo "Closed the current pane"
}

# Function to zoom a pane
zoom_pane() {
  tmux resize-pane -Z
}

# Function to execute a command in the current pane
execute_command() {
  command=$1
  tmux send-keys "$command" C-m
}

# Function to save session layout
save_layout() {
  layout_name=$1
  mkdir -p "$layout_directory"
  tmux display-message -p "#{window_layout}" > "$layout_directory/$layout_name.layout"
  echo "Saved layout as $layout_name"
}

# Function to restore session layout
restore_layout() {
  layout_name=$1
  if [ ! -f "$layout_directory/$layout_name.layout" ]; then
    echo "Layout $layout_name not found"
    return
  fi
  tmux select-layout "$(cat "$layout_directory/$layout_name.layout")"
  echo "Restored layout $layout_name"
}

# Function to execute a script in a specific pane
execute_script() {
  pane_id=$1
  script_file=$2
  tmux send-keys -t "$pane_id" "$(cat "$script_file")" C-m
  echo "Executed script $script_file in pane $pane_id"
}

# Function to broadcast input to multiple panes
broadcast_input() {
  input=$1
  tmux set-window-option synchronize-panes on
  tmux send-keys "$input" C-m
  tmux set-window-option synchronize-panes off
  echo "Broadcasted input to all panes"
}


# Function to display detailed help information
display_help() {
  # Define color codes
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color

  echo "┌──────────────────────────────────────────────────────────────────────────────────────┐"
  echo "│                                        txm Help                                      │"
  echo "├────────────────┬─────────────────────────────────────────────────────────────────────┤"
  echo "│    ${RED}Command${NC}     │                              ${BLUE}Description${NC}                             │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}new${NC}            │ Create a new session                                                │"
  echo "│   ${GREEN}SESSION_NAME${NC} │   ${BLUE}The name of the session to create (default: $default_session_name)${NC} │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}list${NC}           │ ${BLUE}List all sessions${NC}                                                   │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}attach${NC}         │ ${BLUE}Attach to a session${NC}                                                 │"
  echo "│   ${GREEN}SESSION_NAME${NC} │   ${BLUE}The name of the session to attach to${NC}                              │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}detach${NC}         │ ${BLUE}Detach from the current session${NC}                                     │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}rename${NC}         │ ${BLUE}Rename a session${NC}                                                    │"
  echo "│   ${GREEN}OLD_NAME${NC}     │   ${BLUE}The current name of the session${NC}                                   │"
  echo "│   ${GREEN}NEW_NAME${NC}     │   ${BLUE}The new name for the session${NC}                                      │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}kill${NC}           │ ${BLUE}Kill a session${NC}                                                      │"
  echo "│   ${GREEN}SESSION_NAME${NC} │   ${BLUE}The name of the session to kill${NC}                                   │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}switch${NC}         │ ${BLUE}Switch to a different session${NC}                                       │"
  echo "│   ${GREEN}SESSION_NAME${NC} │   ${BLUE}The name of the session to switch to${NC}                              │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}new-window${NC}     │ ${BLUE}Create a new window${NC}                                                 │"
  echo "│   ${GREEN}WINDOW_NAME${NC}  │   ${BLUE}The name of the window to create${NC}                                  │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}rename-window${NC}  │ ${BLUE}Rename a window${NC}                                                     │"
  echo "│   ${GREEN}OLD_NAME${NC}     │   ${BLUE}The current name of the window${NC}                                    │"
  echo "│   ${GREEN}NEW_NAME${NC}     │   ${BLUE}The new name for the window${NC}                                       │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}close-window${NC}   │ ${BLUE}Close a window${NC}                                                      │"
  echo "│   ${GREEN}WINDOW_NAME${NC}  │   ${BLUE}The name of the window to close${NC}                                   │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}switch-window${NC}  │ ${BLUE}Switch to a different window${NC}                                        │"
  echo "│   ${GREEN}WINDOW_NAME${NC}  │   ${BLUE}The name of the window to switch to${NC}                               │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}vsplit${NC}         │ ${BLUE}Split pane vertically${NC}                                               │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}hsplit${NC}         │ ${BLUE}Split pane horizontally${NC}                                             │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}navigate${NC}       │ ${BLUE}Navigate between panes${NC}                                              │"
  echo "│   ${GREEN}DIRECTION${NC}    │   ${BLUE}The direction to navigate (U: Up, D: Down, L: Left, R: Right)${NC}     │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}resize${NC}         │ ${BLUE}Resize pane${NC}                                                         │"
  echo "│   ${GREEN}DIRECTION${NC}    │   ${BLUE}The direction to resize (U: Up, D: Down, L: Left, R: Right)${NC}       │"
  echo "│   ${GREEN}AMOUNT${NC}       │   ${BLUE}The amount to resize the pane by${NC}                                  │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}close-pane${NC}     │ ${BLUE}Close the current pane${NC}                                              │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}zoom${NC}           │ ${BLUE}Zoom in/out of the current pane${NC}                                     │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}run${NC}            │ ${BLUE}Execute a command in the current pane${NC}                               │"
  echo "│   ${GREEN}COMMAND${NC}      │   ${BLUE}The command to execute${NC}                                            │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}save-layout${NC}    │ ${BLUE}Save the current session layout${NC}                                     │"
  echo "│   ${GREEN}LAYOUT_NAME${NC}  │   ${BLUE}The name to save the layout as${NC}                                    │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}restore-layout${NC} │ ${BLUE}Restore a previously saved session layout${NC}                           │"
  echo "│   ${GREEN}LAYOUT_NAME${NC}  │   ${BLUE}The name of the layout to restore${NC}                                 │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}set-option${NC}     │ ${BLUE}Set a tmux option${NC}                                                   │"
  echo "│   ${GREEN}OPTION${NC}       │   ${BLUE}The tmux option to set${NC}                                            │"
  echo "│   ${GREEN}VALUE${NC}        │   ${BLUE}The value to set the option to${NC}                                    │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}execute-script${NC} │ ${BLUE}Execute a script in a specific pane${NC}                                 │"
  echo "│   ${GREEN}PANE_ID${NC}      │   ${BLUE}The ID of the pane to execute the script in${NC}                       │"
  echo "│   ${GREEN}SCRIPT_FILE${NC}  │   ${BLUE}The path to the script file to execute${NC}                            │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}broadcast${NC}      │ ${BLUE}Broadcast input to all panes${NC}                                        │"
  echo "│   ${GREEN}INPUT${NC}        │   ${BLUE}The input to broadcast to all panes${NC}                               │"
  echo "├────────────────┼─────────────────────────────────────────────────────────────────────┤"
  echo "│ ${RED}help${NC}           │ ${BLUE}Display this help information${NC}                                       │"
  echo "└────────────────┴─────────────────────────────────────────────────────────────────────┘"
}


# Load configuration
load_config

# Main script
case $1 in
  new)
    new_session "$2"
    ;;
  list)
    list_sessions
    ;;
  attach)
    attach_session "$2"
    ;;
  detach)
    detach_session
    ;;
  rename)
    rename_session "$2" "$3"
    ;;
  kill)
    kill_session "$2"
    ;;
  switch)
    switch_session "$2"
    ;;
  new-window)
    new_window "$2"
    ;;
  rename-window)
    rename_window "$2" "$3"
    ;;
  close-window)
    close_window "$2"
    ;;
  switch-window)
    switch_window "$2"
    ;;
  vsplit)
    vsplit_pane
    ;;
  hsplit)
    hsplit_pane
    ;;
  navigate)
    navigate_panes "$2"
    ;;
  resize)
    resize_pane "$2" "$3"
    ;;
  close-pane)
    close_pane
    ;;
  zoom)
    zoom_pane
    ;;
  run)
    execute_command "${@:2}"
    ;;
  save-layout)
    save_layout "$2"
    ;;
  restore-layout)
    restore_layout "$2"
    ;;
  set-option)
    set_option "$2" "$3"
    ;;
  execute-script)
    execute_script "$2" "$3"
    ;;
  broadcast)
    broadcast_input "${@:2}"
    ;;
  help)
    display_help
    ;;
  *)
    display_help
    ;;
esac
