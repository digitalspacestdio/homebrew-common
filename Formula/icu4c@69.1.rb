class Icu4cAT691 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz"
  version "69.1"
  sha256 "4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745"
  license "ICU"

  livecheck do
    url :stable
    regex(/^release[._-]v?(\d+(?:[.-]\d+)+)$/i)
    strategy :git do |tags, regex|
        tags.map { |tag| tag[regex, 1]&.gsub("-", ".") }.compact
    end
  end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@69.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3fdfaae19b37ceaff48e5547c3724c2db1572b1d856631995db468e14bbbb75c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "088401115094e9b7e4ba7f14735562ffb85acd64b668703586738a56d4ddb927"
    sha256 cellar: :any_skip_relocation, sonoma:        "fc1ed3fa9ad9f3414685882f89da8171c9f219f57338c330f9f7a0b8ab850a58"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d68bce6b8e08d7fc24682aec5afb8b2091739d7c6266c0b090521f455354385d"
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
