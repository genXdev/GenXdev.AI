################################################################################

function Get-HasCapableGpu {

    # Check for CUDA-compatible GPU with at least 8 GB of RAM

    # Get the list of video controllers
    $videoControllers = Get-WmiObject Win32_VideoController | Where-Object { $PSItem.AdapterRAM -ge 8GB }

    return $null -ne $videoControllers
}
