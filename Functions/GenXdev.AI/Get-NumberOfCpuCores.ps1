################################################################################

function Get-NumberOfCpuCores {

    $cores = 0;

    Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores  | ForEach-Object { $cores += $PSItem.NumberOfCores }

    return $cores * 2;
}
