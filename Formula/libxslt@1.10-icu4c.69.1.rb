class LibxsltAT110Icu4c691 < Formula
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
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libxslt@1.10-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "1bba5b292602cf370914bc47b6e525610881295169e13d595f165142f6878363"
    sha256 cellar: :any_skip_relocation, ventura:       "c7c90a771f2d8fa0edce9253853a3b7908eac6b18519b28344ef14e577023e75"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "471c3cf10ee6ef2f8670f316575d798411588cb36c7d78202a512310fc62d9ee"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "878404ca2151445f8c77a3ad2b4a7f055a230c2381ee831d2f779a7e2eb5ce34"
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