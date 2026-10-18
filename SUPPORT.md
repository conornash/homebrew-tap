# Supported machines

This tap exists to put the same tools on a small, known set of Macs. Every cask
in it must install and run on every machine in this table. Add a row when a
machine joins; remove it when one leaves. Do not raise a cask's `depends_on macos:`
floor above the oldest row here without updating this file first.

| Machine        | Owner | macOS            | CPU            | Homebrew prefix   | Notes                                  |
|----------------|-------|------------------|----------------|-------------------|----------------------------------------|
| Kaji           | Conor | 26.6.2 (Tahoe)   | arm64          | /opt/homebrew     | Tap is authored and tested here. Gatekeeper **off** (`spctl --status` → assessments disabled), so a passing launch here says nothing about Gatekeeper-on machines |
| TODO: hostname | twin  | 12.x (Monterey)  | TODO: arm64/x86_64 | TODO           | Gatekeeper on (assumed) — see README   |
| TODO: hostname | twin  | 12.x (Monterey)  | TODO: arm64/x86_64 | TODO           | Gatekeeper on (assumed) — see README   |

Oldest macOS in the table: **12 (Monterey)**. Every cask carries
`depends_on macos: :monterey` (a bare symbol means "this version or newer";
the `">= :monterey"` string form is deprecated) to make that floor explicit and to make
`brew audit` enforce it.

## What "supported" means for each macOS version

### macOS 26 (Tahoe)

Fully supported by Homebrew (`HOMEBREW_MACOS_OLDEST_SUPPORTED` is 15 as of
Homebrew 6.x). Exercised by CI on every push (GitHub `macos-26` runner, arm64).

### macOS 12 (Monterey)

**Allowed but unsupported by Homebrew.** Homebrew 6.x sets
`HOMEBREW_MACOS_OLDEST_ALLOWED="11"` and `HOMEBREW_MACOS_OLDEST_SUPPORTED="15"`
(`Library/Homebrew/brew.sh`). Consequences:

- `brew` runs, but prints a "macOS 12 is unsupported" warning on every command.
  This is noise, not an error.
- Casks are prebuilt applications, so they are unaffected by the lack of
  bottles. Formulae would build from source; this tap deliberately ships
  **casks only** so that nothing in it needs a compiler on these machines.
- Homebrew removes allowed-but-unsupported versions on a schedule (Big Sur is
  pencilled for September 2027 or later; Monterey has no announced date). When
  Monterey is dropped, `brew` itself will refuse to run on those machines and
  this tap cannot help. Check `HOMEBREW_MACOS_OLDEST_ALLOWED` in
  `Library/Homebrew/brew.sh` upstream when planning OS upgrades.
- **Not exercised by CI.** GitHub retired its `macos-12` runners in December
  2024. Monterey support is verified by hand on the machines above; record the
  date and result of the last check in the Verification log below.
- `:monterey` is still an active symbol in Homebrew's `MacOSVersion::SYMBOLS`,
  so `depends_on macos: :monterey` parses. If Homebrew ever retires the
  symbol, `brew audit` will fail in CI and the floor must be revisited.

## Architecture

The table may contain both arm64 (Apple Silicon) and x86_64 (Intel) machines.
Each cask must either ship a universal binary or declare `depends_on arch:`.

| Cask             | Binary        | Checked how                                                  |
|------------------|---------------|--------------------------------------------------------------|
| `conornash-love` | universal     | `file love.app/Contents/MacOS/love` → `[x86_64] [arm64]`, 11.5 |

CI currently runs on arm64 only. Intel is covered by the universal-binary check
above, not by an Intel runner.

## Verification log

Manual checks on machines CI cannot reach. Newest first.

For a Gatekeeper-on machine, "Result" must cover both halves: did `brew bundle
install` succeed, and did the one-time *Open Anyway* approval (README,
"Gatekeeper") let `love --version` run afterwards.

| Date       | Machine        | macOS  | Cask                | Install | Gatekeeper approval | Notes                                   |
|------------|----------------|--------|---------------------|---------|---------------------|-----------------------------------------|
| 2026-10-18 | Kaji           | 26.6.2 | conornash-love 11.5 | OK      | n/a (Gatekeeper off) | `brew install --cask --require-sha`; `love --version` → `LOVE 11.5 (Mysterious Mysteries)`; app confirmed quarantined (`xattr -p`) |
| TODO       | TODO (twin 1)  | 12.x   | conornash-love 11.5 | TODO    | TODO                | `brew bundle install`, launch, approve once, `love --version` |
| TODO       | TODO (twin 2)  | 12.x   | conornash-love 11.5 | TODO    | TODO                |                                         |
