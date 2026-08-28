class UniChatEngineMattermost < Formula
  desc "Mattermost engine adapter for uni-chat"
  homepage "https://github.com/MikcleGrok/uni-chat-mattermost"
  version "0.1.24"
  release_asset = "uni-chat-engine-mattermost-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/uni-chat-engine-mattermost-v0.1.28/uni-chat-engine-mattermost-0.1.28-darwin-arm64.tar.gz"
    sha256 "bc890f107ae08ff87a23a8c9e57286de35c56758cf96cf0ef3d9d680804896a8"
  end
  depends_on :macos

  def install
    bin.install "uni-chat-engine-mattermost"
  end

  test do
    assert_equal "uni-chat-engine-mattermost #{version}\n", shell_output("#{bin}/uni-chat-engine-mattermost --version")
    assert_match "usage: uni-chat-engine-mattermost", shell_output("#{bin}/uni-chat-engine-mattermost --help")
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/uni-chat-engine-mattermost 2>&1")
    system "codesign", "--verify", "--strict", bin/"uni-chat-engine-mattermost"
  end
end
