class Icu4cAT742 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz"
  version "74.2"
  sha256 "68db082212a96d6f53e35d60f47d38b962e9f9d207a74cfac78029ae8ff5e08c"
  license "ICU"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@74.2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "b2d4dfc4b5456e6c1822f3485e85bfbe487265e0f93d6cf2a6772b39a98e3be6"
    sha256 cellar: :any_skip_relocation, ventura:       "635b5d1a33a5f6f4298349c380417ac0fe2e462d5cac5f3e29cd593ad3c2dbd1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1cce56144305c1dac529d107b4ae327b0e43c2224b1bf4c47e20c9a6d9917145"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4d6ac173368274905bff025eccf68d59834afa0fda1c7bac8dce0ac36b109526"
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