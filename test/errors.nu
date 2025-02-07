
export def catch-error [job: closure]: nothing -> string {
    try {
        do $job
        error make { msg: "no-error" }
    } catch { |error|
        if ($error.msg == "no-error") {
            error make {
                msg: "Expected an error"
                label: {
                    text: "from here"
                    span: (metadata $job).span
                }
            }
        } else {
            $error.msg
        }
    }
}
