class Edencommon < Formula
  desc "Shared library for Watchman and Eden projects"
  homepage "https://github.com/facebookexperimental/edencommon"
  url "https://github.com/facebookexperimental/edencommon/archive/refs/tags/v2024.04.29.00.tar.gz"
  sha256 "4aa2299b0dc2de5841826c7b903521dffa4c528f689e4db91110fded71f93fc9"
  license "MIT"
  head "https://github.com/facebookexperimental/edencommon.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "a87b5163959d6d4fa9083b0b0775788759caeed77cfb96340194828f7739c8eb"
    sha256 cellar: :any,                 arm64_ventura:  "1f4da008d9d19afa58492b4c5b2dd11f060ce534929cff44be37ca6eb8639629"
    sha256 cellar: :any,                 arm64_monterey: "8e6ee43948614fbf6c855fcde7db293644a2120c3d506735aa351e6358781696"
    sha256 cellar: :any,                 sonoma:         "ad4a2465610abc9337107c351822fa9101d283484b9e88a611cba0e3d405b854"
    sha256 cellar: :any,                 ventura:        "f101c96bfc7adab1e2446ec363c3c78d1625458a80313a98314b898b266b49ef"
    sha256 cellar: :any,                 monterey:       "def2d424178794452438d9b51c75c176a525b6bdd3f11bb47efd458fdd7b83ac"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "bea724452a93add7a69fb6f0303ad9508ac6e9785f102838b053aa3acef5c5bd"
  end

  depends_on "cmake" => :build
  depends_on "googletest" => :build
  depends_on "mvfst" => :build
  depends_on "fb303"
  depends_on "fbthrift"
  depends_on "folly"
  depends_on "gflags"
  depends_on "glog"
  depends_on "libsodium"
  depends_on "openssl@3"
  depends_on "wangle"

  def install
    # Fix "Process terminated due to timeout" by allowing a longer timeout.
    inreplace buildpath.glob("eden/common/{os,utils}/test/CMakeLists.txt"),
              /gtest_discover_tests\((.*)\)/,
              "gtest_discover_tests(\\1 DISCOVERY_TIMEOUT 60)"
    inreplace "eden/common/utils/test/CMakeLists.txt",
              /gtest_discover_tests\((.*)\)/,
              "gtest_discover_tests(\\1 DISCOVERY_TIMEOUT 60)"

    # Avoid having to build FBThrift py library
    inreplace "CMakeLists.txt", "COMPONENTS cpp2 py)", "COMPONENTS cpp2)"

    system "cmake", "-S", ".", "-B", "_build", *std_cmake_args
    system "cmake", "--build", "_build"
    system "cmake", "--install", "_build"
  end

  test do
    (testpath/"test.cc").write <<~EOS
      #include <eden/common/utils/ProcessInfo.h>
      #include <cstdlib>
      #include <iostream>

      using namespace facebook::eden;

      int main(int argc, char **argv) {
        if (argc <= 1) return 1;
        int pid = std::atoi(argv[1]);
        std::cout << readProcessName(pid) << std::endl;
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++17", "-I#{include}", "test.cc",
                    "-L#{lib}", "-L#{Formula["folly"].opt_lib}",
                    "-L#{Formula["boost"].opt_lib}", "-L#{Formula["glog"].opt_lib}", "-L#{Formula["fmt"].opt_lib}",
                    "-ledencommon_utils", "-lfolly", "-lfmt", "-lboost_context-mt", "-lglog", "-o", "test"
    assert_match "ruby", shell_output("./test #{Process.pid}")
  end
end
