import { Plugin } from "@opencode/plugin/tui"
import type { KeyEvent } from "@opentui/core"
import { onCleanup } from "solid-js"

export default Plugin.define({
    id: "araaha.dialog-escape",
    setup(context) {
        return context.ui.slot({
            append: "app",
            render() {
                let disposed = false
                const input = context.renderer.keyInput
                const onKey = (event: KeyEvent) => {
                    if (
                        event.defaultPrevented ||
                        event.eventType === "release" ||
                        !event.ctrl ||
                        event.shift || event.meta || event.option || event.super || event.hyper ||
                        event.name?.toLowerCase() !== "c"
                    ) return

                    const mode = context.keymap.mode.current()
                    if (mode === "opencode-vim.session") {
                        // Let opencode-vim handle its own exit and focus cleanup.
                        // This listener runs first, translating Ctrl+C to Escape.
                        event.name = "escape"
                        event.ctrl = false
                        event.sequence = "\x1b"
                        event.raw = "\x1b"
                        return
                    }
                    if (mode !== "modal") return

                    event.preventDefault()
                    event.stopPropagation()
                    context.ui.dialog.clear()
                }

                // Install after app slots mount, ahead of opencode-vim's handler.
                queueMicrotask(() => {
                    if (!disposed) input.prependListener("keypress", onKey)
                })
                onCleanup(() => {
                    disposed = true
                    input.off("keypress", onKey)
                })
                return null
            },
        })
    },
})
