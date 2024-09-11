podman pod create \
    -p 9999:8080 \
    -p 11434:11434 \
    offline-llm
podman create \
    --name=ollama \
    --device nvidia.com/gpu=all \
    --security-opt=label=disable \
    --pod=offline-llm \
    -v ollama:/root/.ollama \
    localhost/ollama:latest serve
podman create \
    --name=open-webui \
    -v open-webui-data:/data \
    --pod=offline-llm \
    localhost/open-webui:latest serve
