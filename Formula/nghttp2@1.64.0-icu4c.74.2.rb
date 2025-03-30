class Nghttp2AT1640Icu4c742 < Formula
    desc "HTTP/2 C Library"
    homepage "https://nghttp2.org/"
    url "https://github.com/nghttp2/nghttp2/releases/download/v1.64.0/nghttp2-1.64.0.tar.gz"
    mirror "http://fresh-center.net/linux/www/nghttp2-1.64.0.tar.gz"
    sha256 "20e73f3cf9db3f05988996ac8b3a99ed529f4565ca91a49eb0550498e10621e8"
    license "MIT"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/nghttp2@1.64.0-icu4c.74.2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "744633e6a73ac23ce8b78db4bf8e3754cb4936289cbf606c6fc1a7859917c4dc"
    sha256 cellar: :any_skip_relocation, ventura:       "74123e60c4a64d3b9fb6ecb26de70c27aabf8ae1ff807fecb0e907b9d54c1793"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2063f2743e96b8a82e977fac5b7aaae35763c9bc31cdc28713e31042901a3823"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "81fffe61b15360da9401627fb5473ef2be603bc03d9ca3d6c85107b6b5034168"
  end
  
    head do
      url "https://github.com/nghttp2/nghttp2.git", branch: "master"
  
      depends_on "autoconf" => :build
      depends_on "automake" => :build
      depends_on "libtool" => :build
    end

    keg_only :versioned_formula
  
    depends_on "pkgconf" => :build
    depends_on "c-ares"
    depends_on "jemalloc"
    depends_on "libev"
    depends_on "libnghttp2"
    depends_on "openssl@3"
  
    uses_from_macos "libxml2@2.12-icu4c.74.2"
    uses_from_macos "zlib"
  
    on_macos do
      # macOS 12 or older
      depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1500
    end
  
    on_linux do
      depends_on "gcc"
    end
  
    fails_with :clang do
      build 1400
      cause "Requires C++20 support"
    end
  
    fails_with :gcc do
      version "11"
      cause "Requires C++20 support"
    end
  
    def install
      ENV.llvm_clang if OS.mac? && DevelopmentTools.clang_build_version <= 1500
  
      # fix for clang not following C++14 behaviour
      # https://github.com/macports/macports-ports/commit/54d83cca9fc0f2ed6d3f873282b6dd3198635891
      inreplace "src/shrpx_client_handler.cc", "return dconn;", "return std::move(dconn);"
  
      # Don't build nghttp2 library - use the previously built one.
      inreplace "Makefile.in", /(SUBDIRS =) lib/, "\\1"
      inreplace Dir["**/Makefile.in"] do |s|
        # These don't exist in all files, hence audit_result being false.
        s.gsub!(%r{^(LDADD = )\$[({]top_builddir[)}]/lib/libnghttp2\.la}, "\\1-lnghttp2", audit_result: false)
        s.gsub!(%r{\$[({]top_builddir[)}]/lib/libnghttp2\.la}, "", audit_result: false)
      end
  
      args = %w[
        --disable-silent-rules
        --enable-app
        --disable-examples
        --disable-hpack-tools
        --disable-python-bindings
        --without-systemd
      ]
  
      system "autoreconf", "--force", "--install", "--verbose" if build.head?
      system "./configure", *args, *std_configure_args
      system "make"
      system "make", "install"
    end
  
    test do
      system bin/"nghttp", "-nv", "https://nghttp2.org"
      refute_path_exists lib
    end
  end
