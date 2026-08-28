# Two-minute ADTC demo plan

This is a deterministic recording outline for the verified release. Use the
current public repository and rebuilt release bundle when recording; do not
present this outline itself as runtime evidence.

| Time | Action | Evidence shown |
|---|---|---|
| 0:00–0:10 | Start from a clean checkout and show the two-prompt metadata contract. | `metadata.json`, pinned checksum |
| 0:10–0:25 | Open `/learn` and point to the `OFFLINE · LOCAL` badge and mode control. | private-by-default PWA and fail-closed offline policy |
| 0:25–0:48 | Start the beginner lesson and answer one quick check. | typed LessonIR content, quiz state, local progress |
| 0:48–1:08 | Run the loop in Practice workspace. | bounded local checker result; no arbitrary host command |
| 1:08–1:35 | In Build tether, ask “Explain this loop to a beginner.” | streamed local answer beside code and explicit write/execute boundary |
| 1:35–1:50 | Show the local `llama.cpp` process and a network-disabled proof. | local inference plus policy enforcement |
| 1:50–2:00 | State limitations and hand off to the profiler report. | no invented accuracy or participant score |

The recording must use the frozen candidate and matching clean-room profile.
Keep participant results and any unavailable accuracy result explicitly
labelled; this plan does not create new benchmark claims.
