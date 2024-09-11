# offline-containers


# ollama

Install [nvidia conatiner toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

For modern podman, follow [this](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html).

Specificallty, generate device spec for podman:

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

Running with GPU:

```bash
podman run --device nvidia.com/gpu=all --security-opt=label=disable -it --rm localhost/ollama:latest serve
```
