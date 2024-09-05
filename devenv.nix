{inputs, ...}:
{
  perSystem = { config, pkgs, system, ... }: {
    formatter = with pkgs; nixfmt;

    devenv.shells.default = {
      devenv.root = let
        devenvRootFileContent =
          builtins.readFile inputs.devenv-root.outPath;
      in pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

      name = "my-project";

      languages.nix = {
        enable = true;
        lsp.package = with pkgs; nixd;
      };

      pre-commit.hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        statix.enable = true;
      };

      imports = [
        # This is just like the imports in devenv.nix.
        # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
        # ./devenv-foo.nix
      ];

      # https://devenv.sh/reference/options/
      packages = let
        extensions = inputs.nix-vscode-extensions.extensions.${system};
        vscode-ext = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = [
            # extensions.vscode-marketplace.golang.go
            extensions.open-vsx.jnoortheen.nix-ide
            extensions.open-vsx.eamodio.gitlens
          ];
        };
      in [ config.packages.default vscode-ext ];
    };
  };
}