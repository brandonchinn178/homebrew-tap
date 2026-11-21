class Hooky < Formula
  desc "Minimal git hooks manager"
  homepage "https://github.com/brandonchinn178/hooky"
  url "https://github.com/brandonchinn178/hooky/archive/refs/tags/v1.0.8.tar.gz"
  sha256 "d806c76542b5e54a41bfb58d0238e5b7a73fb897693da053f17b2b40fa0cec33"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/brandonchinn178/homebrew-tap/releases/download/hooky-1.0.7"
    sha256 cellar: :any, arm64_tahoe:  "453a19d816125bfac323690f3b781c2ac27f0411a2f4a1212074193cbc3197e2"
    sha256 cellar: :any, x86_64_linux: "8fd94a8b64f1c87e9adff8a167268835b72f54800d845c0a90dda3c8067fc334"
  end

  depends_on "ghc@9.12" => :build
  depends_on "haskell-stack" => :build
  depends_on "gmp"
  uses_from_macos "libffi"

  def install
    system "stack", "install", ":hooky",
      "--system-ghc", "--no-install-ghc", "--skip-ghc-check",
      "--local-bin-path=#{bin}"

    [:bash, :fish, :zsh].each do |shell|
      generate_completions_from_executable(
        bin/"hooky", "--#{shell}-completion-script", bin/"hooky",
        shells: [shell], shell_parameter_format: :none
      )
    end
  end

  test do
    (testpath/".hooky.kdl").write <<~EOF
      hook hooky {
        command hooky lint {
          fix_args --fix
        }
        files *
      }
      lint_rules {
        - trailing_whitespace
      }
    EOF
    shell_output("echo 'Hello world with spaces:         ' > #{testpath}/test.txt")
    shell_output("git init")
    shell_output("#{bin}/hooky run test.txt", 1)
    shell_output("#{bin}/hooky fix test.txt", 1)
    shell_output("#{bin}/hooky run test.txt")
  end
end
