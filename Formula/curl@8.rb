class CurlAT8 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  # Don't forget to update both instances of the version in the GitHub mirror URL.
  url "https://curl.se/download/curl-8.7.1.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_7_1/curl-8.7.1.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.7.1.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-8.7.1.tar.bz2"
  sha256 "05bbd2b698e9cfbab477c33aa5e99b4975501835a41b7ca6ca71de03d8849e76"
  license "curl"
  revision 8

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/curl@8"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "c47d472aa43b601bc7ae76ac5104cadb463caeb1818ad77964e30375b38016e4"
    sha256 cellar: :any_skip_relocation, ventura:       "8788c04ba5cad3782541149d45699f8a319e866c5207533b0450e7e56e057714"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b430c9d28ef3a2bc74037f116a6f4803129739df634ba51a9553f309dc70faf0"
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :versioned_formula

  #depends_on "gcc@11" => :build
  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "libidn2"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on "openldap"
  depends_on "openssl@3"
  depends_on "rtmpdump"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "zlib"

  # Fixes `curl: (23) Failed writing received data to disk/application`
  # Remove in next release
  patch do
    url "https://github.com/curl/curl/commit/b30d694a027eb771c02a3db0dee0ca03ccab7377.patch?full_index=1"
    sha256 "da4ae2efdf05169938c2631ba6e7bca45376f1d67abc305cf8b6a982c618df4d"
  end

  def install
    #ENV["CC"] = "#{Formula["gcc@11"].opt_prefix}/bin/gcc-11" if OS.linux?
    #ENV["CXX"] = "#{Formula["gcc@11"].opt_prefix}/bin/g++-11" if OS.linux?

    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(/github\.com/).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
            "Please make sure the URL is correct."
    end

    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-ssl=#{Formula["openssl@3"].opt_prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-secure-transport
      --with-default-ssl-backend=openssl
      --with-libidn2
      --with-librtmp
      --with-libssh2
      --without-libpsl
    ]

    args << if OS.mac?
      "--with-gssapi"
    else
      "--with-gssapi=#{Formula["krb5"].opt_prefix}"
    end

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