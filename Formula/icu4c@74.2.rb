class Icu4cAT742 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz"
  version "74.2"
  sha256 "68db082212a96d6f53e35d60f47d38b962e9f9d207a74cfac78029ae8ff5e08c"
  license "ICU"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@74.2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "70f1b8348af340aee4b5b6453804374c4c30445e519623cf0d3e3a58d506bd07"
    sha256 cellar: :any_skip_relocation, ventura:       "dc56b346db42e50e63fb737c5a9690e225ddbe94f4d81e7f3fc8d2b41ff31703"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1a747e9fbcb8e1d0b23e4631fa51cf95eb655a30f0d74811f05fbefe13f5eeb1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b598389232fc1e88f1e8d51253e182c32976607de91c0085adb8ed857893030f"
  end

  keg_only :versioned_formula

  def install
    args = %w[
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args, *std_configure_args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.exist? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end