# ComfyUI Integration Functions

## Overview

This module provides PowerShell functions to interact with ComfyUI, a powerful node-based interface for Stable Diffusion workflows. ComfyUI offers advanced image generation capabilities through a modular workflow system that allows for complex image manipulation and generation tasks.

## MIT License

````text
MIT License

Copyright (c) 2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
````

## Prerequisites

- ComfyUI installation (automatically handled by `EnsureComfyUI`)
- At least 8GB of available RAM (16GB+ recommended for SDXL models)
- GPU with CUDA support (optional, for faster processing)
- Python 3.8+ environment

## Quick Start

```powershell
# Ensure ComfyUI is running
EnsureComfyUI -ShowWindow

# Generate a simple image
generateimage -Prompt "a beautiful landscape with mountains"

# Generate with specific model
generateimage -Prompt "portrait of a cat" -Model "DreamShaper"

# Batch generation across all available models
generateimage -Prompt "futuristic city" -UseAllModels

# Image-to-image generation
generateimage -Prompt "make it more vibrant" -InputImage "C:\path\to\image.jpg"

```

## Key Features

### 🎨 **Advanced Image Generation**
- **Text-to-Image**: Generate images from text prompts
- **Image-to-Image**: Transform existing images with prompts
- **Multi-Model Batch Processing**: Generate with all available models for comparison
- **Architecture Detection**: Automatic SD1.5 vs SDXL optimization

### 🔧 **Model Management**
- **Validated Model Selection**: Built-in parameter validation sets for easy model choice
- **Smart Downloads**: Auto-download missing models from supported lists
- **Architecture Detection**: Intelligent model compatibility checking
- **Path Management**: Unified model directory handling

### ⚡ **Performance Optimization**
- **GPU/CPU Support**: Automatic hardware detection and optimization
- **Process Management**: Priority control for CPU-intensive operations
- **Queue Monitoring**: Real-time processing status checks
- **Resource Management**: Memory and process optimization

### 🔄 **Workflow Management**
- **Automatic Setup**: One-command ComfyUI initialization
- **Error Recovery**: Robust error handling for batch operations
- **Progress Tracking**: Detailed generation progress feedback
- **Output Organization**: Structured file naming and directory management

## Available Functions

| Function | Description | Aliases |
|----------|-------------|---------|
| `Invoke-ComfyUIImageGeneration` | Comprehensive CLI for all image generation scenarios | `generateimage` |
| `EnsureComfyUI` | Ensures ComfyUI is installed and running | |
| `Stop-ComfyUI` | Terminates all ComfyUI processes | |

## Common Workflows

### Basic Text-to-Image Generation
```powershell
# Simple generation
generateimage -Prompt "sunset over ocean"

# With negative prompt and custom settings
generateimage -Prompt "portrait of a wizard" `
         -NegativePrompt "blurry, low quality" `
         -Steps 30 `
         -CfgScale 7.5
```

### Multi-Model Comparison
```powershell
# Generate the same prompt with all available models
generateimage -Prompt "cyberpunk cityscape" -UseAllModels -OutFile "C:\Comparisons\cyberpunk.png"
```

### Image-to-Image Enhancement
```powershell
# Enhance an existing image
generateimage -Prompt "make it more colorful and vibrant" `
         -InputImage "C:\Photos\original.jpg" `
         -Strength 0.7
```

### Model Management
```powershell
# List available models using Tab completion with -Model parameter
generateimage -Prompt "test" -Model <Tab>

# Use specific models
generateimage -Prompt "fantasy castle" -Model "DreamShaper"
generateimage -Prompt "realistic portrait" -Model "Juggernaut XL"
```

### Advanced Batch Processing
```powershell
# Generate multiple variations
$prompts = @(
    "futuristic car design",
    "vintage car in forest",
    "sports car on highway"
)

$prompts | ForEach-Object {
    generateimage -Prompt $_ -OutFile "C:\CarDesigns\$($_.Replace(' ', '_')).png"
}
```

## Configuration

The module automatically detects ComfyUI installations and manages configuration through:

- **Model Directory Detection**: Automatically finds ComfyUI models folder
- **API Endpoint Management**: Connects to local ComfyUI server (default: localhost:8188)
- **Hardware Optimization**: Adjusts settings based on available GPU/CPU resources
- **Workflow Templates**: Built-in workflows for common generation tasks

## System Requirements

### Minimum Requirements
- **RAM**: 8GB (SD1.5 models)
- **Storage**: 10GB free space for models
- **CPU**: Modern multi-core processor
- **Python**: 3.8 or higher

### Recommended Requirements
- **RAM**: 16GB+ (SDXL models)
- **GPU**: NVIDIA GPU with 6GB+ VRAM
- **Storage**: 50GB+ for model collection
- **CPU**: 8+ cores for CPU-based generation

## Troubleshooting

### Common Issues

1. **ComfyUI Not Starting**
   ```powershell
   # Force restart ComfyUI
   EnsureComfyUI -ShowWindow -Force
   ```

2. **Model Not Found**
   ```powershell
   # Try a different model or let the system auto-download
   generateimage -Prompt "your prompt" -Model "DreamShaper"
   ```

3. **Performance Issues**
   ```powershell
   # Use GPU acceleration for faster generation
   generateimage -Prompt "your prompt" -UseGPU

   # Reduce image size for faster processing
   generateimage -Prompt "your prompt" -ImageWidth 512 -ImageHeight 512
   ```

---