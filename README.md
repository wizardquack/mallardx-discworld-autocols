# Discworld Autocols

Automatically toggles the server-side `cols` setting around column-aware commands.

## What it does

Mallard encourages users to set `cols` to 999 columns to minimize
problems with server-side word-wrap interfering with trigger matching.
However, many Discworld commands like `inv`, `who`, `help`, and
`skills` respond with decorative banners padded to your advertised
width — which becomes 999-character visual noise when displayed in a
reasonably-sized window.

This plugin intercepts those commands, temporarily sets `cols` to your live
OutputPane width (read via `mud.viewport()`), sends the command, and restores
`cols` to 999 afterwards. The result is readably-formatted command output sized
to your actual pane — wider pane, wider banners — while preserving trigger-safe
server-side wrapping for normal prose.

## Wrapped commands

The plugin automatically wraps the following commands:

- **Single-shot** (toggle narrower, send, toggle back): `alias`, `blog`, `cost`,
  `countries`, `group status`, `help`, `inv` / `inventory`, `lang` / `language`,
  `nickname`, `quest`, `rituals`, `skills`, `sp` / `speak`, `spells`, `who`
- **Stateful modes** (stay narrow until explicit exit): `mail`, `title quest`

## Column width

The narrow width follows your OutputPane: drag the pane wider and banners get
wider; drag it narrower and they shrink. The `mail` and `title quest` modes
also re-send `cols N` when you resize mid-session so subsequent prompts match.

## Adding your own commands

The plugin exposes an **Extra commands to wrap** setting (per world, so each
character can have its own list). Add any command word that produces banner
output you'd like sized to your pane.

- Separate entries with commas or whitespace: `skp, taa, score`
- Use a pipe to list synonyms for one entry: `skp|skillpoints`
- Only letters, digits, `_`, `-`, and `|` are allowed inside an entry
- If you re-declare a built-in command (e.g. `skills`), your entry replaces it

## Known limitation: abbreviations

Aliases match exact command spellings. If you type `i` for `inventory` or
`w` for `who`, the plugin will not intercept them. Type the full command name
(`inventory` or `who`) for the plugin to engage.

## Credit

Many thanks to Oki and their scripts at
https://code.tubul.net/tt_dw/scripts for the clever idea and
inspiration for this plugin.
