class Icu4cAT691 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-70-1/icu4c-70_1-src.tgz"
  version "70.1"
  sha256 "8d205428c17bf13bb535300669ed28b338a157b1c01ae66d31d0d3e2d47c3fd5"
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
