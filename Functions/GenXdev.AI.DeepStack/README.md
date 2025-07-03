# DeepStack Face Recognition Functions

![DeepStack Logo](https://deepstack.cc/static/img/logo.png)

## Overview

This module provides PowerShell functions to interact with DeepStack's face recognition API running in a Docker container. DeepStack offers powerful, privacy-focused AI capabilities including face detection, face recognition, object detection, and image enhancement.

## Quick Start

```powershell


# manually ensure LMStudio is working
EnsureLMStudio -ShowWindow -Model "MiniPCM" `
    -HuggingFaceIdentifier ("lmstudio-community/MiniCPM-V-2_6-" +
                            "GGUF/MiniCPM-V-2_6-Q4_K_M.gguf")

# manually ensure docker desktop is working
EnsureDockerDesktop -ShowWindow
EnsureDeepStack

# create a directory containing only directories having names of
# each known person, each knownperson folder can contain multiple
# png, jpeg or gif images of that person

# set directories
Set-AIKnownFacesRootpath -FacesDirectory "C:\path\to\dir\with\for\each\person\a\directory\withmultipleiomages.jpg"
Set-AIImageCollection -ImageDirectories @("~\Pictures")

# update
Update-AllAIMetadata -ShowWindow
Export-ImageDatabase

Find-IndexedImage -HasNudity -HasExplicitContent -ShowInBrowser -InterActive

# you can keep the output and reuse them
$foundImages = Find-IndexedImage -HasNudity -HasExplicitContent

# all Find-IndexedImage's parameters, except -PathsLike, are inclusive
# to truly filter using exclusions, chain commands using pipes |
$foundImages |
    Find-Image -Objects person, dog |
    Find-Image -StyleType *photography* |
    Show-FoundImagesInBrowser -Monitor 0 -Right -Interactive

Set-WindowsPosition -Monitor 0 -Left

```

## Prerequisites

- Docker Desktop installed and running
- At least 16GB of available RAM
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

### Common Issues

- **Container Fails to Start**: Ensure you have sufficient memory and CPU resources
- **API Timeout**: Check if the container is responding with `docker logs deepstack_face_recognition`
- **Face Recognition Issues**: Try registering multiple angles of the same face for better recognition
- **GPU Issues**: Make sure your NVIDIA drivers are up to date and CUDA is properly configured

### Logs and Diagnostics

To view the DeepStack server logs:

```powershell
ensuredeepstack
docker logs deepstack_face_recognition
```

## License

MIT License - see LICENSE file for details.

## Additional Resources

- [DeepStack Documentation](https://docs.deepstack.cc/)face-recognition/)
- [DeepStack GitHub](https://github.com/johnolafenwa/DeepStack)
