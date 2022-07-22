# Arbitrary known-good revision for default use.
let
  revision = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:1z28a3gqbv62sxahlssc5a722kh46f26f5ss3arbxpv7a1272vf1";
})
