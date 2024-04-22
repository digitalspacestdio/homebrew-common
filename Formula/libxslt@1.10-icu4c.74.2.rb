class LibxsltAT110Icu4c742 < Formula
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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libxslt@1.10-icu4c.74.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "960fad75182a8ccf04e77412e4ef363ae0e09f3dc22fed9f71ee84797b20f028"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5c709705ce485d2b444e3c5d67c2b3df91838d6ae1dc946f0fa83eee5b0bfa17"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c81ee329fcbc2ad90641726d52f4f8e32734af6799210b3cd8d603a9197f2944"
    sha256 cellar: :any_skip_relocation, sonoma:         "3689f241fc9a268ba7de608a98f419626d6f2b95d78bae0ca105d5828dfc3f38"
    sha256 cellar: :any_skip_relocation, monterey:       "22c5e3680315f5b705320fa942bf739869b133dfa83723dbbd0b9c3cde308917"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c8bdb2907a7b29871ed08da03fba28868e623272dbbb5b2a8f2b45f10db41534"
  end
  
    head do
      url "https://gitlab.gnome.org/GNOME/libxslt.git", branch: "master"
  
      depends_on "autoconf" => :build
      depends_on "automake" => :build
      depends_on "libtool" => :build
    end
  
    keg_only :versioned_formula
  
    depends_on "digitalspacestdio/common/icu4c@74.2"
    depends_on "libgcrypt"
    depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.74.2"
  
    on_linux do
      depends_on "pkg-config" => :build
    end
  
    def install
      libxml2 = Formula["digitalspacestdio/common/libxml2@2.12-icu4c.74.2"]
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