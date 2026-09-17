class Ocstatusline < Formula
  desc "Live, customizable status line for OpenCode (single-binary push daemon)"
  homepage "https://github.com/MikcleGrok/ocstatusline"
  version "0.2.16"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/ocstatusline/releases/download/v0.2.16/ocstatusline-darwin-arm64"
      sha256 "36b4b1d048323b1daacb4259c1dc0232e6fdb875c489f3256e9e706688f9fdd5"
    else
      url "https://github.com/MikcleGrok/ocstatusline/releases/download/v0.2.16/ocstatusline-darwin-x64"
      sha256 "074bb4053cd133ca4751dd7d9976498e1ce15e62fa55940d0ebb791d42004ce3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/MikcleGrok/ocstatusline/releases/download/v0.2.16/ocstatusline-linux-arm64"
      sha256 "30f0cdc25eaaba02ce72f6e9cd1800c284ecb01a8384eadfe665fb55bd6228ab"
    else
      url "https://github.com/MikcleGrok/ocstatusline/releases/download/v0.2.16/ocstatusline-linux-x64"
      sha256 "b81993c31f0b1eadefcbe346764fc1902a9c7e63959e3c6f29ebd3845b5028c9"
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
