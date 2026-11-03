import { Plugin } from "@opencode/plugin/tui"
import { RGBA, type EditBufferRenderable, type KeyEvent } from "@opentui/core"
import { createSignal } from "solid-js"
import { graphemes, Vim, type Mode } from "./vim"

// Normal-mode mappings to OpenCode commands, carried over from the opencode-vim config.
const commands: Record<string, string> = {
  j: "session.line.down", k: "session.line.up", gg: "session.first", G: "session.last",
  J: "opencode-vim.session.previous", K: "opencode-vim.session.next", gt: "session.list",
  X: "session.tab.close", "ctrl+e": "session.tab.history.back", "ctrl+s": "prompt.stash",
  "ctrl+u": "session.half.page.up", "ctrl+d": "session.half.page.down",
  "ctrl+b": "session.page.up", "ctrl+f": "session.page.down",
  "[m": "session.message.previous", "]m": "session.message.next",
  "[[": "session.message.user.previous", "]]": "session.message.user.next",
  zz: "app.exit", zq: "app.exit", zQ: "app.exit", Zq: "app.exit",
  "space e": "prompt.editor", "space b": "session.sidebar.toggle", "space t": "terminal.toggle",
  "space os": "opencode.status", "space oe": "session.export", "space on": "session.new",
  "space ol": "session.list", "space do": "diff.open", "space lp": "plugins.list",
  "space ot": "session.timeline", "space fz": "session.cd", "space w": "session.tab.close",
  "space oc": "session.compact", "space oq": "session.queued_prompts", "space m": "model.list",
  "space a": "agent.list", "space Y": "messages.copy", "space P": "prompt.stash.pop",
  "space u": "session.undo", "space i": "prompt.images.view", "space enter": "prompt.queue",
  "space 1": "session.tab.select.1", "space 2": "session.tab.select.2",
  "space 3": "session.tab.select.3", "space 4": "session.tab.select.4",
  "space 5": "session.tab.select.5", "space 6": "session.tab.select.6",
  "space 7": "session.tab.select.7", "space 8": "session.tab.select.8",
  "space 9": "session.tab.select.9", "space 0": "session.tab.select.10",
  "ctrl+w s": "session.new", "ctrl+w v": "session.new",
  "ctrl+w h": "pane.focus.left", "ctrl+w l": "pane.focus.right",
  "ctrl+r": "session.redo",
}

// Normalize mapping names to space-separated key tokens: "gg" -> "g g", "space os" -> "space o s".
const tokens = (name: string) =>
  name.split(" ").flatMap((part) => (/^(ctrl|alt)\+/.test(part) || part === "space" || part === "enter" ? [part] : [...part]))
const mappings = new Map(Object.entries(commands).map(([name, id]) => [tokens(name).join(" "), id]))

// OpenTUI reports Shift+g as { name: "g", shift: true }, Enter as "return", and Space as "space".
function keyName(event: KeyEvent) {
  const name = event.name ?? ""
  if (event.ctrl) return `ctrl+${name.toLowerCase()}`
  if (event.meta || event.option) return `alt+${name.toLowerCase()}`
  if (name === "return" || name === "enter") return "enter"
  if (name !== "space" && graphemes(name).length === 1) return event.shift ? name.toUpperCase() : name
  return name
}

const CURSOR = RGBA.fromHex("#9cd365")
const VISUAL = RGBA.fromHex("#3f3f3f")
const sameColor = (a?: RGBA, b?: RGBA) => (a && b ? a.equals(b) : a === b)

const MODE_COLORS: Record<Mode, string> = { normal: "#7DAEA3", insert: "#9DC365", visual: "#D8A657" }

export default Plugin.define({
  id: "local.vim-mini",
  setup(context) {
    const [displayMode, setDisplayMode] = createSignal<Mode>("normal")
    let styledEditor: EditBufferRenderable | null = null
    let originalCursorColor: EditBufferRenderable["cursorColor"] | undefined
    let originalCursorStyle: EditBufferRenderable["cursorStyle"] | undefined
    let originalSelectionBg: EditBufferRenderable["selectionBg"] | undefined
    let paletteReturn: Mode | undefined
    let sawModal = false
    // Building the command list is expensive, so remember which editors are the prompt.
    const prompts = new WeakSet<object>()
    const isPrompt = (editor: EditBufferRenderable) => {
      if (prompts.has(editor)) return true
      if (!context.keymap.commands().some((item) => item.id === "prompt.submit")) return false
      prompts.add(editor)
      return true
    }

    const vim = new Vim({
      mappings,
      dispatch: (command) => context.keymap.dispatch(command),
      onMode: (mode) => {
        setDisplayMode(mode)
        if (styledEditor) styledEditor.selectionBg = mode === "visual" ? VISUAL : originalSelectionBg
      },
    })

    const input = context.renderer.keyInput as typeof context.renderer.keyInput & {
      prependListener(event: "keypress", listener: (event: KeyEvent) => void): void
      off(event: "keypress", listener: (event: KeyEvent) => void): void
    }

    const onKey = (event: KeyEvent) => {
      if (event.eventType === "release" || event.defaultPrevented) return

      // Ctrl+C is a literal Escape for the prompt and dialogs alike.
      if (event.ctrl && !event.shift && !event.meta && !event.option && event.name?.toLowerCase() === "c") {
        event.name = "escape"
        event.ctrl = false
        event.sequence = "\x1b"
        event.raw = "\x1b"
      }

      if (context.keymap.mode.current() !== "base") {
        sawModal = true
        return
      }
      if (sawModal && paletteReturn && context.renderer.currentFocusedEditor) {
        vim.setMode(paletteReturn)
        paletteReturn = undefined
        sawModal = false
      }
      const editor = context.renderer.currentFocusedEditor
      if (!editor || !isPrompt(editor)) return
      if (styledEditor !== editor) {
        if (styledEditor) {
          styledEditor.cursorColor = originalCursorColor!
          styledEditor.cursorStyle = originalCursorStyle!
          styledEditor.selectionBg = originalSelectionBg
        }
        styledEditor = editor
        originalCursorColor = editor.cursorColor
        originalCursorStyle = editor.cursorStyle
        originalSelectionBg = editor.selectionBg
      }
      // Only touch colors when they differ: each setter requests a render.
      if (!editor.cursorColor.equals(CURSOR)) editor.cursorColor = CURSOR
      const style = editor.cursorStyle
      if (style.blinking !== false || style.style !== "block") editor.cursorStyle = { ...style, style: "block", blinking: false }
      const selection = vim.mode === "visual" ? VISUAL : originalSelectionBg
      if (!sameColor(editor.selectionBg, selection)) editor.selectionBg = selection

      // Let OpenCode open its command palette, typing in insert mode until it closes.
      if (event.ctrl && event.name?.toLowerCase() === "p") {
        paletteReturn ??= vim.mode
        vim.setMode("insert")
        return
      }

      const key = keyName(event)
      if (vim.mode === "insert" && key === "ctrl+s") {
        event.preventDefault(); event.stopPropagation()
        context.keymap.dispatch("prompt.stash")
        return
      }
      if (vim.key(editor, key, event.ctrl || event.meta || event.option)) {
        event.preventDefault(); event.stopPropagation()
      }
    }

    context.keymap.layer(() => ({
      mode: "global",
      priority: 10,
      commands: [
        {
          id: "local.vim-mini.pane-history-forward",
          title: "Pane history forward",
          bind: "alt+i",
          run: () => context.keymap.dispatch("session.tab.history.forward"),
        },
        {
          id: "local.vim-mini.pane-history-back",
          title: "Pane history back",
          bind: "alt+o",
          run: () => context.keymap.dispatch("session.tab.history.back"),
        },
      ],
      bindings: ["local.vim-mini.pane-history-forward", "local.vim-mini.pane-history-back"],
    }))
    input.prependListener("keypress", onKey)
    const footer = context.ui.slot({
      prepend: "prompt.footer",
      render: (footer) => footer.mode === "normal" ? (
        <box flexDirection="row" flexShrink={0} paddingRight={1}>
          <text fg="#242424" bg={MODE_COLORS[displayMode()]}>{` ${displayMode().toUpperCase()} `}</text>
        </box>
      ) : null,
    })
    return () => {
      input.off("keypress", onKey)
      footer()
      if (styledEditor) {
        styledEditor.cursorColor = originalCursorColor!
        styledEditor.cursorStyle = originalCursorStyle!
        styledEditor.selectionBg = originalSelectionBg
      }
    }
  },
})
