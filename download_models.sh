#!/bin/bash
# ============================================================
# Download grosse Models beim ersten Start
# Werden im Network Volume gecacht
# ============================================================

echo "=== Pruefe Models ==="

# EchoMimic V3 Preview Transformer (3.41 GB)
if [ ! -f /comfyui/models/echo_mimic/transformer/diffusion_pytorch_model.safetensors ]; then
    echo "Lade EchoMimic V3 Transformer..."
    mkdir -p /comfyui/models/echo_mimic/transformer
    wget -q --show-progress -O /comfyui/models/echo_mimic/transformer/diffusion_pytorch_model.safetensors \
        "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/transformer/diffusion_pytorch_model.safetensors"
    wget -q -O /comfyui/models/echo_mimic/transformer/config.json \
        "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/transformer/config.json"
fi

# EchoMimic V3 Flash-Pro (3.73 GB)
if [ ! -f /comfyui/models/echo_mimic/echomimicv3-flash-pro/diffusion_pytorch_model.safetensors ]; then
    echo "Lade EchoMimic V3 Flash-Pro..."
    mkdir -p /comfyui/models/echo_mimic/echomimicv3-flash-pro
    wget -q --show-progress -O /comfyui/models/echo_mimic/echomimicv3-flash-pro/diffusion_pytorch_model.safetensors \
        "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/echomimicv3-flash-pro/diffusion_pytorch_model.safetensors"
    wget -q -O /comfyui/models/echo_mimic/echomimicv3-flash-pro/config.json \
        "https://huggingface.co/BadToBest/EchoMimicV3/resolve/main/echomimicv3-flash-pro/config.json"
fi

# Wan2.1 VAE (508 MB)
if [ ! -f /comfyui/models/vae/Wan2.1_VAE.pth ]; then
    echo "Lade Wan2.1 VAE..."
    mkdir -p /comfyui/models/vae
    wget -q --show-progress -O /comfyui/models/vae/Wan2.1_VAE.pth \
        "https://huggingface.co/alibaba-pai/Wan2.1-Fun-V1.1-1.3B-InP/resolve/main/Wan2.1_VAE.pth"
fi

# CLIP Text Encoder umt5_xxl fp8 (4.9 GB)
if [ ! -f /comfyui/models/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors ]; then
    echo "Lade CLIP Text Encoder (4.9 GB)..."
    mkdir -p /comfyui/models/clip
    wget -q --show-progress -O /comfyui/models/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
        "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
fi

# CLIP Vision Encoder (1.26 GB)
if [ ! -f /comfyui/models/clip_vision/clip_vision_h.safetensors ]; then
    echo "Lade CLIP Vision Encoder..."
    mkdir -p /comfyui/models/clip_vision
    wget -q --show-progress -O /comfyui/models/clip_vision/clip_vision_h.safetensors \
        "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
fi

# GFPGANv1.4 Face Restore (350 MB)
if [ ! -f /comfyui/models/facerestore_models/GFPGANv1.4.pth ]; then
    echo "Lade GFPGAN Face Restore..."
    mkdir -p /comfyui/models/facerestore_models
    wget -q -O /comfyui/models/facerestore_models/GFPGANv1.4.pth \
        "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.4.pth"
fi

echo "=== Alle Models bereit ==="
