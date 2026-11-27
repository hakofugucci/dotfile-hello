{ pkgs, ... }:
let
  helloAll = pkgs.writeShellApplication {
    name = "hello-all";
    runtimeInputs = with pkgs; [ nodejs php perl lua janet clang go jdk21_headless ];
    text = ''
      tmp=$(mktemp -d)
      ok=0
      total=0
      check() {
        name=$1; bin=$2; shift 2
        total=$((total+1))
        path=$(readlink -f "$(command -v "$bin")")
        out=$("$@" 2>&1 || true)
        if [ "$out" = "hello, world" ] && [[ "$path" == /nix/store/* ]]; then
          ok=$((ok+1))
          printf '✔ %-8s %s\n' "$name" "$out"
        else
          printf '✘ %-8s %s (%s)\n' "$name" "$out" "$path"
        fi
      }
      check Node  node  node ${./hello/hello.js}
      check PHP   php   php ${./hello/hello.php}
      check Perl  perl  perl ${./hello/hello.pl}
      check Lua   lua   lua ${./hello/hello.lua}
      check Janet janet janet ${./hello/hello.janet}
      check C     clang sh -c "clang ${./hello/hello.c} -o $tmp/c && $tmp/c"
      check Go    go    go run ${./hello/hello.go}
      check Java  java  java ${./hello/Hello.java}
      echo "$ok/$total"
    '';
  };
in
{
  home.username = "admin";
  home.homeDirectory = "/Users/admin";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [ nodejs php perl lua janet clang go jdk21_headless helloAll ];

  programs.zsh = {
    enable = true;
    shellAliases.nullpo = "cat ${./nullpo.aa}";
  };
}
