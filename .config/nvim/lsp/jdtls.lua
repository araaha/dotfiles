return {
    cmd = { "jdtls" },
    filetypes = { "java" },
    root_markers = {
        {
            "mvnw",
            "gradlew",
            "settings.gradle",
            "settings.gradle.kts",
            ".git"
        }, { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" }
    },
    settings = {
        -- format = {
        --     enabled = true,
        --     comments = { enabled = false },
        --     tabSize = 4,
        -- },
    },
}
