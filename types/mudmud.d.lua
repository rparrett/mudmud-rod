---@meta

---Mudmud's connection-local Lua API.

---@alias MudmudMsdpValue string|string[]

---@class MudmudMatches
---@field [integer] string? The complete match at index 1, followed by captures.
---@field [string] string? Named regex captures.

---@class MudmudSequenceMatch : MudmudMatches
---@field line string Visible terminal-control-stripped server text.
---@field raw_line string Server application data before terminal processing.

---@class MudmudEvent
---@field name string Exact event name.
---@field payload table<string, any> Event-specific payload.

---@class MudmudMsdp
---@field [string] MudmudMsdpValue

---@class MudmudAnsiColor

---@alias MudmudRichTextAlign "left"|"right"|"center"
---@alias MudmudRichTextPart string|MudmudRichTextDescriptor|MudmudRichText

---@class MudmudRichText
---@field [integer] MudmudRichTextPart

---@class MudmudRichTextDescriptor
---@field text string Literal text to display.
---@field foreground? MudmudAnsiColor Foreground color.
---@field background? MudmudAnsiColor Background color.
---@field bold? boolean Render with bold weight.
---@field dim? boolean Render with reduced intensity.
---@field italic? boolean Render in italics.
---@field underline? boolean Underline the text.
---@field width? integer Exact terminal-cell width; content is truncated and padded as needed.
---@field align? MudmudRichTextAlign Alignment within width. Defaults to left.

---@class MudmudAnsi
---@field default MudmudAnsiColor Terminal default color.
---@field black MudmudAnsiColor ANSI index 0.
---@field red MudmudAnsiColor ANSI index 1.
---@field green MudmudAnsiColor ANSI index 2.
---@field yellow MudmudAnsiColor ANSI index 3.
---@field blue MudmudAnsiColor ANSI index 4.
---@field magenta MudmudAnsiColor ANSI index 5.
---@field cyan MudmudAnsiColor ANSI index 6.
---@field white MudmudAnsiColor ANSI index 7.
---@field bright_black MudmudAnsiColor ANSI index 8.
---@field bright_red MudmudAnsiColor ANSI index 9.
---@field bright_green MudmudAnsiColor ANSI index 10.
---@field bright_yellow MudmudAnsiColor ANSI index 11.
---@field bright_blue MudmudAnsiColor ANSI index 12.
---@field bright_magenta MudmudAnsiColor ANSI index 13.
---@field bright_cyan MudmudAnsiColor ANSI index 14.
---@field bright_white MudmudAnsiColor ANSI index 15.
---@field indexed fun(index: integer): MudmudAnsiColor Construct an ANSI-256 color using index 0 through 255.
---@field rgb fun(red: integer, green: integer, blue: integer): MudmudAnsiColor Construct an RGB color using components 0 through 255.

---@class MudmudLineMatcherOptions
---@field case_insensitive? boolean Use ASCII case-insensitive matching. Defaults to false.
---@field raw? boolean Match server application data before terminal processing. Defaults to false.
---@field foreground? MudmudAnsiColor Require this effective foreground color at the match start.
---@field background? MudmudAnsiColor Require this effective background color at the match start.

---@class MudmudLineWaitOptions : MudmudLineMatcherOptions
---@field timeout? number Seconds to wait before stopping the sequence with an error.
---@field handler? fun(match: MudmudSequenceMatch) Called after a successful match.
---@field on_timeout? fun() Called before a timeout stops the sequence.

---@class MudmudEventWaitOptions
---@field timeout? number Seconds to wait before stopping the sequence with an error.
---@field payload? table<string, any> Partial payload that an event must contain.
---@field accept? fun(event: MudmudEvent): boolean Arbitrary event filter; cannot be combined with payload.
---@field on_other? fun(event: MudmudEvent) Called for rejected events with the requested name.
---@field handler? fun(event: MudmudEvent) Called after an accepted event.
---@field on_timeout? fun() Called before a timeout stops the sequence.

---@class MudmudRaceLineOptions : MudmudLineMatcherOptions
---@field handler? fun(match: MudmudSequenceMatch) Called by the winning branch.

---@class MudmudRaceEventOptions
---@field payload? table<string, any> Partial payload that an event must contain.
---@field accept? fun(event: MudmudEvent): boolean Arbitrary event filter; cannot be combined with payload.
---@field on_other? fun(event: MudmudEvent) Called for rejected events with the requested name.
---@field handler? fun(event: MudmudEvent) Called by the winning branch.

---@class MudmudRepeatUntilOptions : MudmudLineMatcherOptions
---@field every number Seconds between attempts; must be greater than zero.
---@field line? string Plaintext success pattern; exactly one of line or regex is required.
---@field regex? string Regex success pattern; exactly one of line or regex is required.
---@field timeout? number Seconds to wait before stopping the sequence with an error.
---@field handler? fun(match: MudmudSequenceMatch) Called after a successful match.
---@field on_timeout? fun() Called before a timeout stops the sequence.

---@class MudmudInputUntilOptions : MudmudRepeatUntilOptions
---@field input string Text to process through input triggers.

---@class MudmudSendUntilOptions : MudmudRepeatUntilOptions
---@field send string Text to send directly.

---@class MudmudRaceBuilder
local MudmudRaceBuilder = {}

---Add a plaintext server-line branch to a race.
---@param pattern string
---@param handler_or_options? fun(match: MudmudSequenceMatch)|MudmudRaceLineOptions
function MudmudRaceBuilder:line(pattern, handler_or_options) end

---Add a regex server-line branch to a race.
---@param pattern string
---@param handler_or_options? fun(match: MudmudSequenceMatch)|MudmudRaceLineOptions
function MudmudRaceBuilder:regex(pattern, handler_or_options) end

---Add an event branch to a race.
---@param name string
---@param options? MudmudRaceEventOptions
function MudmudRaceBuilder:event(name, options) end

---Add a deadline branch to a race.
---@param seconds number
---@param handler? fun()
function MudmudRaceBuilder:after(seconds, handler) end

---@class MudmudSequencePath
local MudmudSequencePath = {}

---Process text through input triggers when this step is reached.
---@param text string
function MudmudSequencePath:input(text) end

---Send text directly to the MUD when this step is reached.
---@param text string
function MudmudSequencePath:send(text) end

---Echo text to the connection output when this step is reached.
---@param text string
function MudmudSequencePath:echo(text) end

---Emit an event when this step is reached.
---@param name string
---@param payload? table<string, any>
function MudmudSequencePath:emit(name, payload) end

---Run a callback when this step is reached.
---@param callback fun()
function MudmudSequencePath:run(callback) end

---Wait without blocking the connection or automation worker.
---@param seconds number
function MudmudSequencePath:wait(seconds) end

---Wait for a plaintext server-line match.
---@param pattern string
---@param options? MudmudLineWaitOptions
function MudmudSequencePath:wait_line(pattern, options) end

---Wait for a regex server-line match.
---@param pattern string
---@param options? MudmudLineWaitOptions
function MudmudSequencePath:wait_regex(pattern, options) end

---Wait for an event with an optional payload or callback filter.
---@param name string
---@param options? MudmudEventWaitOptions
function MudmudSequencePath:wait_event(name, options) end

---Continue after the first matching branch.
---@param builder fun(first: MudmudRaceBuilder)
function MudmudSequencePath:race(builder) end

---Process input repeatedly until server text matches.
---@param options MudmudInputUntilOptions
function MudmudSequencePath:input_until(options) end

---Send text repeatedly until server text matches.
---@param options MudmudSendUntilOptions
function MudmudSequencePath:send_until(options) end

---@alias MudmudSequenceState
---| "idle"
---| "running"
---| "paused"
---| "finished"
---| "stopped"
---| "error"

---@alias MudmudSequenceStepKind
---| "input"
---| "send"
---| "echo"
---| "emit"
---| "run"
---| "wait"
---| "wait_line"
---| "wait_event"
---| "race"
---| "input_until"
---| "send_until"

---@class MudmudSequenceStatus
---@field state MudmudSequenceState
---@field name? string
---@field step? integer One-based current step.
---@field step_count integer
---@field step_kind? MudmudSequenceStepKind
---@field error? string

---@class MudmudSequencer
local MudmudSequencer = {}

---Start a sequence, replacing the currently running sequence.
---@param builder fun(path: MudmudSequencePath)
---@overload fun(name: string, builder: fun(path: MudmudSequencePath))
function MudmudSequencer.start(builder) end

---Stop the current sequence while retaining it for restart.
function MudmudSequencer.stop() end

---Pause the current sequence and its clocks.
function MudmudSequencer.pause() end

---Resume the paused sequence.
function MudmudSequencer.resume() end

---Skip the current blocking step.
function MudmudSequencer.skip() end

---Restart the retained sequence from its first step.
function MudmudSequencer.restart() end

---Return a snapshot of sequencer state.
---@return MudmudSequenceStatus
---@nodiscard
function MudmudSequencer.status() end

---Send text directly to the MUD, bypassing input triggers.
---@param text string
function send(text) end

---Process text through input triggers.
---@param text string
function input(text) end

---Append content exactly as supplied without adding a newline.
---@param value? MudmudRichTextPart
function echo(value) end

---Append content followed by exactly one newline.
---@param value? MudmudRichTextPart
function echoln(value) end

---Append debug representations of arbitrary values followed by one newline.
---@param ... any
function display(...) end

---Emit an event in the current connection's automation runtime.
---@param name string
---@param payload? table<string, any>
function emit(name, payload) end

---Return Unix epoch time in fractional seconds.
---@return number seconds
---@nodiscard
function now() end

---Visible terminal-control-stripped text for the current line match.
---@type string
line = ""

---Server application data before terminal processing for the current line match.
---@type string
raw_line = ""

---Captures for the current line match. Sequencer callbacks should prefer their typed argument.
---@type MudmudMatches
matches = {}

---The current event. Event and sequencer callbacks should prefer their typed argument when present.
---@type MudmudEvent
event = { name = "", payload = {} }

---Current MSDP values, keyed by the exact server-provided variable name.
---@type MudmudMsdp
msdp = {}

---@type MudmudAnsi
---@diagnostic disable-next-line: missing-fields
ansi = {}

---@type MudmudSequencer
seq = {}

---Remove Unicode whitespace from both ends of a string.
---@param value string
---@return string
function string.trim(value) end

---Remove Unicode whitespace from the start of a string.
---@param value string
---@return string
function string.triml(value) end

---Remove Unicode whitespace from the end of a string.
---@param value string
---@return string
function string.trimr(value) end

---Return whether a string contains a literal, case-sensitive substring.
---@param value string
---@param needle string
---@return boolean
function string.contains(value, needle) end

---Return whether a string starts with a literal, case-sensitive prefix.
---@param value string
---@param prefix string
---@return boolean
function string.starts_with(value, prefix) end

---Return whether a string ends with a literal, case-sensitive suffix.
---@param value string
---@param suffix string
---@return boolean
function string.ends_with(value, suffix) end
