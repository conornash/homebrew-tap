cask "conornash-love" do
  version "11.5"
  sha256 "6795bb3a1656af6a2fdfe741e150787b481886d3a280327a261a3fdded586913"

  url "https://github.com/love2d/love/releases/download/#{version}/love-#{version}-macos.zip"
  name "LÖVE"
  desc "2D game framework for Lua"
  homepage "https://love2d.org/"

  # Why this tap carries its own copy:
  # The homebrew/cask `love` cask was disabled on 2026-09-01 with
  # `because: :fails_gatekeeper_check`. The upstream 11.5 macOS build is
  # ad-hoc signed (no Developer ID, not notarised), so Homebrew will not ship it.
  # Nothing is wrong with the binary itself. Homebrew 6 quarantines the install
  # and has no opt-out; on a Gatekeeper-on machine the first launch must be
  # approved once in the macOS security settings. See README.md, "Gatekeeper".
  #
  # Upstream minimum macOS is 10.11 (LSMinimumSystemVersion in Info.plist).
  # The floor below is this tap's support policy, not LÖVE's limit: see SUPPORT.md.
  livecheck do
    url :url
    strategy :github_latest
  end

  # A bare symbol means "this version or newer".
  depends_on macos: :monterey

  app "love.app"
  binary "#{appdir}/love.app/Contents/MacOS/love"

  zap trash: "~/Library/Saved Application State/org.love2d.love.savedState"
end
