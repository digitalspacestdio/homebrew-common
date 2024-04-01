class Libxml2AT29Icu4c691 < Formula
  desc "GNOME XML library"
  homepage "http://xmlsoft.org/"
  url "http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-2.9.9.tar.gz"
  sha256 "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libxml2@2.9-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "69fa37926f063f77e8a7fa7b9230860f9ebe043aa895018c3df6619be9fde898"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "49a91f56b751e2378cb21984608d96f3940284be9243ab15dcf1fb35898c394f"
    sha256 cellar: :any_skip_relocation, sonoma:        "518f9133018f2ded897a3df7a3d21f48dd7751629194fa936e3611df5eb1e3a1"
    sha256 cellar: :any_skip_relocation, monterey:      "026e1ac59e6ec58f479687e7c3d3b4b52bbfe74d853d1ff7bd65c2cfa16124e5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "554bc374669e7f250978154522ee8712a058e7f3a5c536b65cfe2ad9682b84db"
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