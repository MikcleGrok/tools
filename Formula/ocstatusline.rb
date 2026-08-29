class Ocstatusline < Formula
  desc "Live, customizable status line for OpenCode (single-binary push daemon)"
  homepage "https://github.com/MikcleGrok/ocstatusline"
  version "0.2.13-rc"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.13-rc/ocstatusline-darwin-arm64"
      sha256 "1467b7a0755f52bf1c11340d1ccbef45637b2be851e9e990a8639d1ec8ae0ea0"
    else
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.13-rc/ocstatusline-darwin-x64"
      sha256 "ad0b75e928fa404b4e7fe71729f805d48d4695b0302b330a9f99fac39421e19d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.13-rc/ocstatusline-linux-arm64"
      sha256 "004a3af1438e70c2d1fb11d791cfe3c3c56138725d067a526f2925d769846000"
    else
      url "https://github.com/MikcleGrok/tools/releases/download/ocstatusline-v0.2.13-rc/ocstatusline-linux-x64"
      sha256 "448d7d21adc3006439c5cdb31229554c3cbba4edc8352db3de4a20256f43edfb"
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
