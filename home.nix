{ pkgs, lib, ... }:
let
  langs = [
    { name = "Node";    bin = "node";   pkg = pkgs.nodejs;         file = ./hello/hello.js;    run = f: "node ${f}"; }
    { name = "PHP";     bin = "php";    pkg = pkgs.php;            file = ./hello/hello.php;   run = f: "php ${f}"; }
    { name = "Perl";    bin = "perl";   pkg = pkgs.perl;           file = ./hello/hello.pl;    run = f: "perl ${f}"; }
    { name = "Lua";     bin = "lua";    pkg = pkgs.lua;            file = ./hello/hello.lua;   run = f: "lua ${f}"; }
    { name = "Janet";   bin = "janet";  pkg = pkgs.janet;          file = ./hello/hello.janet; run = f: "janet ${f}"; }
    { name = "C";       bin = "clang";  pkg = pkgs.clang;          file = ./hello/hello.c;     run = f: "clang ${f} -o $tmp/c && $tmp/c"; }
    { name = "Go";      bin = "go";     pkg = pkgs.go;             file = ./hello/hello.go;    run = f: "go run ${f}"; }
    { name = "Java";    bin = "java";   pkg = pkgs.jdk21_headless; file = ./hello/Hello.java;  run = f: "java ${f}"; }
    { name = "Python";  bin = "python3"; pkg = pkgs.python3;       file = ./hello/hello.py;    run = f: "python3 ${f}"; }
    { name = "Ruby";    bin = "ruby";   pkg = pkgs.ruby;           file = ./hello/hello.rb;    run = f: "ruby ${f}"; }
    { name = "Guile";   bin = "guile";  pkg = pkgs.guile;          file = ./hello/hello.scm;   run = f: "guile ${f}"; }
    { name = "Tcl";     bin = "tclsh";  pkg = pkgs.tcl;            file = ./hello/hello.tcl;   run = f: "tclsh ${f}"; }
    { name = "AWK";     bin = "gawk";   pkg = pkgs.gawk;           file = ./hello/hello.awk;   run = f: "gawk -f ${f}"; }
    { name = "jq";      bin = "jq";     pkg = pkgs.jq;             file = ./hello/hello.jq;    run = f: "jq -rn -f ${f}"; }
    { name = "Babashka"; bin = "bb";    pkg = pkgs.babashka;       file = ./hello/hello.bb;    run = f: "bb ${f}"; }
    { name = "Lisp";    bin = "sbcl";   pkg = pkgs.sbcl;           file = ./hello/hello.lisp;  run = f: "sbcl --script ${f}"; }
    { name = "Prolog";  bin = "swipl";  pkg = pkgs.swi-prolog;     file = ./hello/hello.pro;   run = f: "swipl ${f}"; }
    { name = "OCaml";   bin = "ocaml";  pkg = pkgs.ocaml;          file = ./hello/hello.ml;    run = f: "ocaml ${f}"; }
    { name = "Rust";    bin = "rustc";  pkg = pkgs.rustc;          file = ./hello/hello.rs;    run = f: "rustc ${f} -o $tmp/r && $tmp/r"; }
    { name = "COBOL";   bin = "cobc";   pkg = pkgs.gnucobol;       file = ./hello/hello.cob;   run = f: "cobc -x -free ${f} -o $tmp/cb && $tmp/cb"; }
    { name = "Pascal";  bin = "fpc";    pkg = pkgs.fpc;            file = ./hello/hello.pas;   run = f: "fpc -v0 ${f} -o$tmp/p && $tmp/p"; }
    { name = "ASM";     bin = "clang";  pkg = pkgs.clang;          file = ./hello/hello.s;     run = f: "clang ${f} -o $tmp/a && $tmp/a"; }
  ];

  helloAll = pkgs.writeShellApplication {
    name = "hello-all";
    excludeShellChecks = [ "SC2016" ];
    runtimeInputs = (map (l: l.pkg) langs) ++ [ pkgs.coreutils ];
    text = ''
      tmp=$(mktemp -d)
      export tmp
      ok=0
      total=0
      check() {
        name=$1; bin=$2; srcfile=$3; cmd=$4
        total=$((total+1))
        printf '\n\033[1;36m━━ %s ━━\033[0m\n' "$name"
        cat "$srcfile"
        printf '\033[2m--- 実行 ---\033[0m\n'
        path=$(readlink -f "$(command -v "$bin")" || true)
        t0=$(date +%s%N)
        out=$(sh -c "$cmd" 2>&1 || true)
        t1=$(date +%s%N)
        ms=$(( (t1 - t0) / 1000000 ))
        printf '%s\n' "$out"
        if [ "$out" = "hello, world" ] && [[ "$path" == /nix/store/* ]]; then
          ok=$((ok+1))
          printf '\033[1;32m✔\033[0m %s ms  %s\n' "$ms" "$path"
        else
          printf '\033[1;31m✘\033[0m %s ms  %s\n' "$ms" "$path"
        fi
        printf '%s\t%s\n' "$name" "$ms" >> "$tmp/times"
      }
      ${lib.concatMapStrings (l: "check ${lib.escapeShellArg l.name} ${l.bin} ${l.file} ${lib.escapeShellArg (l.run l.file)}\n") langs}
      echo
      echo "$ok/$total"
      echo "--- 遅い順 ---"
      sort -t "$(printf '\t')" -k2 -nr "$tmp/times" | head -5
    '';
  };
in
{
  home.username = "admin";
  home.homeDirectory = "/Users/admin";
  home.stateVersion = "25.05";

  home.packages = (map (l: l.pkg) langs) ++ [ helloAll ];

  programs.zsh = {
    enable = true;
    shellAliases.nullpo = "cat ${./nullpo.aa}";
  };
}
