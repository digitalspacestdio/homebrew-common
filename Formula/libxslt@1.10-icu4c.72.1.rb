class LibxsltAT110Icu4c721 < Formula
    desc "C XSLT library for GNOME"
    homepage "http://xmlsoft.org/XSLT/"
    url "https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz"
    sha256 "2a20ad621148339b0759c4d4e96719362dee64c9a096dbba625ba053846349f0"
    license "X11"
    revision 100
  
    # We use a common regex because libxslt doesn't use GNOME's "even-numbered
    # minor is stable" version scheme.
    livecheck do
      url :stable
      regex(/libxslt[._-]v?(\d+(?:\.\d+)+)\.t/i)
    end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libxslt@1.10-icu4c.72.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "e38376b5e466ccd0e67fe8ee7fc1f3202a1f8824c7b743222d2a46ac7d6da7c0"
    sha256 cellar: :any_skip_relocation, ventura:       "c39624fb977c8773159ac322f278694929e6b24a93238aaa0469a4a71bf41301"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "116b42f6b1436576cb41ca9db4518a436a839989794f1af046f67a8b4cf7799a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "49ed15e51b2b3afc1bf0cd87c7f4d93c8e91f79dec10827e2f9bc14500631044"
  end
  
    head do
      url "https://gitlab.gnome.org/GNOME/libxslt.git", branch: "master"
  
      depends_on "autoconf" => :build
      depends_on "automake" => :build
      depends_on "libtool" => :build
    end
  
    keg_only :versioned_formula
  
    depends_on "digitalspacestdio/common/icu4c@72.1"
    depends_on "libgcrypt"
    depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.72.1"
  
    on_linux do
      depends_on "pkg-config" => :build
    end
  
    def install
      libxml2 = Formula["digitalspacestdio/common/libxml2@2.12-icu4c.72.1"]
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