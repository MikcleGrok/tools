class OpenrouterModelTracker < Formula
  desc "Regenerate the OpenRouter model comparison document from live data"
  homepage "https://openrouter.ai/"
  license "MIT"
  version "1.18.5"

  on_macos do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.18.5/openrouter-1.18.5-darwin-arm64.tar.gz"
      sha256 "97ce51a606cc5a7abd1cc099d7f4eca5516dac5495bb162ca1cd365f941b6834"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.18.5/openrouter-1.18.5-darwin-amd64.tar.gz"
      sha256 "310870ad730d0f160344254fce2cec012c68543abc7f79a284ca9f882a0e9ce9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.18.5/openrouter-1.18.5-linux-arm64.tar.gz"
      sha256 "8b908109cb61e663ef1da864c823cfe5664ce0b48971bc375ef539c3c75611cf"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.18.5/openrouter-1.18.5-linux-amd64.tar.gz"
      sha256 "abd5763d60e4a80b4b06ba9adeb818539196353bca46847896026ab7ea9f9763"
    end
  end

  def install
    bin.install Dir["openrouter-*"].first => "openrouter-model-tracker"
    bin.install_symlink "openrouter-model-tracker" => "omt"

    generate_completions_from_executable(bin/"openrouter-model-tracker", shell_parameter_format: :cobra,
                                                                         shells:                 [:bash])

    # Cobra derives the `complete -F <func> <name>` registration in the
    # generated script from the root command's `Use:` ("openrouter"), not
    # from the name(s) this formula actually installs the binary under, so
    # neither real invocation name works out of the box. Append explicit
    # registrations for both `openrouter-model-tracker` and `omt` onto the
    # same completion function the generated script defines.
    completion_script = bash_completion/"openrouter-model-tracker"
    completion_script.write(<<~BASH, mode: "a")

      if [[ $(type -t compopt) = "builtin" ]]; then
          complete -o default -F __start_openrouter openrouter-model-tracker
          complete -o default -F __start_openrouter omt
      else
          complete -o default -o nospace -F __start_openrouter openrouter-model-tracker
          complete -o default -o nospace -F __start_openrouter omt
      fi
    BASH

    # bash-completion's dynamic loader finds a script by the exact command
    # name being completed, so `omt` needs its own filename too.
    bash_completion.install_symlink "openrouter-model-tracker" => "omt"
  end

  test do
    assert_equal "openrouter #{version}\n", shell_output("#{bin}/openrouter-model-tracker version")
    assert_equal "openrouter version #{version}\n", shell_output("#{bin}/openrouter-model-tracker --version")
    system bin/"openrouter-model-tracker", "--help"
    assert_predicate bin/"omt", :symlink?
    assert_equal "openrouter version #{version}\n", shell_output("#{bin}/omt --version")
  end
end
