class LibpqAT162Icu4c721 < Formula
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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libpq@16.2-icu4c.72.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "cbc744499fa8a31969f837d1f274ee79df7d93685d6f901ac4fc3e9dccb3be4c"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ff19c8753d70f5a4e044a3eb667b6a6e0f0ea7768d7d94e92887ca8805249482"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1b556c56c024a2be1318890e60dc0205f6812cd2d481760eeeaa9edef218dfce"
    sha256 cellar: :any_skip_relocation, sonoma:         "458d6848158a5778b1c1097c2c1b9741982184be84dab153cc90c29a3e9ee84f"
    sha256 cellar: :any_skip_relocation, monterey:       "b0aad9becfb993ad0ffd3066b9eda5f85fa0b159c1b65efdd0b3c2446bb0abbd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "2b69ff0f90dff06e4289f5089bdd07d5900136b199575b59ef31ff1990ef7c38"
  end

  keg_only "conflicts with postgres formula"

  depends_on "pkg-config" => :build
  depends_on "digitalspacestdio/common/icu4c@72.1"
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