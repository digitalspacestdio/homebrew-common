class CurlAT7 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.72.0.tar.bz2"
  mirror "http://curl.mirror.anstey.ca/curl-7.72.0.tar.bz2"
  sha256 "ad91970864102a59765e20ce16216efc9d6ad381471f7accceceab7d905703ef"
  version '7.72.0'
  revision 6

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/curl@7"
    sha256 cellar: :any_skip_relocation, monterey:     "463274d03e93f78c9d1c1081c2e6edda33b52990f363bd07dff56928204ae5da"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "45f3b2ab5d1fb94f857f50f3a4de78e9af90055a4c1f9a96b8ec590706cc03fb"
  end

  pour_bottle? do
    reason "The bottle needs to be installed into #{Homebrew::DEFAULT_PREFIX} when built with OpenSSL."
    satisfy { OS.mac? || HOMEBREW_PREFIX.to_s == Homebrew::DEFAULT_PREFIX }
  end

  head do
    url "https://github.com/curl/curl.git"
    depends_on "openssl@1.1" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :versioned_formula

  option "with-rtmpdump", "Build with RTMP support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support."
  option "with-libmetalink", "Build with libmetalink support."
  option "with-nghttp2", "Build with HTTP/2 support (requires OpenSSL)"

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ares" => "with-c-ares"

  # HTTP/2 support requires OpenSSL 1.0.2+ or LibreSSL 2.1.3+ for ALPN Support
  # which is currently not supported by Secure Transport (DarwinSSL).
#   if MacOS.version < :mountain_lion || build.with?("nghttp2") || build.with?("openssl")
#     depends_on "openssl@1.1"
#   else
#     option "with-openssl", "Build with OpenSSL instead of Secure Transport"
#     depends_on "openssl@1.1" => :optional
#   end

  depends_on "brotli"
  depends_on "libidn2"
  depends_on "openssl@1.1"
  depends_on "pkg-config" => :build
  depends_on "c-ares" => :optional
  depends_on "libmetalink" => :optional
  depends_on "libssh2"
  depends_on "nghttp2" => :optional
  depends_on "rtmpdump" => :optional
  unless OS.mac?
    depends_on "krb5" if build.with? "gssapi"
    depends_on "openldap" => :optional
  end

  ENV['CFLAGS'] = '-I$(brew --prefix openssl@1.1)/include'
  ENV['LDFLAGS'] = '-L$(brew --prefix openssl@1.1)/lib'

  def install
    #ENV["CC"] = "#{Formula["gcc"].opt_prefix}/bin/gcc-11"
    #ENV["CXX"] = "#{Formula["gcc"].opt_prefix}/bin/g++-11"

    system "./buildconf" if build.head?

    # Allow to build on Lion, lowering from the upstream setting of 10.8
    ENV.append_to_cflags "-mmacosx-version-min=10.7" if OS.mac? && MacOS.version <= :lion

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]

    # cURL has a new firm desire to find ssl with PKG_CONFIG_PATH instead of using
    # "--with-ssl" any more. "when possible, set the PKG_CONFIG_PATH environment
    # variable instead of using this option". Multi-SSL choice breaks w/o using it.
    #     if MacOS.version < :mountain_lion || build.with?("openssl") || build.with?("nghttp2")
    #       ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
    #       args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    #       args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
    #       args << "--with-ca-path=#{etc}/openssl@1.1/certs"
    #     else
    #       args << "--with-darwinssl"
    #       args << "--without-ca-bundle"
    #       args << "--without-ca-path"
    #     end

    args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
    args << "--with-ca-path=#{etc}/openssl@1.1/certs"

    args << "--with-libssh2"
    args << (build.with?("libmetalink") ? "--with-libmetalink" : "--without-libmetalink")
    args << (build.with?("gssapi") ? "--with-gssapi" : "--without-gssapi")
    args << (build.with?("rtmpdump") ? "--with-librtmp" : "--without-librtmp")

    if build.with? "c-ares"
      args << "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      args << "--disable-ares"
    end
    args << "--disable-ldap" if build.without? "openldap"

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
