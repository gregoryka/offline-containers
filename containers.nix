{ inputs, ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      packages =
        let
          pkgsCuda = import inputs.nixpkgs {
            inherit system;
            # Ensure dependencies use CUDA consistently (e.g. that openmpi, ucc,
            # and ucx are built with CUDA support)
            config = {
              cudaSupport = true;
              allowUnfreePredicate =
                p:
                builtins.all (
                  license:
                  license.free
                  || builtins.elem license.shortName [
                    "CUDA EULA"
                    "cuDNN EULA"
                  ]
                ) (p.meta.licenses or [ p.meta.license ]);
            };
          };
          nix2containerPkgs = inputs'.nix2container.packages;
          create_dir =
            dir:
            pkgs.runCommandLocal "create-dir-${dir}" { } ''
              mkdir -p $out/${dir}
            '';
        in
        {
          open-webui = nix2containerPkgs.nix2container.buildImage {
            name = "localhost/open-webui";
            tag = "latest";
            copyToRoot = create_dir "data";
            config = {
              # open-webui by default tries to create a DB at the nix store, which is read only
              # So set DATA_DIR to override it.
              Env = [
                "DATA_DIR=/data"
                # TODO enable cuda for webui - opencv breaks currently and selective override is hard
                # "USE_CUDA_DOCKER=true"
              ];
              WorkingDir = "/data";
              entrypoint = [ "${pkgs.open-webui}/bin/open-webui" ];
            };
            maxLayers = 100;
          };

          ollama = nix2containerPkgs.nix2container.buildImage {
            name = "localhost/ollama";
            tag = "latest";
            # ollama requires /tmp to extract runners
            copyToRoot = create_dir "tmp";
            config = {
              Env = [
                # Models are stored in $HOME/.ollama, so ensure HOME is set
                "HOME=/root"
                # Ensure ollama can talk to ollama servers to download models
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
              entrypoint =
                let
                  cuda_ollama = pkgsCuda.ollama.override { acceleration = "cuda"; };
                in
                [ "${cuda_ollama}/bin/ollama" ];
            };
            maxLayers = 100;
            layers = [
              (nix2containerPkgs.nix2container.buildLayer {
                # ollama embeds runners into the main executable,
                # which breaks the nix model of scanning execuatbles for libraries to determine dependencies
                # thus, manually add cuda dependencies
                deps = [
                  pkgsCuda.cudaPackages.cuda_cudart.lib
                  pkgsCuda.cudaPackages.libcublas.lib
                ];
              })
            ];
          };
        };
    };
}
