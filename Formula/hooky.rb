class Hooky < Formula
  desc "Minimal git hooks manager"
  homepage "https://github.com/brandonchinn178/hooky"
  url "https://github.com/brandonchinn178/hooky/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "c16d2443f6962ce0c22df73d510f1720d55a77d46734801a665940688a09193c"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/brandonchinn178/homebrew-tap/releases/download/hooky-1.0.1"
    sha256 cellar: :any,                 arm64_tahoe:  "d7f6501aed8f09419f4ec8fccf05c1fe68917d1e9d788b48a8215f5c9271dad1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "369ea631567cddd7f96f1f755947c4c03817c1029f563eba7befb739a16946f4"
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
