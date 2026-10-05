# terminal-color

Give every new terminal tab its own color and name.

Open a terminal, get a random dark background tint, the directory name in the
tab title, a colored banner, and a little `▌ label` watermark on the right
side of every prompt. Open five terminals, get five different colors — no more
typing into the wrong one.

A single zsh file. No dependencies beyond macOS + zsh.

## Install

```sh
git clone https://github.com/eddyvarelae/terminal-color.git ~/.terminal-color
echo 'source ~/.terminal-color/terminal-color.zsh' >> ~/.zshrc
```

Open a new terminal. That's it.

The first time, macOS may ask to allow Terminal to control itself
(Automation permission) — that's the AppleScript that tints the background.

### Let an AI do it

Using Claude Code or another AI coding agent? Paste this:

> Clone https://github.com/eddyvarelae/terminal-color and follow its
> AGENTS.md to set it up for me.

The agent will ask before touching your `~/.zshrc`, verify the install, and
give you the commands when it's done.

## Usage

New terminals color themselves automatically. The commands are for when you
want control:

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

The on/off toggle persists across sessions (a flag file in
`~/.config/terminal-color/`).

Named colors: `green` `blue` `red` `purple` `orange` `yellow` `dark` `teal`
`cyan` `magenta` `pink` `lime` `forest` `navy` `indigo` `crimson` `olive`
`brown` `slate` `mint` `rose`

## How it works

- **Background tint** — only in Terminal.app: a one-line AppleScript sets the
  background color of the current tab. Each named color maps to a hand-tuned
  dark RGB so text stays readable on dark themes.
- **Tab title** — the standard `ESC ]0; title BEL` sequence.
- **Banner** — three full-width lines in the matching bright color, so the
  label survives in scrollback.
- **Prompt watermark** — a zsh `precmd` hook sets `RPROMPT` to `▌ label` in
  the tab's color. Works in any terminal, survives scrolling.

In terminals that aren't Terminal.app (VS Code, iTerm2, ...), the tint is
skipped and the title + banner + watermark carry the job.

Sub-shells inherit the color instead of re-rolling: the auto-color only fires
when `TC_LABEL` isn't already set.

## Uninstall

```sh
terminal-color off          # resets the current tab and disables auto-color
rm -rf ~/.terminal-color ~/.config/terminal-color
```

...and remove the `source` line from your `~/.zshrc`.

## License

MIT
