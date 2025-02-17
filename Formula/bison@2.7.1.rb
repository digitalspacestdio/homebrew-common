class BisonAT271 < Formula
    desc "Parser generator"
    homepage "https://www.gnu.org/software/bison/"
    url "https://ftp.gnu.org/gnu/bison/bison-2.7.1.tar.gz"
    mirror "https://ftpmirror.gnu.org/bison/bison-2.7.1.tar.gz"
    sha256 "08e2296b024bab8ea36f3bb3b91d071165b22afda39a17ffc8ff53ade2883431"
    license "GPL-3.0-or-later"
    revision 1

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/bison@2.7.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "047bf9ac2c1bfe964138d5b275868099ad981f24a274d2fda8405190e3f28749"
  end
  
    keg_only :versioned_formula
  
    uses_from_macos "m4"
  
    patch :p0 do
      on_high_sierra :or_newer do
        url "https://raw.githubusercontent.com/macports/macports-ports/b76d1e48dac/editors/nano/files/secure_snprintf.patch"
        sha256 "57f972940a10d448efbd3d5ba46e65979ae4eea93681a85e1d998060b356e0d2"
      end
    end
  
    def install
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  
    test do
      (testpath/"test.y").write <<~EOS
        %{ #include <iostream>
           using namespace std;
           extern void yyerror (char *s);
           extern int yylex ();
        %}
        %start prog
        %%
        prog:  //  empty
            |  prog expr '\\n' { cout << "pass"; exit(0); }
            ;
        expr: '(' ')'
            | '(' expr ')'
            |  expr expr
            ;
        %%
        char c;
        void yyerror (char *s) { cout << "fail"; exit(0); }
        int yylex () { cin.get(c); return c; }
        int main() { yyparse(); }
      EOS
  
      system bin/"bison", "test.y"
      system ENV.cxx, "test.tab.c", "-o", "test"
      assert_equal "pass", shell_output("echo \"((()(())))()\" | ./test")
      assert_equal "fail", shell_output("echo \"())\" | ./test")
    end
  end