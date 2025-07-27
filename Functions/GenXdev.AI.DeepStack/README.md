# DeepStack Face Recognition Functions

![DeepStack Logo](https://deepstack.cc/static/img/logo.png)

## Overview

This module provides PowerShell functions to interact with DeepStack's face recognition API running in a Docker container. DeepStack offers powerful, privacy-focused AI capabilities including face detection, face recognition, object detection, and image enhancement.

## MIT License

```text
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

- Docker Desktop installed and running
- At least 16GB of available RAM
- GPU with CUDA support (optional, for faster processing)

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
Export-ImageIndex
Find-IndexedImage -HasNudity -HasExplicitContent -ShowInBrowser -InterActive

# you can keep the output and reuse them
$foundImages = Find-IndexedImage -HasNudity -HasExplicitContent

# all Find-IndexedImage's parameters, except -PathLike, are inclusive
# to truly filter using exclusions, chain commands using pipes |
Set-WindowsPosition -Monitor 0 -Left

$foundImages |
    Find-Image -Objects person, dog |
    Find-Image -StyleType *photography* |
    Show-FoundImagesInBrowser -Monitor 0 -Right -Interactive

```
