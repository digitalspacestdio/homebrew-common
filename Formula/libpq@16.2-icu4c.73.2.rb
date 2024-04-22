class LibpqAT162Icu4c732 < Formula
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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libpq@16.2-icu4c.73.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "203971f06ecc17f56c413d03f90b058668ffc6a926a45a0ee1c2f4bdbd89669e"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "68e96cf4624f86509d480b32a12e9bee1ebcce367b0a29df3fe1eb98eecae72f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d8caf5f57342b27539a0b23d54f79d0a1ad31457b303f65dc795d6b73b8246cd"
    sha256 cellar: :any_skip_relocation, sonoma:         "6830b626504a8f64c76f7ee50113d373248f29045b728c23bbb4a12fa596556c"
    sha256 cellar: :any_skip_relocation, monterey:       "f49996e176a2a960dd9cdb4ac2857aaecb9662e6d01f2fa3bd7d7993ef8d9cb7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4a034cb2397fa70c89e3dcf0bce43392a25e956f0d1f7a06a6bd29f8ace6feca"
  end

  keg_only "conflicts with postgres formula"

  depends_on "pkg-config" => :build
  depends_on "digitalspacestdio/common/icu4c@73.2"
  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"
  depends_on "openssl@3"

  uses_from_macos "zlib"

  on_linux do
    depends_on "readline"
  end

  def install
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