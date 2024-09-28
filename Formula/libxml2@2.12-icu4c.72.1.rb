class Libxml2AT212Icu4c721 < Formula
  desc "GNOME XML library"
  homepage "http://xmlsoft.org/"
  url "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.6.tar.xz"
  sha256 "889c593a881a3db5fdd96cc9318c87df34eb648edfc458272ad46fd607353fbb"
  license "MIT"

  # We use a common regex because libxml2 doesn't use GNOME's "even-numbered
  # minor is stable" version scheme.
  livecheck do
    url :stable
    regex(/libxml2[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libxml2@2.12-icu4c.72.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "3f3ba8c6218601c79bb6a5d5bad6689094ddb6e9f378953dbd249a5da53ed15d"
    sha256 cellar: :any_skip_relocation, ventura:       "0e66d5347fc2b6678dba3f5ccfe8915c5ffa82d9a418297eda312068e29e9d15"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4f335c9abf3c3a97ede2bd85324f9ca725e42309e31e1b5a6fc29dd7a481a5bb"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "32d8b9a9a6e4b439f3f5c7732007c4c1144b0e5719d6b6ff949a21dab238d88c"
  end

  head do
    url "https://gitlab.gnome.org/GNOME/libxml2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  keg_only :versioned_formula

  depends_on "python-setuptools" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "pkg-config" => :test
  depends_on "digitalspacestdio/common/icu4c@72.1"
  depends_on "readline"

  uses_from_macos "zlib"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", *std_configure_args,
                          "--sysconfdir=#{etc}",
                          "--disable-silent-rules",
                          "--with-history",
                          "--with-icu=#{Formula["digitalspacestdio/common/icu4c@72.1"].opt_prefix}",
                          "--without-python",
                          "--without-lzma"
    system "make", "install"

    cd "python" do
      sdk_include = if OS.mac?
        sdk = MacOS.sdk_path_if_needed
        sdk/"usr/include" if sdk
      else
        HOMEBREW_PREFIX/"include"
      end

      includes = [include, sdk_include].compact.map do |inc|
        "'#{inc}',"
      end.join(" ")

      # We need to insert our include dir first
      inreplace "setup.py", "includes_dir = [",
                            "includes_dir = [#{includes}"

      # Needed for Python 3.12+.
      # https://github.com/Homebrew/homebrew-core/pull/154551#issuecomment-1820102786
      with_env(PYTHONPATH: buildpath/"python") do
        pythons.each do |python|
          system python, "-m", "pip", "install", *std_pip_args, "."
        end
      end
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libxml/tree.h>

      int main()
      {
        xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
        xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "root");
        xmlDocSetRootElement(doc, root_node);
        xmlFreeDoc(doc);
        return 0;
      }
    EOS

    # Test build with xml2-config
    args = shell_output("#{bin}/xml2-config --cflags --libs").split
    system ENV.cc, "test.c", "-o", "test", *args
    system "./test"

    # Test build with pkg-config
    ENV.append "PKG_CONFIG_PATH", lib/"pkgconfig"
    args = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libxml-2.0").split
    system ENV.cc, "test.c", "-o", "test", *args
    system "./test"

    pythons.each do |python|
      with_env(PYTHONPATH: prefix/Language::Python.site_packages(python)) do
        system python, "-c", "import libxml2"
      end
    end
  end
end