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
brew install --cask --no-quarantine --require-sha conornash/tap/conornash-love
```

The fully-qualified name tells Homebrew to tap this repository and to trust
only that one cask, not the whole tap
([tap trust](https://docs.brew.sh/Tap-Trust), required since Homebrew 6.0).

### Gatekeeper policy — read this

LÖVE's macOS binary is not signed with a Developer ID and is not notarised.
Homebrew normally marks every cask download with the `com.apple.quarantine`
attribute; on a Mac with Gatekeeper enabled, an unsigned quarantined app is
refused with "Apple could not verify …" and there is no supported way past it
on current macOS. **This tap therefore installs LÖVE with `--no-quarantine`.**
That is a deliberate decision to run an unsigned upstream binary, recorded here
so it is a policy rather than an accident:

- The download is verified against a pinned sha256 before it is unpacked
  (`require_sha` in the Brewfile, `sha256` in the cask).
- The pinned archive is the one published by the LÖVE maintainers on their
  GitHub releases page, the same file every macOS LÖVE user has installed since
  2023.
- No package manager can fix this. The only Gatekeeper-clean alternative is
  building LÖVE from source on each machine, which needs Xcode and about ten
  native dependencies; it is not worth it for these machines.

If a future LÖVE release ships a notarised build, drop `no_quarantine` from the
Brewfile and the CI install step, and delete this section.

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
- That `--no-quarantine` was used. `brew bundle` honours the Brewfile's `args`;
  a hand-typed `brew install` without the flag will install an app that will
  not launch on a Gatekeeper-on machine.

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
