# Use Nvidia CUDA base image
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04 as base

# Prevent prompts from blocking installations
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 

# Install Python, pip, git, and other tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    curl \
    wget && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Clean up APT cache to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui

# Set the working directory
WORKDIR /comfyui

# Install PyTorch with CUDA
RUN pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

# Install xformers and other dependencies
RUN pip install --no-cache-dir xformers==0.0.23 --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir -r requirements.txt

# Install custom nodes (e.g., ComfyUI-Manager)
WORKDIR /comfyui/custom_nodes
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && pip install --no-cache-dir -r requirements.txt

# Expose the application's port
EXPOSE 8188

# Set working directory back to root
WORKDIR /comfyui

# Set entrypoint to run the application
CMD ["python", "main.py"]
