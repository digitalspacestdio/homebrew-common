class Icu4cAT701 < Formula
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

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@70.1"
    sha256 cellar: :any_skip_relocation, sonoma: "4c6e7e273edecc09bcf252a8d01053a3a66cd0368af5a2325d3fca501ca5b9f8"
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
