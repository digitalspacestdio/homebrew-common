class Libxml2AT29Icu4c691 < Formula
  desc "GNOME XML library"
  homepage "http://xmlsoft.org/"
  url "http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-2.9.9.tar.gz"
  sha256 "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libxml2@2.9-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "53bf8952abeebc6211fb39ee7d22e02cd3b5f738ee9c2ddd4fa197f1e0f6d4d8"
    sha256 cellar: :any_skip_relocation, ventura:       "67ba8e4c2b569b8b506a89004e71dcc26360fafe7419b48339933ac62577f2aa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7961b1fbdc696d5ea5ce175e3221903ec4eca9fd1d0dc54a1e05ff71fe93549b"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c66c3efa4f1a3654f3e76a39947ed239683ecd7f772e19921469352a0bb69263"
  end

  head do
    url "https://gitlab.gnome.org/GNOME/libxml2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  depends_on "python-setuptools" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]

  keg_only :versioned_formula

  depends_on "python"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    system "autoreconf", "-fiv" if build.head?

    # Fix build on OS X 10.5 and 10.6 with Xcode 3.2.6
    inreplace "configure", "-Wno-array-bounds", "" if ENV.compiler == :gcc_4_2

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
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

      # # Needed for Python 3.12+.
      # # https://github.com/Homebrew/homebrew-core/pull/154551#issuecomment-1820102786
      # with_env(PYTHONPATH: buildpath/"python") do
      #   pythons.each do |python|
      #     system python, "-m", "pip", "install", *std_pip_args, "."
      #   end
      # end
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
    args = shell_output("#{bin}/xml2-config --cflags --libs").split
    args += %w[test.c -o test]
    system ENV.cc, *args
    system "./test"

    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_path "PYTHONPATH", lib/"python#{xy}/site-packages"
    system "python3", "-c", "import libxml2"
  end
end