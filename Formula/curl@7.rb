class CurlAT7 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.79.1.tar.bz2"
  mirror "http://curl.mirror.anstey.ca/curl-7.79.1.tar.bz2"
  sha256 "de62c4ab9a9316393962e8b94777a570bb9f71feb580fb4475e412f2f9387851"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/curl@7"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "c00d4074176551ab4c7447f26225d342092e65f4205f7481f43fb26cac4ebde8"
    sha256 cellar: :any_skip_relocation, ventura:       "85afbdbf2b004bab337bcd1f695f205f399f0a6ac6c5324de2a51debbec27fc1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3fdf04bef43f32f562232ed9f17094ac7ef804e8b6c177ae44741693aca62329"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "395f271b59d2d45811c7ed2120241ef39b83cfa2364595aa5056656f4c96a807"
  end

  pour_bottle? do
    reason "The bottle needs to be installed into #{Homebrew::DEFAULT_PREFIX} when built with OpenSSL."
    satisfy { OS.mac? || HOMEBREW_PREFIX.to_s == Homebrew::DEFAULT_PREFIX }
  end

  head do
    url "https://github.com/curl/curl.git"
    depends_on "openssl111w" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :versioned_formula

  option "with-rtmpdump", "Build with RTMP support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support."

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ares" => "with-c-ares"

  # HTTP/2 support requires OpenSSL 1.0.2+ or LibreSSL 2.1.3+ for ALPN Support
  # which is currently not supported by Secure Transport (DarwinSSL).
#   if MacOS.version < :mountain_lion || build.with?("nghttp2") || build.with?("openssl")
#     depends_on "openssl111w"
#   else
#     option "with-openssl", "Build with OpenSSL instead of Secure Transport"
#     depends_on "openssl111w" => :optional
#   end

  depends_on "brotli"
  depends_on "libidn2"
  depends_on "openssl111w"
  depends_on "pkg-config" => :build
  depends_on "libssh2"
  depends_on "nghttp2"

  depends_on "c-ares" => :optional
  depends_on "rtmpdump" => :optional
  unless OS.mac?
    depends_on "krb5" if build.with? "gssapi"
    depends_on "openldap" => :optional
  end

  ENV['CFLAGS'] = '-I{$(brew --prefix openssl111w)}/include'
  ENV['LDFLAGS'] = '-L$(brew --prefix openssl111w)/lib'

  def install
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
    #       ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl111w"].opt_lib}/pkgconfig"
    #       args << "--with-ssl=#{Formula["openssl111w"].opt_prefix}"
    #       args << "--with-ca-bundle=#{etc}/openssl111w/cert.pem"
    #       args << "--with-ca-path=#{etc}/openssl111w/certs"
    #     else
    #       args << "--with-darwinssl"
    #       args << "--without-ca-bundle"
    #       args << "--without-ca-path"
    #     end

    args << "--with-ssl=#{Formula["openssl111w"].opt_prefix}"
    args << "--with-ca-bundle=#{etc}/openssl111w/cert.pem"
    args << "--with-ca-path=#{etc}/openssl111w/certs"

    args << "--with-libssh2=#{Formula["libssh2"].opt_prefix}"

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
