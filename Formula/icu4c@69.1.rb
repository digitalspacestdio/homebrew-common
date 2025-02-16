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
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a77fe00396a02f4a0e2fe007c752d471bef2fc6e50f5dccac64377364b00bf82"
    sha256 cellar: :any_skip_relocation, ventura:       "20a39508badeb51fe2c0db722ed684d24947eb0611f776150d4e49f5cd48e7cb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4fb4a8702c62503221e806d8f701e3d3e367858749c78573a92d966c710ace43"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "8c211f6ba7b797525d7844736d33ec8973e1a8471cb3a442e77b2fe1aa0e1ead"
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
