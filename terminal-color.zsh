# terminal-color — give every new terminal tab its own color and name.
#
# Each new interactive shell gets a random dark background tint (macOS
# Terminal.app), the directory name as its label in the tab title, a colored
# banner, and a right-prompt watermark — so you always know which terminal
# you're looking at.
#
# Install: source this file from your ~/.zshrc:
#   source /path/to/terminal-color.zsh
#
# Usage:
#   terminal-color on                  enable auto-coloring of new terminals
#   terminal-color off                 disable it (and reset this tab)
#   terminal-color reset               reset this tab only
#   terminal-color                     interactive color picker for this tab
#   terminal-color "My label"          relabel this tab (keeps its color)
#   terminal-color "My label" blue     named color
#   terminal-color "My label" 001c36   hex color (with or without #)
#   terminal-color "My label" random   random color, no prompt
#
# Colors: green blue red purple orange yellow dark teal cyan magenta pink
#         lime forest navy indigo crimson olive brown slate mint rose
#
# Designed for dark Terminal.app themes. In other terminals (VS Code, iTerm2)
# the background tint is skipped; the banner, title and watermark still work.

typeset -g _tc_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/terminal-color"

# Reset the current tab: title, background (Terminal.app only), watermark.
_tc_reset_tab() {
  printf "\e]0;\a"
  if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    osascript <<'EOF' >/dev/null 2>&1
tell application "Terminal"
  set background color of selected tab of front window to background color of default settings
end tell
EOF
  fi
  unset TC_LABEL TC_FG
}

terminal-color() {
  local label="${1:-}"
  local color="${2:-}"

  case "$label" in
    on)
      rm -f "$_tc_config_dir/off"
      print "terminal-color: on — new terminals will be auto-colored."
      [[ -z "$TC_LABEL" ]] && terminal-color "$(basename "$PWD")" random
      return 0 ;;
    off)
      mkdir -p "$_tc_config_dir" && : > "$_tc_config_dir/off"
      _tc_reset_tab
      print "terminal-color: off — new terminals stay plain (this tab reset too)."
      return 0 ;;
    reset)
      _tc_reset_tab
      return 0 ;;
  esac

  # Quick relabel: if this tab is already colored and only a label is given,
  # update the label without re-picking a color or replaying the banner.
  if [[ -n "$label" && -z "$color" && -n "$TC_FG" ]]; then
    export TC_LABEL="$label"
    printf "\e]0;%s\a" "$label"
    printf "%s  ▌ %s (relabeled)\e[0m\n" "$TC_FG" "$label"
    return 0
  fi

  label="${label:-Terminal}"

  # Palette eligible for random rotation and the picker
  local -a _tc_palette=(green blue red purple orange yellow dark teal cyan magenta pink lime forest navy indigo crimson olive brown slate mint rose)
  # Bright-ANSI digit per named color, used for picker swatches
  typeset -A _tc_fg_digit=(
    green 2 blue 4 red 1 purple 5 orange 3 yellow 3 dark 7
    teal 6 cyan 6 magenta 5 pink 5 lime 2 forest 2 navy 4
    indigo 5 crimson 1 olive 3 brown 3 slate 6 mint 2 rose 1
  )

  # `random` shortcut: pick from the palette without prompting
  if [[ "$color" == "random" ]]; then
    color="${_tc_palette[$((RANDOM % ${#_tc_palette[@]} + 1))]}"
  fi

  # Interactive picker when no color is specified
  if [[ -z "$color" ]]; then
    if [[ -t 0 && -t 1 ]]; then
      local -a _shuf
      _shuf=("${(@f)$(print -l ${_tc_palette[@]} | sort -R | head -10)}")

      printf '\nPick a color for "\e[1m%s\e[0m":\n\n' "$label"
      local i c
      for ((i=1; i<=10; i++)); do
        c="${_shuf[i]}"
        printf '   %2d \e[1;9%sm▌ %-9s\e[0m' "$i" "${_tc_fg_digit[$c]}" "$c"
        (( i % 5 == 0 )) && printf '\n'
      done

      printf '\n'
      local choice
      read "choice?Choice [1-10], Enter for random: "

      if [[ "$choice" == <-> ]] && (( choice >= 1 && choice <= 10 )); then
        color="${_shuf[choice]}"
      else
        color="${_shuf[$((RANDOM % 10 + 1))]}"
      fi
    else
      color="${_tc_palette[$((RANDOM % ${#_tc_palette[@]} + 1))]}"
    fi
  fi

  local r g b fg
  case "$color" in
    green)   r=20; g=40; b=25; fg="\e[1;92m" ;;
    blue)    r=15; g=25; b=50; fg="\e[1;94m" ;;
    red)     r=50; g=18; b=20; fg="\e[1;91m" ;;
    purple)  r=35; g=20; b=50; fg="\e[1;95m" ;;
    orange)  r=55; g=30; b=15; fg="\e[1;93m" ;;
    yellow)  r=50; g=45; b=15; fg="\e[1;93m" ;;
    dark)    r=10; g=10; b=15; fg="\e[1;97m" ;;
    teal)    r=15; g=45; b=45; fg="\e[1;96m" ;;
    cyan)    r=15; g=40; b=55; fg="\e[1;96m" ;;
    magenta) r=50; g=15; b=40; fg="\e[1;95m" ;;
    pink)    r=55; g=25; b=40; fg="\e[1;95m" ;;
    lime)    r=30; g=50; b=20; fg="\e[1;92m" ;;
    forest)  r=15; g=35; b=20; fg="\e[1;92m" ;;
    navy)    r=10; g=15; b=40; fg="\e[1;94m" ;;
    indigo)  r=25; g=15; b=50; fg="\e[1;95m" ;;
    crimson) r=45; g=10; b=25; fg="\e[1;91m" ;;
    olive)   r=40; g=40; b=15; fg="\e[1;93m" ;;
    brown)   r=40; g=25; b=15; fg="\e[1;93m" ;;
    slate)   r=20; g=25; b=35; fg="\e[1;96m" ;;
    mint)    r=20; g=45; b=35; fg="\e[1;92m" ;;
    rose)    r=50; g=20; b=30; fg="\e[1;91m" ;;
    \#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]|[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
            local hex="${color#\#}"
            r=$((16#${hex:0:2}))
            g=$((16#${hex:2:2}))
            b=$((16#${hex:4:2}))
            # Pick white or black text by background luminance
            local lum=$(( (r*299 + g*587 + b*114) / 1000 ))
            if (( lum < 128 )); then fg="\e[1;97m"; else fg="\e[1;30m"; fi
            ;;
    *)      r=20;  g=40;  b=25;  fg="\e[1;92m" ;;
  esac

  # Set tab + window title
  printf "\e]0;%s\a" "$label"

  # Tint Terminal.app background via AppleScript (current tab only).
  # Skip in VS Code / other terminals — they don't respond to the AppleScript,
  # so the banner + title below are the only watermark there.
  if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    osascript <<EOF >/dev/null 2>&1
tell application "Terminal"
  set background color of selected tab of front window to {${r}*257, ${g}*257, ${b}*257}
end tell
EOF
  fi

  # Print persistent banner so the watermark is visible in scrollback
  local width=$(tput cols)
  local bar=$(printf '═%.0s' $(seq 1 $width))
  printf "${fg}${bar}\e[0m\n"
  printf "${fg}  ▌ ${label}\e[0m\n"
  printf "${fg}${bar}\e[0m\n"

  # Export label + interpreted ANSI fg so RPROMPT can render the watermark.
  # `printf %b` resolves the literal "\e" in $fg into a real ESC byte.
  export TC_LABEL="$label"
  export TC_FG="$(printf '%b' "$fg")"
}

# Always-on watermark: shows "▌ label" in the tab's color at the right edge
# of every prompt line — survives scrolling, works in any terminal.
typeset -g _tc_reset=$'\e[0m'
_tc_update_rprompt() {
  if [[ -n "$TC_LABEL" && -n "$TC_FG" ]]; then
    RPROMPT="%{${TC_FG}%}▌ ${TC_LABEL}%{${_tc_reset}%}"
  else
    RPROMPT=""
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _tc_update_rprompt

# Auto-tint each new interactive shell with a random color, unless toggled
# off. Skipped if TC_LABEL is already set (sub-shell) or stdout isn't a tty.
if [[ -o interactive && -z "$TC_LABEL" && -t 1 && ! -e "$_tc_config_dir/off" ]]; then
  terminal-color "$(basename "$PWD")" random
fi
