class OpenrouterModelTracker < Formula
  desc "Regenerate the OpenRouter model comparison document from live data"
  homepage "https://openrouter.ai/"
  license "MIT"
  version "1.16.6"

  on_macos do
    on_arm do
      url "https://github.com/MikcleGrok/tools/releases/download/openrouter-model-tracker-v1.16.6/openrouter-1.16.6-darwin-arm64.tar.gz"
      sha256 "3a10ea24053da88edef8ae205b5c368f6a575fbcfbf4b2cdc0f7429ca28ad2ac"
    end
    on_intel do
      url "https://github.com/MikcleGrok/tools/releases/download/openrouter-model-tracker-v1.16.6/openrouter-1.16.6-darwin-amd64.tar.gz"
      sha256 "14be9e5999fbdcc5f8d8a593289a2b0eba0c7e4858a9cfb8e52543f216fea523"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/MikcleGrok/tools/releases/download/openrouter-model-tracker-v1.16.6/openrouter-1.16.6-linux-arm64.tar.gz"
      sha256 "f9a4cd9f08661b49e7ebea00b82a69f43aae3b3097dedbba3c319db7a80acf1c"
    end
    on_intel do
      url "https://github.com/MikcleGrok/tools/releases/download/openrouter-model-tracker-v1.16.6/openrouter-1.16.6-linux-amd64.tar.gz"
      sha256 "3afb04e520c0ac4bf2f7d153853d3d962c353775e0a22704385482f48f42fe4b"
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
