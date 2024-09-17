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
    -v /usr/lib64/libcuda.so:/usr/lib64/libcuda.so:ro \
    -v /usr/lib64/libcuda.so.555.58.02:/usr/lib64/libcuda.so.555.58.02:ro \
    --env-merge "LD_LIBRARY_PATH=/usr/lib64:${LD_LIBRARY_PATH}" \
    localhost/ollama:latest serve
podman create \
    --name=open-webui \
    -v open-webui-data:/data \
    --pod=offline-llm \
    localhost/open-webui:latest serve
