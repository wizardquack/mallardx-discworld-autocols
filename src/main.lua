-- Discworld Autocols — toggles server `cols` around column-aware commands.
-- See README.md for the full rationale.
--
-- The narrow width is the live OutputPane width (from `mud.viewport()`); a
-- wider pane gives wider banners, which is what the user is asking for by
-- sizing the pane that way. Discworld enforces its own server-side `cols`
-- ceiling so we don't cap here. A defensive floor catches degenerate
-- pre-first-report reads (viewport defaults to 999, so this is mostly
-- about future-proofing if the cell is ever pre-init zero).
local WIDE_COLS = 999

-- Subtract a small buffer from the raw viewport width so banners don't
-- abut the right edge of the pane (which can be visually cramped and is
-- prone to one-off wrap surprises near scrollbar/padding boundaries).
local COLS_BUFFER = 2

local function narrow_cols()
  local v = mud.viewport()
  if v.cols and v.cols >= 20 then return v.cols - COLS_BUFFER end
  return 100
end

-- Each entry: { name = "<unique alias name>", regex = "<command|synonym|...>" }.
-- The registration loop wraps the regex in a capture group and appends an
-- optional arg-tail group, so capture #1 is always the matched command literal
-- and capture #2 is always the arg tail (or nil).
local WRAPPED_COMMANDS = {
  { name = "alias",     regex = "alias" },
  { name = "blog",      regex = "blog" },
  { name = "cost",      regex = "cost" },
  { name = "countries", regex = "countries" },
  { name = "help",      regex = "help" },
  { name = "inv",       regex = "inv|inventory" },
  { name = "lang",      regex = "lang|language" },
  { name = "nickname",  regex = "nickname" },
  { name = "quest",     regex = "quest" },
  { name = "rituals",   regex = "rituals" },
  { name = "skills",    regex = "skills" },
  { name = "speak",     regex = "sp|speak" },
  { name = "who",       regex = "who" },
}

local function wrap_with_cols(original)
  mud.send("cols " .. narrow_cols())
  mud.send(original)
  mud.send("cols " .. WIDE_COLS)
end

-- Callback signature: function(_line, m)
--   _line = the full matched input string (unused here)
--   m     = Lua table of regex captures, 0-indexed at the Rust level but
--           set via enumerate() so m[0] = whole match, m[1] = capture group 1,
--           m[2] = capture group 2. See runtime.rs invoke_callback for the
--           authoritative dispatch.
for _, c in ipairs(WRAPPED_COMMANDS) do
  mud.alias("^(" .. c.regex .. ")( .*)?$", function(_line, m)
    -- m[1] = the matched command (e.g. "inv" or "inventory")
    -- m[2] = the arg tail including leading space (e.g. " weapons") or nil
    wrap_with_cols(m[1] .. (m[2] or ""))
  end, { name = "autocols-" .. c.name })
end

world.on("line", function(line)
  if line.text:match("^Columns changed from %d+ to %d+%.$") then
    return true
  end
end)

local in_mail = false

mud.alias("^mail( .*)?$", function(_line, m)
  local tail = m[1] or ""
  in_mail = true
  mud.send("cols " .. narrow_cols())
  mud.send("mail" .. tail)
end, { name = "autocols-mail" })

world.on("line", function(line)
  if in_mail and line.text:match("^Quitting mailer%.%.%. OK%.$") then
    in_mail = false
    mud.send("cols " .. WIDE_COLS)
  end
end)

local in_title_quest = false

mud.alias("^title quest( .*)?$", function(_line, m)
  local tail = m[1] or ""
  in_title_quest = true
  mud.send("cols " .. narrow_cols())
  mud.send("title quest" .. tail)
end, { name = "autocols-title-quest" })

world.on("line", function(line)
  if in_title_quest and line.text:match("^Aborted%.$") then
    in_title_quest = false
    mud.send("cols " .. WIDE_COLS)
  elseif in_title_quest and line.text:match("^Set the quest title to .+%.$") then
    in_title_quest = false
    mud.send("cols " .. WIDE_COLS)
  end
end)

mud.alias("^spells( .*)?$", function(_line, m)
  local tail = m[1] or ""
  wrap_with_cols("spells" .. tail)
end, { name = "autocols-spells" })

-- If the user drags the pane wider/narrower mid-session while inside one
-- of the stateful modes, push a fresh `cols N` so subsequent prompts match
-- the new width. Single-shot wrapped commands (`inv`, `who`, etc.) read
-- the live viewport at invocation time and don't need this hook.
events.on("viewport.resized", function(_v)
  if in_mail or in_title_quest then
    mud.send("cols " .. narrow_cols())
  end
end)

world.on("disconnect", function()
  in_mail = false
  in_title_quest = false
end)
