# Docker Desktop - Safe Settings (Windows + WSL)

## 1) Docker Engine JSON (safe baseline)

Use the content from:
- C:\myAI_System\config\docker-desktop-engine.safe.json

Why this baseline:
- keeps BuildKit GC enabled
- keeps experimental disabled
- adds bounded json-file log rotation
- does NOT force data-root/hosts changes that often break Docker Desktop startup

## 2) Resources -> Advanced -> Disk image location

Recommended target path:
- P:\DockerEngine\DockerDesktopWSL

Rules:
- target path should be empty before Browse
- do not point to two different historical copies at once
- after changing location, restart Docker Desktop and validate

Validation commands:
- wsl -l -v --all
- docker info

## 3) Resources -> File sharing (bind mounts)

Add only project roots you really mount into containers:
- C:\myAI_System
- D:\myai
- P:\_PROJECTS\MyStudio

Do not add whole drives unless required. Too broad file sharing increases IO overhead.

## 4) Can we merge two DockerDesktopWSL copies?

Short answer: no direct merge at file level.

Reason:
- each copy is a Linux filesystem image (VHDX)
- Docker metadata, layers and volume state are inside image internals
- file-level merge of two VHDX images is unsafe and can corrupt graph state

Safe options:
1. Choose one canonical image and keep the other as archive.
2. Start Docker from the chosen image.
3. If both images may contain unique workloads, export from one and import to the other:
   - docker image save / docker image load
   - docker volume backup via helper containers
   - compose project redeploy from source

## 5) Current observed state in this workspace session

- Active C image:
  - C:\Users\tomiw\AppData\Local\Docker\wsl\disk\docker_data.vhdx = 1,602,224,128 bytes
  - last write around 2026-07-08 10:22

- Historical P images (identical duplicate pair):
  - P:\DockerEngine\DockerDesktopWSL_old_20260708101340\disk\docker_data.vhdx = 37,887,148,032 bytes
  - P:\DockerDesktopWSL\disk\docker_data.vhdx = 37,887,148,032 bytes
  - same size and same timestamps in this check

Interpretation:
- two big P locations currently look like one duplicated historical dataset
- active runtime currently points elsewhere (small C image)

## 6) Recommended consolidation path

1. Keep canonical target: P:\DockerEngine\DockerDesktopWSL
2. Keep one archive only:
   - P:\DockerEngine\DockerDesktopWSL_old_20260708101340
3. Remove or rename root duplicate P:\DockerDesktopWSL when lock is released.
4. After migration and validation, keep only canonical + one backup snapshot.
