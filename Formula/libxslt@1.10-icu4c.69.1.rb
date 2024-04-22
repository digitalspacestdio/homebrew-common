class LibxsltAT110Icu4c691 < Formula
    desc "C XSLT library for GNOME"
    homepage "http://xmlsoft.org/XSLT/"
    url "https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz"
    sha256 "2a20ad621148339b0759c4d4e96719362dee64c9a096dbba625ba053846349f0"
    license "X11"
  
    # We use a common regex because libxslt doesn't use GNOME's "even-numbered
    # minor is stable" version scheme.
    livecheck do
      url :stable
      regex(/libxslt[._-]v?(\d+(?:\.\d+)+)\.t/i)
    end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libxslt@1.10-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "fa57f6c3b6badc728d2923f3bba52aaca15372abce0b12a9361ef1b9039268cb"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "8c94df319c5fcff56ada32bbd744d12ffebed5e877be6c4e2f2228721fdc7880"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "559a45f67f815f766f8dca6731d794b48fb95053b3ec63a4f2715ed6134d3f46"
    sha256 cellar: :any_skip_relocation, sonoma:         "3b57d6dede0e15ded3b8cc84314158ed7d240c919e025f4b2a5c985cd369cc29"
    sha256 cellar: :any_skip_relocation, monterey:       "c4440542db01963bc2b0aa37f118f14009cdb44cb6fc288417805553f4dca9b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "93bee195b091135a01e94a3b179e54b57571a92d7c74e7edf1635423ac4a590a"
  end
  
    head do
      url "https://gitlab.gnome.org/GNOME/libxslt.git", branch: "master"
  
      depends_on "autoconf" => :build
      depends_on "automake" => :build
      depends_on "libtool" => :build
    end
  
    keg_only :versioned_formula
  
    depends_on "digitalspacestdio/common/icu4c@69.1"
    depends_on "libgcrypt"
    depends_on "digitalspacestdio/common/libxml2@2.9-icu4c.69.1"
  
    on_linux do
      depends_on "pkg-config" => :build
    end
  
    def install
      libxml2 = Formula["digitalspacestdio/common/libxml2@2.9-icu4c.69.1"]
      system "autoreconf", "--force", "--install", "--verbose" if build.head?
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}",
                            "--without-python",
                            "--with-crypto",
                            "--with-libxml-prefix=#{libxml2.opt_prefix}"
      system "make"
      system "make", "install"
      inreplace [bin/"xslt-config", lib/"xsltConf.sh"], libxml2.prefix.realpath, libxml2.opt_prefix
    end
  
    def caveats
      <<~EOS
        To allow the nokogiri gem to link against this libxslt run:
          gem install nokogiri -- --with-xslt-dir=#{opt_prefix}
      EOS
    end
  
    test do
      assert_match version.to_s, shell_output("#{bin}/xslt-config --version")
      (testpath/"test.c").write <<~EOS
        #include <libexslt/exslt.h>
        int main(int argc, char *argv[]) {
          exsltCryptoRegister();
          return 0;
        }
      EOS
      flags = shell_output("#{bin}/xslt-config --cflags --libs").chomp.split
      system ENV.cc, "test.c", "-o", "test", *flags, "-lexslt"
      system "./test"
    end
  end