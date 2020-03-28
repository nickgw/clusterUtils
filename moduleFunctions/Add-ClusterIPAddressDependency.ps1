
<#
.Synopsis
   Adds an IPAddress as a Dependency to a Windows Cluster
.DESCRIPTION
   Adds an IP Address resource to a Windows Cluster's Dependecy Expression
.EXAMPLE
   # Using the default ParameterSet of both IP Address and Subnet
   Add-ClusterIPAddressDependency -IPAddress 10.235.32.137 -Subnet 255.255.255.128 -Verbose
.EXAMPLE
    # Using the Combined ParameterSet
    Add-ClusterIPAddressDependency -IPandSubnet 10.235.32.137/255.255.255.128 -Verbose
.AUTHOR
    Nick Germany
#>
function Add-ClusterIPAddressDependency
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
        [Parameter(Mandatory=$true,
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
    }
    Process
    {
        #* Get Windows Cluster resource
        Write-Verbose "$f Getting Windows Cluster resource"
        $cluster = Get-ClusterResource | Where-Object { $_.name -eq 'Cluster Name'}

        #* Create new IPAddress resource and add the IPAddress parameters to it
        Try {
            Write-Verbose "$f Creating new IP Address cluster resource for IP $IPAddress and Subnet Mask $SubnetMask"
            $params = @{
              Name         = "IP Address $($IPAddress.IPAddressToString)"
              ResourceType = "IP Address"
              Group        = $($cluster.OwnerGroup.Name)
              ErrorAction  = 'Stop'
            }
            $ipResource = Add-ClusterResource @params
        } Catch {
            Write-Error "$f Failed to add IPResource $($IPResource.Name) to cluster"
            break
        }

        #* Add the IP Address resource to the cluster
        Try {
            Write-Verbose "$f Attempting to add the IP Address resource properties to the cluster"
            $parameter1 = New-Object Microsoft.FailoverClusters.PowerShell.ClusterParameter $ipResource,Address,$($ipAddress.IPAddressToString)
            $parameter2 = New-Object Microsoft.FailoverClusters.PowerShell.ClusterParameter $ipResource,SubnetMask,$($subnetMask.IPAddressToString)
            $parameterList = $parameter1,$parameter2
            $ErrorActionPreference = 'Stop'
            $parameterList | Set-ClusterParameter
        } Catch {
          #TODO Add error handling here for failure. Most likely reasons are
          #* IP Address already exists (does this check actuall IP Address or just IP Address Name)
          #* IP Address network has yet to be added to the Cluster
          Write-Error "$f failed to add the IP Address resource properties to the cluster"
          break
        }

        Write-Verbose "$f Getting all IP Address resources from the Windows Cluster"
        $ipResources = Get-ClusterResource | Where-Object {
            ( $_.OwnerGroup -eq $cluster.OwnerGroup ) -and
            ( $_.ResourceType -eq 'IP Address' )
          }

        Write-Verbose "$f Building IP Resource DependencyExpression"
        $dependencyExpression = ''
        $i = 0
        while ( $i -lt ( $ipResources.count ) ) {
          if ( $i -eq ( $ipResources.count -  1) ) {
              $dependencyExpression += "[$($ipResources[$i].name)]"
          } else {
              $dependencyExpression += "[$($ipResources[$i].name)] or "
          }
          $i++
        }

        #Set cluster resources
        Try {
          $params = @{
            Resource    = $($cluster.Name)
            Dependency  = $dependencyExpression
            ErrorAction = 'Stop'
          }
          Write-Verbose "$f Setting DependencyExpression  as $dependencyExpression"
          Set-ClusterResourceDependency @params
        } Catch {
          #TODO error handling for when adding the depenencies list fails
          Write-Error "$f Failed to set DependencyExpression"
          break
        }

    }
    End
    {
      return $True
    }
}