{ pkgs, ... }:
let
  src = {
  js     = ./hello/hello.js;
  php    = ./hello/hello.php;
  pl     = ./hello/hello.pl;
  lua    = ./hello/hello.lua;
  janet  = ./hello/hello.janet;
  c      = ./hello/hello.c;
  go     = ./hello/hello.go;
  java   = ./hello/Hello.java;
  };

  helloAll = pkgs.writeShellApplication {
    name = "hello-all";
    runtimeInputs = with pkgs; [ nodejs php perl lua janet clang go jdk21_headless ];
    text = ''
      tmp=$(mktemp -d)
      ok=0
      total=0
      check() {
        name=$1; bin=$2; src=$3; cmd=$4
        total=$((total+1))
        printf '\n\033[1;36m━━ %s ━━\033[0m\n' "$name"
        cat "$src"
        printf '\033[2m--- 実行 ---\033[0m\n'
        path=$(readlink -f "$(command -v "$bin")" || true)
        out=$(sh -c "$cmd" 2>&1 || true)
        printf '%s\n' "$out"
        if [ "$out" = "Hello, World!" ] && [[ "$path" == /nix/store/* ]]; then
          ok=$((ok+1)); printf '\033[1;32m✔\033[0m %s\n' "$path"
        else
          printf '\033[1;31m✘\033[0m %s\n' "$path"
        fi
      }
      check Node  node  ${src.js}    "node ${src.js}"
      check PHP   php   ${src.php}   "php ${src.php}"
      check Perl  perl  ${src.pl}    "perl ${src.pl}"
      check Lua   lua   ${src.lua}   "lua ${src.lua}"
      check Janet janet ${src.janet} "janet ${src.janet}"
      check C     clang ${src.c}     "clang ${src.c} -o $tmp/c && $tmp/c"
      check Go    go    ${src.go}    "go run ${src.go}"
      check Java  java  ${src.java}  "java ${src.java}"
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
    shellAliases.nullpo = "cat ${src../nullpo.aa}";
  };
}

