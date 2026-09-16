class OpenrouterModelTracker < Formula
  desc "Regenerate the OpenRouter model comparison document from live data"
  homepage "https://openrouter.ai/"
  license "MIT"
  on_macos do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.22.0/openrouter-1.22.0-darwin-arm64.tar.gz"
      sha256 "2e95e8cc0ccd9b6f03c2a65a82b73d5e339d4c75be9bc8dc3332f7864835fa4e"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.22.0/openrouter-1.22.0-darwin-amd64.tar.gz"
      sha256 "22e2b22529ae280e78ff7e4eb286fa8151b8e1adb357f8faab9dd78258562085"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.22.0/openrouter-1.22.0-linux-arm64.tar.gz"
      sha256 "8b8d6c255799cfceb05cbdc166712159da260bfe94229e27ce61a820cf7125d3"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.22.0/openrouter-1.22.0-linux-amd64.tar.gz"
      sha256 "a5a6f47c85852daec42fa4900e982045de5b0d7fbf8455159d5aa348506712c8"
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
