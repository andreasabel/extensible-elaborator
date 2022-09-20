# SPDX-FileCopyrightText: 2020 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{ stdenv, lib, pandoc, texlive, biber,
  makeFontsConf, source-serif-pro, source-sans-pro, source-code-pro, inkscape}:
let texlive-combined = texlive.combine { inherit (texlive)
      scheme-basic xetex latexmk
      fontspec koma-script  # ??
      unicode-math # ??
      xcolor # for coloured text
      todonotes # for todo-pop-ups
      biblatex hyperref # for references and links
      beamer # for slides
      listings # for code snippets
      stmaryrd # for horizontal-bar rules
      ulem # for strikethrough
      ; };
    extraTexInputs = [ ];
    extraBuildInputs = [ ];
in stdenv.mkDerivation ({

  name = "extensible-elaborator-slides";
  src = builtins.filterSource
    (path: type: !(builtins.elem (builtins.baseNameOf path) ["main.pdf" "result" "fonts.patch"]))
    ./.;

  nativeBuildInputs =
    [ pandoc texlive-combined biber inkscape] ++  extraBuildInputs;

  patches = [./fonts.patch];

  buildPhase = ''
    make main.pdf
  '';

  installPhase = ''
    mv main.pdf $out
  '';

  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [source-sans-pro source-code-pro source-serif-pro]; };

  TEXINPUTS =
    builtins.concatStringsSep ":" ([ "." ] ++ extraTexInputs ++ [ "" ]);
})
