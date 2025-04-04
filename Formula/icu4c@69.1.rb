class Icu4cAT691 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz"
  version "69.1"
  sha256 "4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745"
  license "ICU"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@69.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7f8fc233155f42208cd6b4621ad474e4e5dd7bfb8fb8a78212b8e56b0c3a3de6"
    sha256 cellar: :any_skip_relocation, ventura:       "d5de0279f6194995643e1f313d8d3b8099129480fa4d49c8b9a2fe75afb0b56a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ea1dc961d6b3dd9757e9677a81ab98249623ead9160bba3f7f1ed039ca650d8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "dcd8f8d5fc16405bc463866fff575630fa8f97232eaaa3c23dd035531d3606bc"
  end

  keg_only :versioned_formula

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
    if File.exist? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end
