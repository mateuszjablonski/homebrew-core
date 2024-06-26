require "language/node"

class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-13.12.0.tgz"
  sha256 "6ec1299a8ea7099b0fcdb5733a28876ae4bc191c432fc20464f12d053219a4f7"
  license "MIT"
  head "https://github.com/firebase/firebase-tools.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "908a0289c87219ca6623dd8a02d2fafbbd54d3994a5e71c5021535a027d1ac31"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "908a0289c87219ca6623dd8a02d2fafbbd54d3994a5e71c5021535a027d1ac31"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "908a0289c87219ca6623dd8a02d2fafbbd54d3994a5e71c5021535a027d1ac31"
    sha256 cellar: :any_skip_relocation, sonoma:         "f688356d419e3dae28daef3a1d4ce4c6873431cf61bc73be95d3e0882534396d"
    sha256 cellar: :any_skip_relocation, ventura:        "f688356d419e3dae28daef3a1d4ce4c6873431cf61bc73be95d3e0882534396d"
    sha256 cellar: :any_skip_relocation, monterey:       "f688356d419e3dae28daef3a1d4ce4c6873431cf61bc73be95d3e0882534396d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "732328b056cfcd1406e9d4ac5cf7ecde618fccd495098958cb7d733a27379051"
  end

  depends_on "node"

  uses_from_macos "expect" => :test

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
