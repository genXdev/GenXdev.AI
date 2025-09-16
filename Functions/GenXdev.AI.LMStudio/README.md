# LM Studio Integration Functions

## Overview

This module provides PowerShell functions to interact with LM Studio, a desktop application for running large language models locally. LM Studio offers a user-friendly interface for downloading, managing, and running various LLM models with OpenAI-compatible API endpoints.

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

- LM Studio application (automatically installed via `Install-LMStudioApplication`)
- At least 16GB of available RAM (32GB+ recommended for larger models)
- Modern CPU with AVX2 support
- 50GB+ free storage for model downloads

## Quick Start

```powershell
# Install LM Studio application
Install-LMStudioApplication

# Start using AI queries immediately
Invoke-LLMQuery -Query "What is PowerShell?" -LLMQueryType "Knowledge"

# Quick queries using alias
qllm "Explain machine learning in simple terms"
```

## Key Features

- **Simple AI Queries**: Use `Invoke-LLMQuery` with different query types for optimized responses
- **Multi-Modal Support**: Analyze images, documents, and text in a single query
- **Interactive Chat**: Real-time conversations with AI models
- **Structured Output**: Get responses in JSON format with custom schemas
- **File Attachments**: Process documents, images, and code files
- **Session Management**: Continue conversations with context

## Available Functions

| Function | Description | Aliases |
|----------|-------------|---------|
| `Invoke-LLMQuery` | Main AI query function with multiple capabilities | `qllm` |
| `Set-AILLMSettings` | Configure AI settings with memory detection | |
| `EnsureLMStudio` | Ensures LM Studio is running | |
| `Initialize-LMStudioModel` | Initializes and loads a model | `initlmstudio` |
| `Install-LMStudioApplication` | Installs LM Studio via WinGet | |
| `Start-LMStudioApplication` | Starts LM Studio if not running | |
| `Get-LMStudioModelList` | Lists all installed models | |
| `Get-LMStudioLoadedModelList` | Lists currently loaded models | |
| `Get-LMStudioPaths` | Gets LM Studio executable paths | |
| `Get-LMStudioTextEmbedding` | Generates text embeddings | |
| `Get-LMStudioWindow` | Manages LM Studio window positioning | `lmstudiowindow`, `setlmstudiowindow` |
| `Test-LMStudioInstallation` | Verifies LM Studio installation | |
| `Test-LMStudioProcess` | Checks if LM Studio is running | |
| `Add-GenXdevMCPServerToLMStudio` | Adds MCP server to LM Studio | |
| `ConvertTo-LMStudioFunctionDefinition` | Converts PowerShell functions to LM Studio format | |

## AI Query Examples with Invoke-LLMQuery

### Basic Queries with Different Types

```powershell
# General knowledge questions
Invoke-LLMQuery -Query "What are the benefits of renewable energy?" -LLMQueryType "Knowledge"

# Programming assistance
Invoke-LLMQuery -Query "Write a function to sort an array in PowerShell" -LLMQueryType "Coding"

# Language translation
Invoke-LLMQuery -Query "Translate 'Good morning' to French, Spanish, and German" -LLMQueryType "TextTranslation"

# General reasoning
Invoke-LLMQuery -Query "Compare the pros and cons of remote work" -LLMQueryType "SimpleIntelligence"

# Quick alias usage
qllm "What's the weather like today?"
```

### Working with Files and Attachments

```powershell
# Analyze an image
Invoke-LLMQuery -Query "What do you see in this image?" `
    -LLMQueryType "Pictures" `
    -Attachments @("C:\Photos\vacation.jpg")

# Review code files
Invoke-LLMQuery -Query "Check this code for potential issues" `
    -LLMQueryType "Coding" `
    -Attachments @("C:\Code\script.ps1")

# Summarize documents
Invoke-LLMQuery -Query "Create a summary of this document" `
    -LLMQueryType "Knowledge" `
    -Attachments @("C:\Documents\report.txt")

# Analyze multiple files together
Invoke-LLMQuery -Query "Compare these two approaches and recommend the best one" `
    -LLMQueryType "Coding" `
    -Attachments @("C:\Code\approach1.py", "C:\Code\approach2.py")
```

### Interactive Chat and Conversations

```powershell
# Start an interactive chat session
Invoke-LLMQuery -ChatMode "textprompt" -LLMQueryType "SimpleIntelligence"

# Continue a previous conversation
Invoke-LLMQuery -Query "Can you elaborate on that last point?" -ContinueLast

# Start fresh conversation
Invoke-LLMQuery -Query "Let's discuss a new topic: AI ethics" -ClearSession
```

### Structured Output with JSON Schemas

```powershell
# Get structured analysis
$schema = @'
{
  "type": "object",
  "properties": {
    "summary": {"type": "string"},
    "key_points": {"type": "array", "items": {"type": "string"}},
    "rating": {"type": "number", "minimum": 1, "maximum": 10}
  }
}
'@

Invoke-LLMQuery -Query "Analyze this product review" `
    -LLMQueryType "Knowledge" `
    -Attachments @("C:\Reviews\product_review.txt") `
    -ResponseFormat $schema

# Get code analysis in structured format
$codeSchema = @'
{
  "type": "object",
  "properties": {
    "issues": {"type": "array", "items": {"type": "string"}},
    "suggestions": {"type": "array", "items": {"type": "string"}},
    "complexity_score": {"type": "number"}
  }
}
'@

Invoke-LLMQuery -Query "Analyze this code quality" `
    -LLMQueryType "Coding" `
    -Attachments @("C:\Code\complex_function.js") `
    -ResponseFormat $codeSchema
```

### Advanced Query Features

```powershell
# Custom instructions (system prompt)
Invoke-LLMQuery -Query "Review this contract" `
    -LLMQueryType "Knowledge" `
    -Instructions "You are a legal expert. Focus on potential risks and unclear terms." `
    -Attachments @("C:\Legal\contract.pdf")

# Creative writing with specific tone
Invoke-LLMQuery -Query "Write a story about space exploration" `
    -LLMQueryType "SimpleIntelligence" `
    -Instructions "Write in a humorous, lighthearted tone suitable for children"

# Technical analysis with specific expertise
Invoke-LLMQuery -Query "Optimize this database query" `
    -LLMQueryType "Coding" `
    -Instructions "You are a senior database architect. Focus on performance and scalability." `
    -Attachments @("C:\SQL\slow_query.sql")
```

### Image Analysis Examples

```powershell
# Basic image description
Invoke-LLMQuery -Query "Describe what's happening in this image" `
    -LLMQueryType "Pictures" `
    -Attachments @("C:\Images\event_photo.jpg")

# Technical diagram analysis
Invoke-LLMQuery -Query "Explain this network diagram and identify potential bottlenecks" `
    -LLMQueryType "Pictures" `
    -Attachments @("C:\Diagrams\network_topology.png")

# Multiple images comparison
Invoke-LLMQuery -Query "Compare these before and after photos" `
    -LLMQueryType "Pictures" `
    -Attachments @("C:\Photos\before.jpg", "C:\Photos\after.jpg")

# Chart and data analysis
Invoke-LLMQuery -Query "What trends do you see in this sales chart?" `
    -LLMQueryType "Pictures" `
    -Attachments @("C:\Reports\sales_chart.png")
```

## LLM Query Types

Different query types optimize AI responses for specific tasks:

| Query Type | Use Case | Best For |
|------------|----------|----------|
| `SimpleIntelligence` | General reasoning and questions | Everyday questions, discussions |
| `Knowledge` | Factual information and research | Research, facts, explanations |
| `Pictures` | Image analysis and visual tasks | Photo analysis, diagrams, charts |
| `TextTranslation` | Language translation | Converting between languages |
| `Coding` | Programming assistance | Code review, debugging, writing functions |
| `ToolUse` | Function calling and automation | Automated tasks, integrations |

## System Requirements

- **RAM**: 16GB minimum (32GB+ recommended)
- **CPU**: Modern processor with AVX2 support
- **Storage**: 20GB+ free space for models
- **OS**: Windows 10/11, macOS 10.15+, or Linux
