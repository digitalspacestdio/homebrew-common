class Icu4cAT671 < Formula
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
end
