// Vim editing engine for the OpenCode prompt. Text is handled as graphemes; the editor's
// cursor offsets are display columns, so Buf.off maps grapheme indices to editor offsets.

export type Mode = "normal" | "insert" | "visual"
export type Find = { key: "f" | "F" | "t" | "T"; ch: string }
export type Register = { text: string; linewise: boolean }
type Kind = "exclusive" | "inclusive" | "linewise"
type Motion = { to: number; kind: Kind; find?: Find }
type Range = { start: number; end: number; linewise: boolean }
type Edit = { start: number; end: number; text: string }
type Result = { edit?: Edit; cursor: number; register?: Register; insert?: boolean; find?: Find }
type Select = { select: [number, number]; find?: Find }
type Action = "pending" | "invalid" | "visual" | "exit" | "undo" | "down" | "up" | Result | Select
type Context = { register?: Register; lastFind?: Find }

export interface Editor {
  plainText: string
  cursorOffset: number
  editBuffer: { measureText(text: string): number }
  setSelection(start: number, end: number): void
  deleteSelection(): boolean
  insertText(text: string): void
  moveCursorDown(): boolean
  moveCursorUp(): boolean
  undo(): boolean
}

const segmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" })
export const graphemes = (text: string) => Array.from(segmenter.segment(text), (part) => part.segment)

// ---------- buffer helpers ----------

type Buf = { g: string[]; off: number[] }

export function readBuf(editor: Editor): Buf {
  const g = graphemes(editor.plainText)
  const off = [0]
  for (const ch of g) off.push(off[off.length - 1] + (ch === "\n" ? 1 : Math.max(1, editor.editBuffer.measureText(ch))))
  return { g, off }
}

export function cursorIndex(buf: Buf, offset: number) {
  let i = 0
  while (i < buf.g.length && buf.off[i + 1] <= offset) i++
  return i
}

function applyEdit(editor: Editor, buf: Buf, edit: Edit) {
  if (edit.end > edit.start) editor.setSelection(buf.off[edit.start], buf.off[edit.end])
  else editor.cursorOffset = buf.off[edit.start]
  if (edit.text) editor.insertText(edit.text)
  else if (edit.end > edit.start) editor.deleteSelection()
}

const splice = (g: string[], { start, end, text }: Edit) => [...g.slice(0, start), ...graphemes(text), ...g.slice(end)]
const isBlank = (ch: string | undefined) => ch === " " || ch === "\t"
const swapCase = (ch: string) => (ch === ch.toUpperCase() ? ch.toLowerCase() : ch.toUpperCase())
const charArg = (key: string) => (key === "space" ? " " : graphemes(key).length === 1 ? key : undefined)

export const lineStart = (g: string[], i: number) => {
  while (i > 0 && g[i - 1] !== "\n") i--
  return i
}
export const lineEnd = (g: string[], i: number) => {
  while (i < g.length && g[i] !== "\n") i++
  return i
}
const firstNonBlank = (g: string[], i: number) => {
  let j = lineStart(g, i)
  const end = lineEnd(g, i)
  while (j < end && isBlank(g[j])) j++
  return j
}
// Normal-mode cursor sits on a character, never past the end of a non-empty line.
export const clampNormal = (g: string[], i: number) => {
  i = Math.max(0, Math.min(i, g.length))
  const start = lineStart(g, i), end = lineEnd(g, i)
  return end > start ? Math.min(i, end - 1) : start
}

// ---------- words ----------

// 0 = whitespace, 1 = keyword (or any non-blank for WORD), 2 = punctuation
const cls = (ch: string | undefined, big: boolean) =>
  !ch || /^\s+$/u.test(ch) ? 0 : big || /^[\p{L}\p{N}_]/u.test(ch) ? 1 : 2

function nextWord(g: string[], i: number, big: boolean) {
  const c = cls(g[i], big)
  let j = i
  if (c) while (j < g.length && cls(g[j], big) === c) j++
  while (j < g.length && cls(g[j], big) === 0) j++
  return j
}
function endWord(g: string[], i: number, big: boolean) {
  let j = i + 1
  while (j < g.length && cls(g[j], big) === 0) j++
  if (j >= g.length) return Math.max(0, g.length - 1)
  const c = cls(g[j], big)
  while (j + 1 < g.length && cls(g[j + 1], big) === c) j++
  return j
}
function prevWord(g: string[], i: number, big: boolean) {
  let j = i - 1
  while (j > 0 && cls(g[j], big) === 0) j--
  if (j <= 0) return 0
  const c = cls(g[j], big)
  while (j > 0 && cls(g[j - 1], big) === c) j--
  return j
}

// ---------- brackets ----------

const PAIRS: Record<string, [string, string]> = {
  "(": ["(", ")"], ")": ["(", ")"], b: ["(", ")"],
  "{": ["{", "}"], "}": ["{", "}"], B: ["{", "}"],
  "[": ["[", "]"], "]": ["[", "]"],
  "<": ["<", ">"], ">": ["<", ">"],
}
function findOpen(g: string[], from: number, open: string, close: string) {
  let depth = 0
  for (let j = Math.min(from, g.length - 1); j >= 0; j--) {
    if (g[j] === close) depth++
    else if (g[j] === open && depth-- === 0) return j
  }
  return -1
}
function findClose(g: string[], from: number, open: string, close: string) {
  let depth = 0
  for (let j = from; j < g.length; j++) {
    if (g[j] === open) depth++
    else if (g[j] === close && depth-- === 0) return j
  }
  return -1
}

// ---------- motions ----------

function find(g: string[], i: number, f: Find, repeat = false): Motion | undefined {
  const start = lineStart(g, i), end = lineEnd(g, i)
  const forward = f.key === "f" || f.key === "t"
  const till = f.key === "t" || f.key === "T"
  const step = forward ? 1 : -1
  let j = i + step + (repeat && till ? step : 0)
  while (j >= start && j < end && g[j] !== f.ch) j += step
  if (j < start || j >= end) return undefined
  return forward
    ? { to: till ? j - 1 : j, kind: "inclusive", find: f }
    : { to: till ? j + 1 : j, kind: "exclusive", find: f }
}

const FLIP = { f: "F", F: "f", t: "T", T: "t" } as const

function motion(t: string[], g: string[], i: number, op: string | undefined, last?: Find): Motion | "pending" | undefined {
  const [k, arg] = t
  if (t.length > ("fFtTg".includes(k) && k.length === 1 ? 2 : 1)) return undefined
  const start = lineStart(g, i), end = lineEnd(g, i)
  switch (k) {
    case "h": case "left": case "backspace": return { to: Math.max(start, i - 1), kind: "exclusive" }
    case "l": case "right": return { to: Math.min(end, i + 1), kind: "exclusive" }
    case "0": case "home": return { to: start, kind: "exclusive" }
    case "^": case "H": return { to: firstNonBlank(g, i), kind: "exclusive" }
    case "$": case "L": case "end": return { to: end, kind: "exclusive" }
    case "e": case "E": return { to: endWord(g, i, k === "E"), kind: "inclusive" }
    case "b": case "B": return { to: prevWord(g, i, k === "B"), kind: "exclusive" }
    case "G": return { to: firstNonBlank(g, g.length), kind: "linewise" }
    case "j": return end < g.length ? { to: end + 1, kind: "linewise" } : undefined
    case "k": return start > 0 ? { to: start - 1, kind: "linewise" } : undefined
    case "w": case "W": {
      const big = k === "W"
      const c = cls(g[i], big)
      // cw on a word changes to the end of the word, like ce.
      if (op === "c" && c) {
        let j = i
        while (j + 1 < g.length && cls(g[j + 1], big) === c) j++
        return { to: j, kind: "inclusive" }
      }
      const to = nextWord(g, i, big)
      // An operator never crosses into the next line with w.
      return { to: op && to > end ? end : to, kind: "exclusive" }
    }
    case "g":
      if (!arg) return "pending"
      if (arg === "g") return { to: firstNonBlank(g, 0), kind: "linewise" }
      if (arg === "0" || arg === "^" || arg === "$") return motion([arg], g, i, op)
      return undefined
    case "f": case "F": case "t": case "T": {
      if (!arg) return "pending"
      const ch = charArg(arg)
      return ch ? find(g, i, { key: k, ch }) : undefined
    }
    case ";": case ",":
      if (!last) return undefined
      return find(g, i, k === ";" ? last : { key: FLIP[last.key], ch: last.ch }, true)
    case "%": {
      let j = i
      while (j < end && !"()[]{}".includes(g[j])) j++
      if (j >= end) return undefined
      const [open, close] = PAIRS[g[j]]
      const to = g[j] === open ? findClose(g, j + 1, open, close) : findOpen(g, j - 1, open, close)
      return to < 0 ? undefined : { to, kind: "inclusive" }
    }
  }
  return undefined
}

// ---------- text objects ----------

function textObject(g: string[], i: number, type: string, obj: string): Range | undefined {
  const start = lineStart(g, i), end = lineEnd(g, i)
  const inner = type === "i"
  const blank = (j: number) => j >= start && j < end && isBlank(g[j])

  if (obj === "w" || obj === "W") {
    if (i >= end) return undefined
    const big = obj === "W"
    const c = cls(g[i], big)
    const same = (j: number) => j >= start && j < end && cls(g[j], big) === c
    let s = i, e = i + 1
    while (same(s - 1)) s--
    while (same(e)) e++
    if (!inner) {
      if (c === 0) {
        const next = cls(g[e], big)
        while (next && e < end && cls(g[e], big) === next) e++
      } else if (blank(e)) while (blank(e)) e++
      else while (blank(s - 1)) s--
    }
    return { start: s, end: e, linewise: false }
  }

  if (obj === '"' || obj === "'" || obj === "`") {
    const quotes: number[] = []
    for (let j = start; j < end; j++) if (g[j] === obj && g[j - 1] !== "\\") quotes.push(j)
    for (let n = 0; n + 1 < quotes.length; n += 2) {
      const open = quotes[n], close = quotes[n + 1]
      if (close < i) continue
      if (inner) return { start: open + 1, end: close, linewise: false }
      let s = open, e = close + 1
      if (blank(e)) while (blank(e)) e++
      else while (blank(s - 1)) s--
      return { start: s, end: e, linewise: false }
    }
    return undefined
  }

  const pair = PAIRS[obj]
  if (pair) {
    const [open, close] = pair
    const o = findOpen(g, g[i] === close ? i - 1 : i, open, close)
    const c = o < 0 ? -1 : findClose(g, o + 1, open, close)
    if (c < 0) return undefined
    return inner ? { start: o + 1, end: c, linewise: false } : { start: o, end: c + 1, linewise: false }
  }

  if (obj === "p") {
    const blankLine = (s: number) => g.slice(s, lineEnd(g, s)).every((ch) => /\s/u.test(ch))
    const kind = blankLine(start)
    let s = start, e = end
    while (s > 0 && blankLine(lineStart(g, s - 1)) === kind) s = lineStart(g, s - 1)
    while (e < g.length && blankLine(e + 1) === kind) e = lineEnd(g, e + 1)
    if (!inner) {
      const before = e
      while (e < g.length && blankLine(e + 1) !== kind) e = lineEnd(g, e + 1)
      if (e === before) while (s > 0 && blankLine(lineStart(g, s - 1)) !== kind) s = lineStart(g, s - 1)
    }
    return { start: s, end: e, linewise: true }
  }
  return undefined
}

// ---------- operators ----------

function rangeOf(g: string[], i: number, m: Motion): Range {
  const a = Math.min(i, m.to), b = Math.max(i, m.to)
  if (m.kind === "linewise") return { start: lineStart(g, a), end: lineEnd(g, b), linewise: true }
  return { start: a, end: m.kind === "inclusive" ? Math.min(g.length, b + 1) : b, linewise: false }
}

function operate(g: string[], i: number, op: string, r: Range): Result {
  const register = { text: g.slice(r.start, r.end).join(""), linewise: r.linewise }
  if (op === "y") {
    const cursor = r.linewise ? (r.start < lineStart(g, i) ? firstNonBlank(g, r.start) : i) : r.start
    return { register, cursor }
  }
  if (op === "c") return { register, edit: { start: r.start, end: r.end, text: "" }, cursor: r.start, insert: true }
  if (!r.linewise) {
    const edit = { start: r.start, end: r.end, text: "" }
    return { register, edit, cursor: clampNormal(splice(g, edit), r.start) }
  }
  // Linewise delete also removes one adjoining newline.
  let s = r.start, e = r.end
  if (e < g.length) e++
  else if (s > 0) s--
  const edit = { start: s, end: e, text: "" }
  const next = splice(g, edit)
  return { register, edit, cursor: firstNonBlank(next, Math.min(r.start, next.length)) }
}

function paste(g: string[], i: number, reg: Register, before: boolean): Result {
  if (reg.linewise) {
    const at = before ? lineStart(g, i) : lineEnd(g, i)
    const edit = { start: at, end: at, text: before ? `${reg.text}\n` : `\n${reg.text}` }
    return { edit, cursor: firstNonBlank(splice(g, edit), before ? at : at + 1) }
  }
  const end = lineEnd(g, i)
  const at = before || end === lineStart(g, i) ? i : Math.min(i + 1, end)
  return { edit: { start: at, end: at, text: reg.text }, cursor: at + Math.max(0, graphemes(reg.text).length - 1) }
}

function join(g: string[], i: number): Result | undefined {
  const end = lineEnd(g, i)
  if (end >= g.length) return undefined
  let j = end + 1
  while (j < g.length && isBlank(g[j])) j++
  const space = end > lineStart(g, i) && j < g.length && g[j] !== "\n" && g[j] !== ")" && !isBlank(g[end - 1])
  return { edit: { start: end, end: j, text: space ? " " : "" }, cursor: end }
}

// ---------- normal and visual commands ----------

function normal(t: string[], g: string[], i: number, ctx: Context): Action {
  const [k] = t
  const one = t.length === 1
  const start = lineStart(g, i), end = lineEnd(g, i)
  if (one) {
    switch (k) {
      case "i": return { cursor: i, insert: true }
      case "a": return { cursor: end > start ? Math.min(i + 1, end) : i, insert: true }
      case "I": return { cursor: firstNonBlank(g, i), insert: true }
      case "A": return { cursor: end, insert: true }
      case "o": return { edit: { start: end, end, text: "\n" }, cursor: end + 1, insert: true }
      case "O": return { edit: { start, end: start, text: "\n" }, cursor: start, insert: true }
      case "v": return "visual"
      case "u": return "undo"
      case "j": return "down"
      case "k": return "up"
      case "x": case "delete": return i < end ? operate(g, i, "d", { start: i, end: i + 1, linewise: false }) : "invalid"
      case "D": return operate(g, i, "d", { start, end, linewise: true })
      case "C": return operate(g, i, "c", { start: i, end, linewise: false })
      case "Y": return operate(g, i, "y", { start: i, end, linewise: false })
      case "p": case "P": return ctx.register ? paste(g, i, ctx.register, k === "P") : "invalid"
      case "~":
        if (i >= end) return "invalid"
        return { edit: { start: i, end: i + 1, text: swapCase(g[i]) }, cursor: Math.min(i + 1, end - 1) }
    }
  }
  if (k === "r") {
    if (one) return "pending"
    const ch = t.length === 2 ? charArg(t[1]) : undefined
    return ch && i < end ? { edit: { start: i, end: i + 1, text: ch }, cursor: i } : "invalid"
  }
  if (k === "d" || k === "c" || k === "y") {
    const rest = t.slice(1)
    if (!rest.length) return "pending"
    if (rest.length === 1 && rest[0] === k) return operate(g, i, k, { start, end, linewise: true })
    if (rest[0] === "i" || rest[0] === "a") {
      if (rest.length === 1) return "pending"
      const r = rest.length === 2 ? textObject(g, i, rest[0], rest[1]) : undefined
      return r ? operate(g, i, k, r) : "invalid"
    }
    const m = motion(rest, g, i, k, ctx.lastFind)
    if (m === "pending" || !m) return m ?? "invalid"
    return { ...operate(g, i, k, rangeOf(g, i, m)), find: m.find }
  }
  if (k === "g" && t.length === 2) {
    if (t[1] === "j") return "down"
    if (t[1] === "k") return "up"
    if (t[1] === "J") return join(g, i) ?? "invalid"
  }
  const m = motion(t, g, i, undefined, ctx.lastFind)
  if (m === "pending" || !m) return m ?? "invalid"
  return { cursor: m.kind === "linewise" ? m.to : clampNormal(g, m.to), find: m.find }
}

function visual(t: string[], g: string[], i: number, anchor: number, ctx: Context): Action {
  const [k] = t
  const s = Math.min(anchor, i), e = Math.min(g.length, Math.max(anchor, i) + 1)
  const selection = { start: s, end: e, linewise: false }
  if (t.length === 1) {
    switch (k) {
      case "v": return "exit"
      case "o": return { select: [i, anchor] }
      case "j": return "down"
      case "k": return "up"
      case "d": case "x": case "delete": return operate(g, i, "d", selection)
      case "c": case "s": return operate(g, i, "c", selection)
      case "y": return operate(g, i, "y", selection)
      case "p": case "P": {
        if (!ctx.register) return "invalid"
        const text = ctx.register.text
        return { edit: { start: s, end: e, text }, cursor: s + Math.max(0, graphemes(text).length - 1) }
      }
      case "~": return { edit: { start: s, end: e, text: g.slice(s, e).map(swapCase).join("") }, cursor: s }
    }
  }
  if (k === "i" || k === "a") {
    if (t.length === 1) return "pending"
    const r = t.length === 2 ? textObject(g, i, k, t[1]) : undefined
    return r && r.end > r.start ? { select: [r.start, r.end - 1] } : "invalid"
  }
  if (k === "g" && t.length === 2 && (t[1] === "j" || t[1] === "k")) return t[1] === "j" ? "down" : "up"
  const m = motion(t, g, i, undefined, ctx.lastFind)
  if (m === "pending" || !m) return m ?? "invalid"
  const to = k === "$" || k === "L" || k === "end" ? Math.min(m.to, Math.max(0, g.length - 1)) : clampNormal(g, m.to)
  return { select: [anchor, to], find: m.find }
}

// ---------- key dispatch ----------

// Keys that take a following vim argument; while pending, session mappings are ignored.
const VIM_ARG = new Set(["d", "c", "y", "r", "f", "F", "t", "T", "i", "a"])
const ALIASES: Record<string, string[]> = { "space y": ["y"], "space p": ["p"] }
// Named keys that vim handles itself in normal/visual mode instead of passing to OpenCode.
const OWN_KEYS = new Set(["backspace", "delete", "left", "right", "home", "end"])

export class Vim {
  mode: Mode = "normal"
  register?: Register
  lastFind?: Find
  private pending: string[] = []
  private anchor = 0
  private cursor = 0

  constructor(
    private options: {
      mappings: Map<string, string>
      dispatch(command: string): void
      onMode(mode: Mode): void
    },
  ) {}

  setMode(mode: Mode) {
    this.mode = mode
    this.pending = []
    this.options.onMode(mode)
  }

  // Returns true when the key was consumed. `modified` means ctrl/alt was held.
  key(editor: Editor, key: string, modified = false): boolean {
    if (this.mode === "insert") {
      if (key !== "escape") return false
      const b = readBuf(editor), i = cursorIndex(b, editor.cursorOffset)
      if (i > lineStart(b.g, i)) editor.cursorOffset = b.off[i - 1]
      this.setMode("normal")
      return true
    }
    const b = readBuf(editor)
    const i = this.mode === "visual" ? Math.min(this.cursor, b.g.length) : cursorIndex(b, editor.cursorOffset)
    if (key === "escape") {
      if (this.pending.length) {
        this.pending = []
        return true
      }
      if (this.mode !== "visual") return false
      this.apply(editor, b, i, "exit")
      return true
    }

    const t = [...this.pending, key]
    const name = t.join(" ")
    const alias = ALIASES[name]
    const inVim = this.pending.length > 0 && VIM_ARG.has(this.pending[0])
    const { mappings } = this.options
    // j/k move through prompt lines; on the first/last line they fall back to their mapping.
    if (this.mode === "normal" && !this.pending.length && (key === "j" || key === "k")) {
      const before = editor.cursorOffset
      this.apply(editor, b, i, key === "j" ? "down" : "up")
      if (editor.cursorOffset !== before) return true
    }
    if (this.mode === "normal" && !inVim && !alias) {
      const command = mappings.get(name)
      if (command) {
        this.pending = []
        this.options.dispatch(command)
        return true
      }
    }
    const prefix =
      !inVim && (name === "space" || (this.mode === "normal" && [...mappings.keys()].some((n) => n.startsWith(`${name} `))))
    const ctx = { register: this.register, lastFind: this.lastFind }
    const action = this.mode === "visual" ? visual(alias ?? t, b.g, i, this.anchor, ctx) : normal(alias ?? t, b.g, i, ctx)
    if (action === "pending" || (action === "invalid" && prefix)) {
      this.pending = t
      return true
    }
    this.pending = []
    if (action === "invalid") {
      // Let OpenCode handle unbound chords and keys such as Enter, Tab, and Up/Down.
      const named = graphemes(key).length > 1 && !OWN_KEYS.has(key)
      return !(t.length === 1 && (modified || named))
    }
    this.apply(editor, b, i, action)
    return true
  }

  private apply(editor: Editor, b: Buf, i: number, action: Exclude<Action, "pending" | "invalid">) {
    if (action === "visual") {
      this.anchor = this.cursor = i
      this.setMode("visual")
      this.select(editor, b)
      return
    }
    if (action === "exit") {
      editor.cursorOffset = b.off[i]
      this.setMode("normal")
      return
    }
    if (action === "undo") {
      editor.undo()
      return
    }
    if (action === "down" || action === "up") {
      editor.cursorOffset = b.off[i]
      if (action === "down") editor.moveCursorDown()
      else editor.moveCursorUp()
      const next = readBuf(editor)
      const j = cursorIndex(next, editor.cursorOffset)
      if (this.mode === "visual") {
        this.cursor = clampNormal(next.g, j)
        this.select(editor, next)
      } else editor.cursorOffset = next.off[clampNormal(next.g, j)]
      return
    }
    if (action.find) this.lastFind = action.find
    if ("select" in action) {
      ;[this.anchor, this.cursor] = action.select
      this.select(editor, b)
      return
    }
    if (action.register) this.register = action.register
    let next = b
    if (action.edit) {
      applyEdit(editor, b, action.edit)
      next = readBuf(editor)
    }
    editor.cursorOffset = next.off[Math.max(0, Math.min(action.cursor, next.g.length))]
    if (action.insert) this.setMode("insert")
    else if (this.mode === "visual") this.setMode("normal")
  }

  private select(editor: Editor, b: Buf) {
    const s = Math.min(this.anchor, this.cursor)
    const e = Math.min(b.g.length, Math.max(this.anchor, this.cursor) + 1)
    editor.cursorOffset = b.off[Math.min(this.cursor, b.g.length)]
    editor.setSelection(b.off[s], b.off[e])
  }
}
