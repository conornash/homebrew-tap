# conornash/tap

A personal [Homebrew tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
for software that the official taps will not or cannot carry, installed onto a
small, known set of Macs. The machines, and what "supported" means for each,
are listed in [SUPPORT.md](SUPPORT.md). Read that file before raising any
cask's minimum macOS.

## What is in it

| Cask             | Version | Why it is here                                                                 |
|------------------|---------|--------------------------------------------------------------------------------|
| `conornash-love` | 11.5    | [LÖVE](https://love2d.org/). The `homebrew/cask` `love` cask was disabled on 2026-09-01 (`fails_gatekeeper_check`): upstream's macOS build is ad-hoc signed, not notarised. This is the same cask with the `disable!` line removed. |

Cask tokens are prefixed `conornash-` so they never collide with
`homebrew/cask` tokens (Homebrew's recommendation for third-party casks). An
unqualified `brew install --cask love` would still resolve to the disabled
official cask and fail; `conornash-love` cannot be confused with it.

## Install on one of the supported machines

The intended route is the [Brewfile](Brewfile) in this repository, which
records the tap, per-cask trust, and the install arguments in one place:

```sh
git clone https://github.com/conornash/homebrew-tap.git
brew bundle install --file=homebrew-tap/Brewfile
love --version        # → LOVE 11.5 (Mysterious Mysteries)
```

`brew bundle check --file=homebrew-tap/Brewfile` reports whether a machine has
drifted from the file.

The one-liner equivalent, if you need it:

```sh
brew install --cask --require-sha conornash/tap/conornash-love
```

The fully-qualified name tells Homebrew to tap this repository and to trust
only that one cask, not the whole tap
([tap trust](https://docs.brew.sh/Tap-Trust), required since Homebrew 6.0).

### Gatekeeper — read this

LÖVE's macOS binary is ad-hoc signed: no Developer ID, not notarised. Homebrew
marks every cask download with the `com.apple.quarantine` attribute, and
**there is no opt-out**: `--no-quarantine` was deprecated in Homebrew 4.7,
disabled in 5.0 and deleted in 6.0 with no replacement
([Homebrew/brew#20755](https://github.com/Homebrew/brew/issues/20755)). The
same policy is why the official `love` cask was disabled. This tap does not try
to get around that: the installed app is quarantined, exactly as Homebrew
intends, and the cask's `caveats` (printed at the end of `brew install`, and
by `brew info --cask conornash/tap/conornash-love`) tell the person at the
keyboard what to do next.

What that means on each kind of machine:

- **Gatekeeper off** (`spctl --status` → `assessments disabled`): the app runs
  immediately. Kaji is in this state.
- **Gatekeeper on** (the default; assume this for the boys' Macs): the first
  `love …` or double-click is refused with "cannot be opened because the
  developer cannot be verified" (macOS 12–14) or "Apple could not verify …"
  (macOS 15+). Approve it **once** in the macOS security settings:
  - macOS 12–13: System Preferences → Security & Privacy → General → *Open Anyway*
  - macOS 14+: System Settings → Privacy & Security → scroll to *Security* → *Open Anyway*

  then launch again and confirm. macOS records the approval in the quarantine
  attribute; Homebrew 6 preserves it across `brew upgrade` where it can
  (`Cask::Quarantine.inherit_user_approval!`). For an ad-hoc-signed app the
  signing identity changes with every release, so expect to approve again after
  each version bump.

  **Or** remove the attribute by hand, which is what the caveats print:

  ```sh
  xattr -dr com.apple.quarantine /Applications/love.app
  ```

  Either way, record the outcome in the SUPPORT.md verification log.

This procedure has **not yet been verified on macOS 12**; it is Apple's
documented flow, but the first install on one of the boys' Macs is the test.

The cask deliberately does **not** run that `xattr` command itself (no
`postflight`). Doing so would re-implement the feature Homebrew removed on
purpose and would make a security decision silently on someone else's machine.
Printing the command and letting a person run it keeps the decision with the
person. If that ever changes, it should be a reviewed commit to the cask.

What the tap does guarantee: the download is verified against a pinned sha256
before it is unpacked (`require_sha` in the Brewfile, `sha256` in the cask),
and the archive is the one the LÖVE maintainers publish on GitHub — the same
file every macOS LÖVE user has installed since 2023.

If a future LÖVE release ships a notarised build, delete this section.

## Maintaining

### Bumping a version

1. Edit `version` in `Casks/<token>.rb`.
2. Recompute the hash: `curl -L <url> | shasum -a 256`, and update `sha256`.
3. Push. CI (`.github/workflows/tests.yml`) runs `brew test-bot
   --only-tap-syntax` (readall, audit, style), then installs the cask on a
   `macos-26` runner and checks `love --version`.
4. Check the oldest machine in SUPPORT.md by hand — CI cannot reach macOS 12 —
   and record the result in the verification log there.

`brew livecheck --tap conornash/tap` reports casks whose upstream has moved;
each cask carries a `livecheck` block for this.

### Adding a cask

1. `Casks/conornash-<name>.rb`, with `depends_on macos:` no higher than the
   floor in SUPPORT.md, and a pinned `sha256`.
2. Add the token to the `trusted: { casks: [...] }` list **and** a `cask` line
   in the Brewfile.
3. Add a row to the table above, to the architecture table in SUPPORT.md, and
   an install/smoke-test step to `install-casks` in the workflow.

### What CI does not prove

- macOS 12 (no GitHub runner exists). See SUPPORT.md.
- Intel Macs (the runner is arm64). Covered only by the universal-binary check
  in SUPPORT.md.
- That the app launches on a Gatekeeper-on machine without the step in the
  caveats. CI follows the caveats literally (runs the `xattr` command, then
  `love --version`), which makes the smoke test deterministic whatever the
  runner image's Gatekeeper state (printed via `spctl --status` for the
  record). The *Open Anyway* route is only exercised by hand.

## Layout

```
Brewfile                     the per-machine install contract
Casks/                       one file per cask (flat; shard into Casks/l/… only if it grows)
SUPPORT.md                   supported machines, OS/arch policy, manual verification log
.github/workflows/tests.yml  CI, derived from `brew tap-new`'s template
.github/dependabot.yml       keeps the pinned action SHAs current
```

There is no `Formula/` directory on purpose: formulae would build from source
on the unsupported-macOS machines in SUPPORT.md.
