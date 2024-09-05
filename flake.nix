{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
  };
    devenv = {
      url = "github:cachix/devenv";
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
