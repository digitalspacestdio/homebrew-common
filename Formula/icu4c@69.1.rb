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
    sha256 cellar: :any_skip_relocation, sonoma:       "a384ee343bbfd21f87cb91bcf0ea3162bf1c9509a30366a94445f6dfee72df2e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d68bce6b8e08d7fc24682aec5afb8b2091739d7c6266c0b090521f455354385d"
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
