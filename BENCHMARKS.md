# GDMCode benchmark evidence (private draft)

All values below are from the pinned ADTC profiler `0.1.0`, but the environment
is explicitly `audit_cloud_vm`, not `participant_laptop`. They are an audit
envelope only.

| Candidate | Environment | Generation | First token | Peak RSS | Accuracy |
|---|---|---:|---:|---:|---|
| Qwen3.5-4B trained Q4_K_M | Debian 13, Intel Xeon 8124M, 30.4 GB, no GPU | 2.92 tok/s | 113,358.58 ms | 2,846.14 MiB | NOT MEASURED |

The 4B artifact is pinned by SHA-256
`514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9`. The raw
2B alternative is pinned by SHA-256
`ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b`.

**Participant-laptop result:** `NOT MEASURED`. No official score, thermal
claim, or accuracy result should be inferred from this table.
