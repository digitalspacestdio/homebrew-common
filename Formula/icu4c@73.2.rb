class Icu4cAT732 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-src.tgz"
  version "73.2"
  sha256 "818a80712ed3caacd9b652305e01afc7fa167e6f2e94996da44b90c2ab604ce1"
  license "ICU"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@73.2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "46bcc5b49abaa009522b25d88752a5847772f20d0d8bfd2563558e664212bfb6"
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
      system "./configure", *std_configure_args, *args
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