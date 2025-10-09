# DeepStack Face Recognition Functions

![DeepStack Logo](https://deepstack.cc/static/img/logo.png)

## Overview

This module provides PowerShell functions to interact with DeepStack's face recognition API running in a Docker container. DeepStack offers powerful, privacy-focused AI capabilities including face detection, face recognition, object detection, and image enhancement.

## APACHE 2.0 License

````text
Copyright (c) 2025 René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

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
