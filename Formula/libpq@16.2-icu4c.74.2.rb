class LibpqAT162Icu4c742 < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/current/libpq.html"
  url "https://ftp.postgresql.org/pub/source/v16.2/postgresql-16.2.tar.bz2"
  sha256 "446e88294dbc2c9085ab4b7061a646fa604b4bec03521d5ea671c2e5ad9b2952"
  license "PostgreSQL"
  revision 1

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libpq@16.2-icu4c.74.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "ba8a88566b4cab695fd7809c8e36fbe380463b223146f68acb5ccaac7cd96e45"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f50a0baadf76abac3ea40f79d5878940871c9d032bbfada8e1705ecfb0002ea5"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "27b43d3d3b59cd11edfa0980809b8f52d51c189faa70e8352026887ff3a19943"
    sha256 cellar: :any_skip_relocation, sonoma:         "6771d889d5a243f9e16d227b7dabfd46a7e765b22c61a8a15d9be878a2d48765"
    sha256 cellar: :any_skip_relocation, monterey:       "51418f1f5b559484a7ae7e32c71570b0e35ac913a72eb26ca649f01d27d902b8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0cbc0420d580626648f65d25cbe05bbc0542dd607b80567d738f77a6dc951ffc"
  end

  keg_only "conflicts with postgres formula"

  depends_on "pkg-config" => :build
  depends_on "digitalspacestdio/common/icu4c@74.2"
  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"
  depends_on "openssl@3"

  uses_from_macos "zlib"

  on_linux do
    depends_on "readline"
  end

  def install
    if Hardware::CPU.arm? && OS.linux?
      ENV.append "USE_SLICING_BY_8_CRC32C", "1"
    end
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-gssapi",
                          "--with-openssl",
                          "--libdir=#{opt_lib}",
                          "--includedir=#{opt_include}"
    dirs = %W[
      libdir=#{lib}
      includedir=#{include}
      pkgincludedir=#{include}/postgresql
      includedir_server=#{include}/postgresql/server
      includedir_internal=#{include}/postgresql/internal
    ]
    system "make"
    system "make", "-C", "src/bin", "install", *dirs
    system "make", "-C", "src/include", "install", *dirs
    system "make", "-C", "src/interfaces", "install", *dirs
    system "make", "-C", "src/common", "install", *dirs
    system "make", "-C", "src/port", "install", *dirs
    system "make", "-C", "doc", "install", *dirs
  end

  test do
    (testpath/"libpq.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <libpq-fe.h>

      int main()
      {
          const char *conninfo;
          PGconn     *conn;

          conninfo = "dbname = postgres";

          conn = PQconnectdb(conninfo);

          if (PQstatus(conn) != CONNECTION_OK) // This should always fail
          {
              printf("Connection to database attempted and failed");
              PQfinish(conn);
              exit(0);
          }

          return 0;
        }
    EOS
    system ENV.cc, "libpq.c", "-L#{lib}", "-I#{include}", "-lpq", "-o", "libpqtest"
    assert_equal "Connection to database attempted and failed", shell_output("./libpqtest")
  end
end