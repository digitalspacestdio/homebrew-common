class Icu4cAT63 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "https://ssl.icu-project.org/files/icu4c/63.1/icu4c-63_1-src.tgz"
  mirror "https://github.com/unicode-org/icu/releases/download/release-63-1/icu4c-63_1-src.tgz"
  version "63.1"
  sha256 "05c490b69454fce5860b7e8e2821231674af0a11d7ef2febea9a32512998cb9d"
  revision 1

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end
