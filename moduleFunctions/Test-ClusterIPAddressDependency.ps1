
<#
.Synopsis
   Tests whether a given IPAddress is part of the Cluster's DependencyExpression
.DESCRIPTION
   Long description
.EXAMPLE
   Example using complete IPAddress and Subnetmask default ParameterSet
   Test-ClusterIPAddressDependency -IPAddress 10.235.0.141 -SubnetMask 255.255.255.128 -verbose
.EXAMPLE
   Example using IPAddress from default ParameterSet
   Test-ClusterIPAddressDependency -IPAddress 10.235.0.141 -verbose
.EXAMPLE
   Example using Combined ParameterSet
   Test-ClusterIPAddressDependency -IPandSubnet 10.235.0.141/255.255.255.128 -verbose
#>
function Test-ClusterIPAddressDependency
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # IPAddress to add to Cluster
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName = "Default",
                   Position=0)]
        [IPAddress]$IPAddress,

        # SubnetMask of IPAddress
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName = "Default",
                   Position=1)]
        [IPAddress]$SubnetMask,

        #CombinedIPAddressandSubnet
        [Parameter(Mandatory=$true,
                   ValueFromPipelineBYPropertyName=$true,
                   ParameterSetName="Combined",
                   Position=0)]
        [String]$IPandSubnet
    )

    Begin
    {
        $f = "$($PSCmdlet.CommandRunTime): "
        switch ( $PsCmdlet.ParameterSetName ) {
          "Combined" {
              Write-Verbose "$f Combined IP and SubnetMask were passed as $IPandSubnet"

              [IPAddress]$IPAddress  = $IPandSubnet.Split('/')[0]
              [IPAddress]$SubnetMask = $IPandSubnet.Split('/')[1]
              Write-Verbose "$f IP and SubnetMask split as $IPAddress and $SubnetMask"
          }
        }
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
      Try {
        Write-Verbose "$f Getting Cluster DependencyExpression"
        $cluster = Get-ClusterResource | Where-Object {$_.name -eq 'Cluster Name'}
        $dependencyExpression = (Get-ClusterResourceDependency -Resource $cluster.Name).DependencyExpression
      } Catch {
        Write-Error "$f Failed to get cluster dependencies. Is $($env:ComputerName) joined to a cluster?"
      }

      Write-Verbose "$f Testing if $IPAddress is in DependencyExpression $dependencyExpression"
      If ( $dependencyExpression -match $IPAddress ) {
        Write-Verbose "$f $IPAddress is in DependencyExpression $dependencyExpression"
        $returnObj = $True
      } else {
        Write-Verbose "$f $IPAddress is not in DependencyExpression $dependencyExpression"
        $returnObj = $False
      }
    }
    End
    {
      return $returnObj
    }
}
