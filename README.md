# Discworld Autocols

Automatically toggles the server-side `cols` setting around column-aware commands.

## What it does

Mallard advertises a banner width of 999 columns to the server (via NAWS) so that
server-side word-wrap doesn't interfere with trigger matching. However, many
Discworld commands like `inv`, `who`, `help`, and `skills` respond with decorative
banners padded to your advertised width — which becomes 999-character visual noise
when displayed in a reasonably-sized window.

This plugin intercepts those commands, temporarily sets `cols` to your live
OutputPane width (read via `mud.viewport()`), sends the command, and restores
`cols` to 999 afterwards. The result is readably-formatted command output sized
to your actual pane — wider pane, wider banners — while preserving trigger-safe
server-side wrapping for normal prose.

## Wrapped commands

The plugin automatically wraps the following commands:

- **Single-shot** (toggle narrower, send, toggle back): `alias`, `blog`, `cost`,
  `countries`, `help`, `inv` / `inventory`, `lang` / `language`, `nickname`,
  `quest`, `rituals`, `skills`, `sp` / `speak`, `spells`, `who`
- **Stateful modes** (stay narrow until explicit exit): `mail`, `title quest`

## Column width

The narrow width follows your OutputPane: drag the pane wider and banners get
wider; drag it narrower and they shrink. The `mail` and `title quest` modes
also re-send `cols N` when you resize mid-session so subsequent prompts match.

## Known limitation: abbreviations

Aliases match exact command spellings. If you type `i` for `inventory` or
`w` for `who`, the plugin will not intercept them. Type the full command name
(`inventory` or `who`) for the plugin to engage. (This follows the `tt_dw`
convention of not trying to be clever about abbreviations.)

