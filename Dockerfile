# ============================================================
# KI Avatar Studio — Custom ComfyUI Worker
# EchoMimic V3 (Videos) + ReActor (Face-Swap) + Flux.1-dev (Bilder)
# Base: RunPod worker-comfyui 5.8.5
# ============================================================
FROM runpod/worker-comfyui:5.8.5-base AS base

# ============================================================
# 1. Custom Nodes installieren
# ============================================================

# EchoMimic V3 — Bild + Audio → Video mit Lip-Sync + Gestik
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/smthemex/ComfyUI_EchoMimic.git && \
    cd ComfyUI_EchoMimic && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --no-deps facenet-pytorch && \
    pip install --no-cache-dir retina-face==0.0.17

# ReActor — Face-Swap (Lindas Gesicht auf echte Videos)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor.git && \
    cd ComfyUI-ReActor && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir onnxruntime-gpu insightface

# VideoHelperSuite — Video-Output (VHS_VideoCombine)
RUN comfy-node-install comfyui-videohelpersuite

# ============================================================
# 2. EchoMimic V3 Models (~7 GB)
# ============================================================

# V3 Preview Transformer (3.41 GB)
RUN mkdir -p /comfyui/models/echo_mimic/transformer && \
    wget -q --show-progress -O /comfyui/models/echo_mimic/transformer/diffusion_pytorch_model.safetensors \
    "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/transformer/diffusion_pytorch_model.safetensors" && \
    wget -q -O /comfyui/models/echo_mimic/transformer/config.json \
    "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/transformer/config.json"

# V3 Flash-Pro Transformer (3.73 GB) — schnellere Inferenz
RUN mkdir -p /comfyui/models/echo_mimic/echomimicv3-flash-pro && \
    wget -q --show-progress -O /comfyui/models/echo_mimic/echomimicv3-flash-pro/diffusion_pytorch_model.safetensors \
    "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/echomimicv3-flash-pro/diffusion_pytorch_model.safetensors" && \
    wget -q -O /comfyui/models/echo_mimic/echomimicv3-flash-pro/config.json \
    "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/echomimicv3-flash-pro/config.json"

# ============================================================
# 3. Wan2.1 VAE (508 MB)
# ============================================================
RUN comfy model download \
    --url "https://huggingface.co/alibaba-pai/Wan2.1-Fun-V1.1-1.3B-InP/resolve/main/Wan2.1_VAE.pth" \
    --relative-path models/vae \
    --filename Wan2.1_VAE.pth

# ============================================================
# 4. Audio Encoder — wav2vec2-base-960h (380 MB)
# ============================================================
RUN mkdir -p /comfyui/models/echo_mimic/wav2vec2-base-960h && \
    cd /comfyui/models/echo_mimic/wav2vec2-base-960h && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/model.safetensors" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/preprocessor_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/feature_extractor_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/special_tokens_map.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/tokenizer_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/vocab.json"

# ============================================================
# 5. CLIP Text Encoder — umt5_xxl fp8 (4.9 GB)
# ============================================================
RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    --relative-path models/clip \
    --filename umt5_xxl_fp8_e4m3fn_scaled.safetensors

# ============================================================
# 6. CLIP Vision Encoder (1.26 GB)
# ============================================================
RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
    --relative-path models/clip_vision \
    --filename clip_vision_h.safetensors

# ============================================================
# 7. Face Detection — RetinaFace (113 MB)
# ============================================================
RUN mkdir -p /comfyui/models/echo_mimic/.deepface/weights && \
    wget -q -O /comfyui/models/echo_mimic/.deepface/weights/retinaface.h5 \
    "https://github.com/serengil/deepface_models/releases/download/v1.0/retinaface.h5"

# ============================================================
# 8. ReActor Models — Face-Swap (~900 MB)
# ============================================================
RUN mkdir -p /comfyui/models/insightface && \
    wget -q --show-progress -O /comfyui/models/insightface/inswapper_128.onnx \
    "https://huggingface.co/fofr/comfyui/resolve/main/insightface/inswapper_128.onnx"

RUN mkdir -p /comfyui/models/facerestore_models && \
    wget -q -O /comfyui/models/facerestore_models/GFPGANv1.4.pth \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.4.pth"

# ============================================================
# 9. Workflows kopieren
# ============================================================
COPY workflows/ /comfyui/user/default/workflows/
