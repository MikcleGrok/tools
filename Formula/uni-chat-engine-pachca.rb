class UniChatEnginePachca < Formula
  desc "Pachca engine adapter for uni-chat"
  homepage "https://github.com/MikcleGrok/uni-chat-pachca"
  version "1.1.19"
  release_asset = "uni-chat-engine-pachca-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_PACHCA_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_PACHCA_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/uni-chat-engine-pachca-v1.1.27/uni-chat-engine-pachca-1.1.27-darwin-arm64.tar.gz"
    sha256 "8fd9cd2b7cfb8583723d650564b2f4641c417619ea0fa0a27a0afe0e00fbd850"
  end
  depends_on :macos

  def install
    bin.install "uni-chat-engine-pachca"
  end

  test do
    assert_equal "uni-chat-engine-pachca #{version}\n", shell_output("#{bin}/uni-chat-engine-pachca --version")
    assert_match "usage: uni-chat-engine-pachca", shell_output("#{bin}/uni-chat-engine-pachca --help")
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/uni-chat-engine-pachca 2>&1")
    system "codesign", "--verify", "--strict", bin/"uni-chat-engine-pachca"
  end
end
