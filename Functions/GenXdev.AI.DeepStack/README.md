# DeepStack Face Recognition Functions

![DeepStack Logo](https://deepstack.cc/static/img/logo.png)

## Overview

This module provides PowerShell functions to interact with DeepStack's face recognition API running in a Docker container. DeepStack offers powerful, privacy-focused AI capabilities including face detection, face recognition, object detection, and image enhancement.

## Quick Start

```powershell
# Ensure the DeepStack server is running
EnsureDeepStack

# Register faces for recognition
Register-Face -Identifier "JohnDoe" -ImagePath "C:\path\to\john.jpg"

# Check if faces are recognized in an image
Get-ImageDetectedFaces -ImagePath "C:\path\to\group_photo.jpg"

# Remove a registered face
Unregister-Face -Identifier "JohnDoe"

# Enhance an image
Invoke-ImageEnhancement -ImagePath "C:\path\to\photo.jpg" -OutputPath "C:\path\to\enhanced.jpg"
```

## Prerequisites

- Docker Desktop installed and running
- PowerShell 5.1 or later (PowerShell Core is also supported)
- At least 4GB of available RAM (8GB recommended)
- GPU with CUDA support (optional, for faster processing)

## Available Functions

| Function                  | Description                                                |
| ------------------------- | ---------------------------------------------------------- |
| `EnsureDeepStack`         | Ensures the DeepStack container is running                 |
| `Register-Face`           | Registers a face with an identifier for future recognition |
| `Get-ImageDetectedFaces`  | Detects and identifies faces in an image                   |
| `Unregister-Face`         | Removes a specific registered face                         |
| `Unregister-AllFaces`     | Removes all registered faces                               |
| `Invoke-ImageEnhancement` | Enhances image quality and size                            |

## Detailed Usage

### Setting up DeepStack

```powershell
# Basic setup with default settings
EnsureDeepStack

# Setup with GPU acceleration
EnsureDeepStack -UseGPU

# Custom setup with specific port and container name
EnsureDeepStack -ContainerName "my_deepstack" -ServicePort 5050
```

### Face Registration

```powershell
# Register a single face
Register-Face -Identifier "JohnDoe" -ImagePath "C:\Users\You\Pictures\john.jpg"

# Register multiple face images for the same person
Register-Face -Identifier "JaneDoe" -ImagePath @(
    "C:\Users\You\Pictures\jane1.jpg",
    "C:\Users\You\Pictures\jane2.jpg"
)
```

### Face Detection and Recognition

```powershell
# Recognize faces in an image (returns all registered people in the photo)
Get-ImageDetectedFaces -ImagePath "C:\Users\You\Pictures\group_photo.jpg"

# Use higher confidence threshold (more accurate but may miss some faces)
Get-ImageDetectedFaces -ImagePath "C:\Users\You\Pictures\group_photo.jpg" -ConfidenceThreshold 0.7
```

### Managing Registered Faces

```powershell
# Remove a specific registered face
Unregister-Face -Identifier "JohnDoe"

# Remove all registered faces (with confirmation prompt)
Unregister-AllFaces

# Force remove all registered faces (no confirmation)
Unregister-AllFaces -Force
```

### Image Enhancement

```powershell
# Enhance an image and save the result
Invoke-ImageEnhancement -ImagePath "C:\Users\You\Pictures\low_quality.jpg" -OutputPath "C:\Users\You\Pictures\enhanced.jpg"

# Enhance an image using GPU acceleration
Invoke-ImageEnhancement -ImagePath "C:\Users\You\Pictures\low_quality.jpg" -UseGPU -OutputPath "C:\Users\You\Pictures\enhanced.jpg"
```

## DeepStack API Endpoints

The functions in this module interact with these DeepStack API endpoints:

- `POST /v1/vision/face/register` - Register known faces
- `POST /v1/vision/face/recognize` - Recognize faces in an image
- `POST /v1/vision/face/list` - List registered faces
- `POST /v1/vision/face/delete` - Remove registered face
- `POST /v1/vision/enhance` - Enhance image quality and size

## Troubleshooting

### Common Issues

- **Container Fails to Start**: Ensure you have sufficient memory and CPU resources
- **API Timeout**: Check if the container is responding with `docker logs deepstack_face_recognition`
- **Face Recognition Issues**: Try registering multiple angles of the same face for better recognition
- **GPU Issues**: Make sure your NVIDIA drivers are up to date and CUDA is properly configured

### Logs and Diagnostics

To view the DeepStack server logs:

```powershell
docker logs deepstack_face_recognition
```

## License

MIT License - see LICENSE file for details.

## Additional Resources

- [DeepStack Documentation](https://docs.deepstack.cc/)face-recognition/)
- [DeepStack GitHub](https://github.com/johnolafenwa/DeepStack)
