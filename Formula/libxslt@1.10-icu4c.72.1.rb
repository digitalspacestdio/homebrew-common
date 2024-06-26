class LibxsltAT110Icu4c721 < Formula
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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libxslt@1.10-icu4c.72.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "22b5f0e8e4a6a3b0d2b98008b917a186c08cd463d050779ac9e2fcd07dfad48d"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5517990d56a49ba3f0de176bac702ae32ae7426c848c1387be13bf8cad6e2741"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "607c7b64410ba8e881faee8cf02d95bafb0b70ba95974821d54b91f2c9af8474"
    sha256 cellar: :any_skip_relocation, sonoma:         "273a76ed43f6769bac5c931a95b7cce5880e7a70e952dc88bf973ab0929d0588"
    sha256 cellar: :any_skip_relocation, monterey:       "40bb8f0664b9c1d7090e6dee259c8c2c1f39fd2a8b601756374504fd48b065c3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9e641c39bafe9b5a25cb4c6070dfe4d0f4e0f22176d0d4ece0cd242ae3522b76"
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