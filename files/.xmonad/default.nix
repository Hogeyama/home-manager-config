{ pkgs, compiler }:
let
  src = pkgs.lib.sourceByRegex ./. [
    ".*.hs"
    ".*.cabal"
    "cabal.project"
    "README.md"
    "CHANGELOG.md"
    "LICENSE"
  ];
  haskPkgs = pkgs.haskell.packages.${compiler}.override {
    overrides = haskellPackagesNew: haskellPackagesOld: {
      xmonad = haskellPackagesOld.xmonad_0_17_0;
      xmonad-contrib = haskellPackagesOld.xmonad-contrib_0_17_0;
      xmobar = haskellPackagesOld.xmobar.overrideAttrs
        (old: { configureFlags = "-f all_extensions"; });
    };
  };
  drv = (haskPkgs.callCabal2nix "xmonad-config" src { });
in drv
