# Instructions for AI agents

You are setting up **terminal-color** for a user: a single-file zsh plugin
that gives every new terminal tab its own color and name. Your job is to
install it, verify it, and hand the user the commands. Follow this playbook.

## 1. Ask permission first

Installation means adding one `source` line to the user's `~/.zshrc`. Do NOT
edit `~/.zshrc` (or any shell config) until the user has said yes. Ask
something like:

> terminal-color installs by adding one line to your `~/.zshrc`:
> `source <path>/terminal-color.zsh`. OK to add it?

If the user's login shell is not zsh (`echo $SHELL`), stop and tell them —
this plugin is zsh-only.

## 2. Install

1. Decide the install path. If you already cloned this repo somewhere
   reasonable and permanent, source it from there. If you cloned into a
   temporary or working directory, copy or clone to `~/.terminal-color`
   instead so the path survives:

   ```sh
   git clone https://github.com/eddyvarelae/terminal-color.git ~/.terminal-color
   ```

2. Append the source line to `~/.zshrc` — idempotently. Check first that no
   line referencing `terminal-color.zsh` already exists; if it does, the
   plugin is already installed, skip to verification.

   ```sh
   echo 'source ~/.terminal-color/terminal-color.zsh' >> ~/.zshrc
   ```

## 3. Verify

Run these — they are safe in a non-interactive shell (the auto-coloring only
fires in interactive shells with a tty, so sourcing from a script changes
nothing visible):

```sh
zsh -n ~/.terminal-color/terminal-color.zsh      # syntax check
zsh -c 'source ~/.zshrc 2>/dev/null; type terminal-color' | head -1
```

The second command should report that `terminal-color` is a shell function.

Notes for you, the agent:

- Do NOT run `terminal-color <label> <color>` yourself from your tool shell:
  on macOS Terminal.app it tints the *frontmost* window's selected tab via
  AppleScript, which may not be the tab you are running in.
- The first time it runs, macOS may show an Automation permission prompt
  ("Terminal wants to control Terminal"). Warn the user to click Allow.

## 4. Hand off to the user

End by telling the user to **open a new terminal** (it will come up colored
and labeled with the directory name) and give them this cheat sheet:

```sh
terminal-color on                  # enable auto-coloring of new terminals
terminal-color off                 # disable it (and reset this tab)
terminal-color reset               # reset this tab only
terminal-color                     # interactive color picker for this tab
terminal-color "api server"        # relabel this tab (keeps its color)
terminal-color "api server" blue   # named color
terminal-color "staging" 001c36    # hex color (with or without #)
terminal-color "scratch" random    # random color, no prompt
```

Named colors: `green` `blue` `red` `purple` `orange` `yellow` `dark` `teal`
`cyan` `magenta` `pink` `lime` `forest` `navy` `indigo` `crimson` `olive`
`brown` `slate` `mint` `rose`

## Uninstall (if asked)

```sh
terminal-color off
rm -rf ~/.terminal-color ~/.config/terminal-color
```

...and remove the `source` line from `~/.zshrc`.
