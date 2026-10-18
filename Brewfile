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

# no_quarantine: the LÖVE macOS build is ad-hoc signed (not notarised). With
# the quarantine attribute set, Gatekeeper refuses to launch it on any machine
# where Gatekeeper is on. This is the deliberate policy decision recorded in
# README.md; it is the only thing that makes the cask usable.
# require_sha: refuse to install any cask that does not pin a sha256.
cask "conornash/tap/conornash-love", args: { no_quarantine: true, require_sha: true }
