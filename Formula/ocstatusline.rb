class Ocstatusline < Formula
  desc "Live, customizable status line for OpenCode (single-binary push daemon)"
  homepage "https://github.com/MikcleGrok/ocstatusline"
  version "0.2.14"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.14/ocstatusline-darwin-arm64"
      sha256 "1b758c3de0b131f238b6dab1be886cfca07ac36dd0f2d8ca1fedb09649d27fc4"
    else
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.14/ocstatusline-darwin-x64"
      sha256 "a5228ff0e1adb5b5ecf980392783e522e7702ca4b02549f44a64c3d94bdad7b6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.14/ocstatusline-linux-arm64"
      sha256 "28e30c050e8b45425ed788e91d0f0a4b68f00a211da6406e7a443b0fdaa4f01b"
    else
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.14/ocstatusline-linux-x64"
      sha256 "b7c2b3bd2176174cc46252615fd1cbce0d8eb360eca98a9f2a696356bb33d344"
    end
  end

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    bin.install "ocstatusline-#{OS.kernel_name}-#{arch}" => "ocstatusline"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocstatusline --version")
  end
end
