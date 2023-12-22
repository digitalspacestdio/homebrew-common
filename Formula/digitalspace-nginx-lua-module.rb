class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"

  depends_on "luajit-openresty"
  depends_on "denji/nginx/ngx-devel-kit"
  depends_on "openresty/brew/openresty"

  def install
    pkgshare.install Dir["*"]
  end

  def post_install
    # configure script tries to write that file and fails
    # seems to be empty anyways, this hack makes compile succeed
    system "touch",  "#{pkgshare}/src/ngx_http_lua_autoconf.h"
  end
end