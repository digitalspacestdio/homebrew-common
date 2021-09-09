class OpenjdkAT13 < Formula
  desc "Development kit for the Java programming language"
  homepage "https://openjdk.java.net/"
  url "https://hg.openjdk.java.net/jdk-updates/jdk13u/archive/jdk-13.0.2+8.tar.bz2"
  version "13.0.2+8"
  sha256 "01059532335fefc5e0e7a23cc79eeb1dc6fea477606981b89f259aa0e0f9abc1"
  revision 2

  keg_only "it shadows the macOS `java` wrapper"

  depends_on "autoconf" => :build
  depends_on "zip"  => :build
  depends_on "unzip"  => :build
  if OS.linux?
  depends_on "gcc@9" => :build
  end

  on_linux do
    depends_on "pkg-config" => :build
  end

  if OS.linux?
    resource "boot-jdk" do
      url "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz"
      sha256 "acc7a6aabced44e62ec3b83e3b5959df2b1aa6b3d610d58ee45f0c21a7821a71"
    end
  else
    resource "boot-jdk" do
      url "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_osx-x64_bin.tar.gz"
      sha256 "08fd2db3a3ab6fb82bb9091a035f9ffe8ae56c31725f4e17d573e48c39ca10dd"
    end
  end

  def install
    boot_jdk_dir = Pathname.pwd/"boot-jdk"
    resource("boot-jdk").stage boot_jdk_dir
    if OS.linux?
        boot_jdk = boot_jdk_dir
        java_options = ENV.delete("_JAVA_OPTIONS")
    else
        boot_jdk = boot_jdk_dir/"Contents/Home"
        java_options = ENV.delete("_JAVA_OPTIONS")
    end

    short_version, _, build = version.to_s.rpartition("+")

    if OS.linux?
        ENV["CC"] = "#{Formula["gcc@9"].opt_prefix}/bin/gcc-9"
        ENV["CXX"] = "#{Formula["gcc@9"].opt_prefix}/bin/g++-9"
    end
    ENV["ZIPEXE"] = "#{Formula["zip"].opt_prefix}/bin/zip"
    ENV["UNZIP"] = "#{Formula["unzip"].opt_prefix}/bin/unzip"

    chmod 0755, "configure"
    system "./configure",
                          "--without-version-pre",
                          "--without-version-opt",
                          "--with-version-build=#{build}",
                          "--with-boot-jdk=#{boot_jdk}",
                          "--with-boot-jdk-jvmargs=#{java_options}",
                          "--with-debug-level=release",
                          "--with-native-debug-symbols=none",
                          "--enable-dtrace=auto",
                          "--with-jvm-variants=server",

                          OS.mac? ? "--with-extra-ldflags=-headerpad_max_install_names" : "",
                          OS.linux? ? "--with-toolchain-type=gcc" : "",

    ENV["MAKEFLAGS"] = "JOBS=#{ENV.make_jobs}"
    ENV["BINUTILS"] = "binutils-2.30"
    ENV["ARCH"] = "amd64"

    system "make", "images"

    libexec.install "build/macosx-x86_64-server-release/images/jdk-bundle/jdk-#{short_version}.jdk" => "openjdk.jdk"
    bin.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/bin/*"]
    include.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/include/*.h"]
    include.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/include/darwin/*.h"]
  end

  def caveats
    <<~EOS
      For the system Java wrappers to find this JDK, symlink it with
        sudo ln -sfn #{opt_libexec}/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    EOS
  end

  test do
    (testpath/"HelloWorld.java").write <<~EOS
      class HelloWorld {
        public static void main(String args[]) {
          System.out.println("Hello, world!");
        }
      }
    EOS

    system bin/"javac", "HelloWorld.java"

    assert_match "Hello, world!", shell_output("#{bin}/java HelloWorld")
  end
end
