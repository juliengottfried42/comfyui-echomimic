# ComfyUI Worker — KI Avatar Studio

Custom RunPod Serverless Worker mit:
- **EchoMimic V3** — Bild + Audio → Video mit Lip-Sync + Gestik
- **ReActor** — Face-Swap (Avatar-Gesicht auf echte Videos)
- **VideoHelperSuite** — Video-Output

## Setup

### 1. Docker Hub Account
- Account erstellen auf hub.docker.com
- Access Token generieren: Account Settings → Security → New Access Token

### 2. GitHub Repository
- Diesen Ordner als eigenes Repo pushen
- Secrets hinzufuegen:
  - `DOCKERHUB_USERNAME` — dein Docker Hub Username
  - `DOCKERHUB_TOKEN` — dein Access Token

### 3. Build starten
- Push auf `main` Branch startet automatisch den Build
- Oder manuell: Actions → Build & Push → Run workflow
- Dauert ~30-60 Min (Models werden heruntergeladen)

### 4. RunPod Endpoint erstellen
- RunPod Dashboard → Serverless → New Endpoint
- Docker Image: `DEINUSER/comfyui-echomimic:latest`
- GPU: 24 GB (RTX 4090 Pro empfohlen)
- Min Workers: 0, Max Workers: 1

### 5. Endpoint-ID in .env eintragen
```
RUNPOD_COMFYUI_ENDPOINT_ID=deine_endpoint_id
```

## Workflows

- `workflows/echomimic_v3_video.json` — Video-Generierung (Bild + Audio → Video)

## Kosten
- ~$0.03 pro Video (Scale-to-Zero, nur Kosten bei Nutzung)
- GPU: RTX 4090 Pro ~$0.69/Stunde, nur waehrend Inferenz
