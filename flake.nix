{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # my packages
    my-xmobar.url = "github:Hogeyama/xmobar-config";
  };

  outputs = { home-manager, my-xmobar, ... }:
    let
      username = (import ./user.nix).username;
      system = "x86_64-linux";
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Specify the path to your home configuration here
        configuration = { config, pkgs, ... }: import ./home.nix {
          inherit config pkgs;
          my-xmobar = my-xmobar.defaultPackage.${system};
        };

        inherit system username;
        homeDirectory = "/home/${username}";
        # Update the state version as needed.
        # See the changelog here:
        # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
        stateVersion = "21.11";

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
