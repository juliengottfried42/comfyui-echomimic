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
# 1. Custom Nodes installieren (nur Code, keine Models)
# ============================================================

# EchoMimic V3 — Bild + Audio → Video mit Lip-Sync + Gestik
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/smthemex/ComfyUI_EchoMimic.git && \
    cd ComfyUI_EchoMimic && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --no-deps facenet-pytorch && \
    pip install --no-cache-dir retina-face==0.0.17

# ReActor — Face-Swap (Avatar-Gesicht auf echte Videos)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor.git && \
    cd ComfyUI-ReActor && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir onnxruntime-gpu insightface

# VideoHelperSuite — Video-Output (VHS_VideoCombine)
RUN comfy-node-install comfyui-videohelpersuite

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
