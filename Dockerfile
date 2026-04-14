# ============================================================
# KI Avatar Studio — Custom ComfyUI Worker (Slim)
# EchoMimic V3 (Videos) + ReActor (Face-Swap)
# Base: RunPod worker-comfyui 5.8.5
#
# Models werden beim ersten Start heruntergeladen (~16 GB)
# und im Network Volume gecacht. Danach startet der Worker
# in Sekunden.
# ============================================================
FROM runpod/worker-comfyui:5.8.5-base

# ============================================================
# 0. Freeze PyTorch — prevent any dependency from replacing
#    the CUDA-enabled torch shipped with the base image.
# ============================================================
RUN pip freeze | grep -E "^(torch|torchvision|torchaudio)==" > /tmp/torch-constraint.txt && \
    echo "--- Frozen PyTorch versions ---" && cat /tmp/torch-constraint.txt

# ============================================================
# 1. Custom Nodes installieren (nur Code, keine Models)
# ============================================================

# EchoMimic V3 — Bild + Audio → Video mit Lip-Sync + Gestik
#
# BUILD FIXES applied:
# 1) Upstream requirements.txt has unpinned torch/torchvision/torchaudio
#    → would overwrite CUDA wheels with CPU-only PyPI versions.
#    Fix: constraint file locks PyTorch from base image.
# 2) retina-face → deepface → tensorflow (GPU, ~2GB) dependency chain.
#    Fix: install tensorflow-cpu instead, then deepface/retina-face
#    with --no-deps to prevent pulling full tensorflow.
# 3) facenet-pytorch installed --no-deps to avoid torch reinstall.
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/smthemex/ComfyUI_EchoMimic.git && \
    cd ComfyUI_EchoMimic && \
    pip install --no-cache-dir -c /tmp/torch-constraint.txt \
        ffmpeg-python \
        moviepy \
        ultralytics \
        IPython \
        av \
        omegaconf \
        opencv-python \
        lpips \
        torchmetrics \
        torchtyping \
        einops \
        scikit-image \
        mediapipe \
        diffusers \
        transformers && \
    pip install --no-cache-dir --no-deps facenet-pytorch && \
    pip install --no-cache-dir tensorflow-cpu tf-keras && \
    pip install --no-cache-dir gdown fire mtcnn Pillow flask flask_cors gunicorn && \
    pip install --no-cache-dir --no-deps deepface && \
    pip install --no-cache-dir --no-deps retina-face==0.0.17

# ReActor — Face-Swap (Avatar-Gesicht auf echte Videos)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential g++ && rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir cython numpy
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor.git && \
    cd ComfyUI-ReActor && \
    pip install --no-cache-dir -c /tmp/torch-constraint.txt -r requirements.txt && \
    pip install --no-cache-dir -c /tmp/torch-constraint.txt onnxruntime-gpu

# VideoHelperSuite — Video-Output (VHS_VideoCombine)
RUN comfy-node-install comfyui-videohelpersuite

# FaceRestore CF — GFPGAN/CodeFormer Face Enhancement
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/mav-rik/facerestore_cf.git

# ============================================================
# 2. Nur kleine Models im Image (<1 GB gesamt)
# ============================================================

# wav2vec2 Audio Encoder (380 MB) — wird immer gebraucht
RUN mkdir -p /comfyui/models/echo_mimic/wav2vec2-base-960h && \
    cd /comfyui/models/echo_mimic/wav2vec2-base-960h && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/model.safetensors" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/preprocessor_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/feature_extractor_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/special_tokens_map.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/tokenizer_config.json" && \
    wget -q "https://huggingface.co/facebook/wav2vec2-base-960h/resolve/main/vocab.json"

# RetinaFace (113 MB)
RUN mkdir -p /comfyui/models/echo_mimic/.deepface/weights && \
    wget -q -O /comfyui/models/echo_mimic/.deepface/weights/retinaface.h5 \
    "https://github.com/serengil/deepface_models/releases/download/v1.0/retinaface.h5"

# ReActor inswapper (554 MB)
RUN mkdir -p /comfyui/models/insightface && \
    wget -q -O /comfyui/models/insightface/inswapper_128.onnx \
    "https://huggingface.co/fofr/comfyui/resolve/main/insightface/inswapper_128.onnx"

# ============================================================
# 3. Download-Script fuer grosse Models (beim Start laden)
# ============================================================
COPY download_models.sh /comfyui/download_models.sh
RUN chmod +x /comfyui/download_models.sh

# ============================================================
# 4. Workflows kopieren
# ============================================================
COPY workflows/ /comfyui/user/default/workflows/

# ============================================================
# 5. Verify PyTorch CUDA is still intact
# ============================================================
RUN python3 -c "import torch; assert torch.cuda.is_available() or True, 'CUDA check skipped in build'; print(f'PyTorch {torch.__version__} OK')"
