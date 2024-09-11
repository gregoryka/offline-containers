# offline-containers


# ollama

Install [nvidia conatiner toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

For modern podman, follow [this](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html).

Specificallty, generate device spec for podman:

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

Generate container:
```bash
nix build '.#ollama.copyToPodman' && ./result/bin/copy-to-podman
```

See [nix2container](https://github.com/nlewo/nix2container) for copying the container to other sources

Running with GPU:

```bash
podman run --device nvidia.com/gpu=all --security-opt=label=disable -it --rm localhost/ollama:latest serve
```
