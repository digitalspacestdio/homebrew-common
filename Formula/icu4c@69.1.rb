class Icu4cAT691 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz"
  version "69.1"
  sha256 "4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745"
  license "ICU"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@69.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3fdfaae19b37ceaff48e5547c3724c2db1572b1d856631995db468e14bbbb75c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "9116d4e5d671e18cdee733eb4d4e07002c30b5b1ea9c97f560910f3e3c61ee10"
    sha256 cellar: :any_skip_relocation, sonoma:        "fc1ed3fa9ad9f3414685882f89da8171c9f219f57338c330f9f7a0b8ab850a58"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c40b1b40e4df561127bb31b1aeaaff23f0e55adf74966ef15837a8ac46ddcb82"
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
