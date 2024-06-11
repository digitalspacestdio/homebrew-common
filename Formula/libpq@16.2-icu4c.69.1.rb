class LibpqAT162Icu4c691 < Formula
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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libpq@16.2-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "d4dc490f29afc152f13e8d3e6dcd6c355e32688a86a8fcfde8964e7cd28a3611"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f6bbea45d759b51e71e5ae7154763a1d0e592bbcea205d14685fb31838ebad5b"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5250c6fafe27cadb46cbf821cbd30057336b768b4574d34b0d0397f3f6e1806b"
    sha256 cellar: :any_skip_relocation, sonoma:         "8bbba26f10a3ef6362fb8fca386eb3e2967b46699cb1a5bb44c06c70eec77f6f"
    sha256 cellar: :any_skip_relocation, monterey:       "b1833e15663364cf259221d95cd1ea52be73571b912e0049dda1b1782874543a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4f6e270fb325893819f21764e3e4c499bd3f69273747558726c4adbf6f1804ab"
  end

  keg_only "conflicts with postgres formula"

  depends_on "pkg-config" => :build
  depends_on "digitalspacestdio/common/icu4c@69.1"
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