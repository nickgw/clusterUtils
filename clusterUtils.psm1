

# Get all module functions
$script:ModuleFunctionPath = Join-Path -Path $PSScriptRoot -ChildPath 'moduleFunctions'
Write-host "script:ModuleFunctionPath is: $($script:ModuleFunctionPath)"

# Get all helper functions
$script:HelperFunctionPath = Join-Path -Path $PSScriptRoot -ChildPath 'HelperFunction'
Write-host "script:HelperFunctionPath is: $($script:HelperFunctionPath)"

$moduleFunctionFiles = Get-ChildItem -Path $script:ModuleFunctionPath
$helperFunctionFiles = Get-ChildItem -Path $script:ModuleFunctionPath

ForEach-Object ( $function in $moduleFunctionFiles ) {
    Export-ModuleMember -Function $function.BaseName
}
