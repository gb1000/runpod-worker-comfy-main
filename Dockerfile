# Use Nvidia CUDA base image
FROM nvidia/cuda:12.6.2-cudnn-runtime-ubuntu22.04 as base

# Prevent prompts from blocking installations
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 

# Install Python 3.12 and other dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-distutils \
    python3-pip \
    git \
    wget \
    libgl1 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get autoremove -y && apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui

# Set the working directory
WORKDIR /comfyui

RUN python3 -m venv venv
RUN /bin/bash -c "source venv/bin/activate"

RUN pip install --no-cache-dir -r requirements.txt



# Install PyTorch with CUDA
# RUN pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu124



# Install xformers and other dependencies
RUN pip install --no-cache-dir xformers --extra-index-url https://download.pytorch.org/whl/cu124


# Install custom nodes (e.g., ComfyUI-Manager)
WORKDIR /comfyui/custom_nodes
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && pip install --no-cache-dir -r requirements.txt

# Expose the application's port
EXPOSE 8188

WORKDIR /comfyui

# COPY data/extra_model_paths.yaml .
ADD src/extra_model_paths.yaml ./


# Set working directory back to root
WORKDIR /comfyui

# Set entrypoint to run the application
CMD ["python", "main.py"]
