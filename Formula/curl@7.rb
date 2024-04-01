class CurlAT7 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.88.0.tar.bz2"
  mirror "http://curl.mirror.anstey.ca/curl-7.88.0.tar.bz2"
  sha256 "c81f439ed02442f6a9b95836dfb3a98e0c477610ca7b2f4d5aa1fc329543d33f"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/curl@7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9007f52b52811bd510f438c9bafbf96b37a765e84801216352e195fe064d270e"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5309ad02485a33562bea87841920001719ee705796c7422d1b9e153831d537f1"
    sha256 cellar: :any_skip_relocation, sonoma:        "81ee3f55d0c14a1668bed7ad38acce00aeb8bf1186a8ba96058c2008a74555a1"
    sha256 cellar: :any_skip_relocation, monterey:      "9d8649a3e158d761844b46beafcecc8c4b93cfde15c7a1e9feaf85af570c2c5a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e2a73970cdce0e27fae8fb4f7b6b95f14c9f8abef4ff29a476f610ab192ea5d1"
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
  option "with-libssh2", "Build with scp and sftp support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support."
  option "with-nghttp2", "Build with HTTP/2 support (requires OpenSSL)"

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ssh" => "with-libssh2"
  deprecated_option "with-ares" => "with-c-ares"

  depends_on "brotli"
  depends_on "libidn2"
  depends_on "openssl@1.1"
  depends_on "gcc@11" => :build
  depends_on "pkg-config" => :build
  depends_on "c-ares" => :optional
  depends_on "libssh2" => :optional
  depends_on "nghttp2" => :optional
  depends_on "rtmpdump" => :optional
  unless OS.mac?
    depends_on "krb5" if build.with? "gssapi"
    depends_on "openldap" => :optional
  end

  def install
    ENV["CC"] = "#{Formula["gcc@11"].opt_prefix}/bin/gcc-11" if OS.linux?
    ENV["CXX"] = "#{Formula["gcc@11"].opt_prefix}/bin/g++-11" if OS.linux?

    ENV.append "LDFLAGS", "-L#{Formula["openssl@1.1"].opt_prefix}/lib"
    ENV.append "CPPFLAGS", "-I#{Formula["openssl@1.1"].opt_prefix}/include"

    system "./buildconf" if build.head?

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

    args << (build.with?("libssh2") ? "--with-libssh2" : "--without-libssh2")
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
    libexec.install "scripts/mk-ca-bundle.pl"
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
