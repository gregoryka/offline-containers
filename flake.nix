{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";
    devenv-root = {
        url = "file+file:///dev/null";
        flake = false;
    };
      devenv = {
        url = "github:cachix/devenv";
    };
    nix-vscode-extensions = {
        url = "github:nix-community/nix-vscode-extensions";
        inputs = {
            nixpkgs.follows = "nixpkgs";
            flake-utils.follows = "flake-utils";
        };
    };
  };


  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = import inputs.systems;
      imports = [
        inputs.devenv.flakeModule
        ./devenv.nix
      ];

      flake.nix-dev-home.username = "gregorykanter";
    };
}
