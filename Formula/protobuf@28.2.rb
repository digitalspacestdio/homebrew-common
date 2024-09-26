class ProtobufAT282 < Formula
    desc "Protocol buffers (Google's data interchange format)"
    homepage "https://protobuf.dev/"
    url "https://github.com/protocolbuffers/protobuf/releases/download/v28.2/protobuf-28.2.tar.gz"
    sha256 "b2340aa47faf7ef10a0328190319d3f3bee1b24f426d4ce8f4253b6f27ce16db"
    license "BSD-3-Clause"
  
    livecheck do
      url :stable
      strategy :github_latest
    end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/0/protobuf@28.2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "085adb8df69d083492c872529e49089017f29f127d973970ccf9561869ad5161"
  end
  
    depends_on "cmake" => :build
    depends_on "abseil"
    uses_from_macos "zlib"
  
    on_macos do
      # We currently only run tests on macOS.
      # Running them on Linux requires rebuilding googletest with `-fPIC`.
      depends_on "googletest" => :build
    end
  
    patch do
      url "https://github.com/protocolbuffers/protobuf/commit/e490bff517916495ed3a900aa85791be01f674f5.patch?full_index=1"
      sha256 "7e89d0c379d89b24cb6fe795cd9d68e72f0b83fcc95dd91af721d670ad466022"
    end
  
    def install
      # Keep `CMAKE_CXX_STANDARD` in sync with the same variable in `abseil.rb`.
      abseil_cxx_standard = 17
      cmake_args = %W[
        -DBUILD_SHARED_LIBS=ON
        -Dprotobuf_BUILD_LIBPROTOC=ON
        -Dprotobuf_BUILD_SHARED_LIBS=ON
        -Dprotobuf_INSTALL_EXAMPLES=ON
        -Dprotobuf_BUILD_TESTS=#{OS.mac? ? "ON" : "OFF"}
        -Dprotobuf_USE_EXTERNAL_GTEST=ON
        -Dprotobuf_ABSL_PROVIDER=package
        -Dprotobuf_JSONCPP_PROVIDER=package
      ]
      cmake_args << "-DCMAKE_CXX_STANDARD=#{abseil_cxx_standard}"
  
      system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
      system "cmake", "--build", "build"
      system "ctest", "--test-dir", "build", "--verbose" if OS.mac?
      system "cmake", "--install", "build"
  
      (share/"vim/vimfiles/syntax").install "editors/proto.vim"
      elisp.install "editors/protobuf-mode.el"
    end
  
    test do
      testdata = <<~EOS
        syntax = "proto3";
        package test;
        message TestCase {
          string name = 4;
        }
        message Test {
          repeated TestCase case = 1;
        }
      EOS
      (testpath/"test.proto").write testdata
      system bin/"protoc", "test.proto", "--cpp_out=."
    end
  end