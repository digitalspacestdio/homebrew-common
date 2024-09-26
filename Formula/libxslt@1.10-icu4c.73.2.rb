class LibxsltAT110Icu4c732 < Formula
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
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libxslt@1.10-icu4c.73.2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "9dd144e0174e701da2d1e54f519e994c5b441d6ec14a855da48eed7622ac7c8f"
    sha256 cellar: :any_skip_relocation, ventura:       "b95815ab926b272fc56d7a66ff3d5f143ca8b20cffc24eb4a7ec9e098978e788"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6d3c319259ad4f6b9c15a38b364da6e7f01f4ca0839a542d285cd8f4b996261a"
  end
  
    head do
      url "https://gitlab.gnome.org/GNOME/libxslt.git", branch: "master"
  
      depends_on "autoconf" => :build
      depends_on "automake" => :build
      depends_on "libtool" => :build
    end
  
    keg_only :versioned_formula
  
    depends_on "digitalspacestdio/common/icu4c@73.2"
    depends_on "libgcrypt"
    depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.73.2"
  
    on_linux do
      depends_on "pkg-config" => :build
    end
  
    def install
      libxml2 = Formula["digitalspacestdio/common/libxml2@2.12-icu4c.73.2"]
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