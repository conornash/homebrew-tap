# Brewfile for the machines listed in SUPPORT.md.
#
# On a fresh machine:
#   brew bundle install --file=/path/to/this/Brewfile
# To check for drift without changing anything:
#   brew bundle check --file=/path/to/this/Brewfile
#
# Trust is granted per cask, not for the whole tap, so adding a cask here means
# adding it to the `casks:` list below as well. Keep the two in step.

tap "conornash/tap", trusted: { casks: ["conornash-love"] }

# require_sha: refuse to install any cask that does not pin a sha256.
#
# There is no quarantine opt-out: Homebrew removed `--no-quarantine` in 6.0
# (Homebrew/brew#20755) with no replacement. Every cask install is quarantined;
# on a machine with Gatekeeper on, the first launch must be approved once in
# the macOS security settings. See README.md, "Gatekeeper".
cask "conornash/tap/conornash-love", args: { require_sha: true }
