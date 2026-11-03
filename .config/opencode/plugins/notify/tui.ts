import { execFile } from "node:child_process"
import { Plugin } from "@opencode/plugin/tui"

export default Plugin.define({
  id: "local.dunstify",
  setup(context) {
    const stop = context.data.on("session.execution.succeeded", () => {
      execFile(
        "dunstify",
        ["-t", "600"],
        ["-a", "OpenCode", "OpenCode", "Response completed!"],
        (error) => {
          if (error) console.error("OpenCode notification failed:", error.message)
        },
      )
    })

    return () => stop()
  },
})
