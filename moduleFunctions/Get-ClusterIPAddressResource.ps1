function Get-ClusterIPAddressResource
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        #Cluster name to target
        [Parameter(Mandatory=$false,
                   ValueFromPipelineBYPropertyName=$true
                   )]
        [System.String]
        $Cluster = ''
    )

    Begin
    {
        $f = "$($PSCmdlet.CommandRunTime): "
    }
    Process
    {
        Try {
            if ( '' -ne $Cluster ) {
              Write-Verbose "$f Getting all Cluster resources for Cluster $Cluster"
              $resources = Get-ClusterResource -Cluster $Cluster
            } else {
              Write-Verbose "$f Getting all Cluster resources"
              $resources = Get-ClusterResource
            }
        } Catch {
            Write-Error "$f Failed to get Cluster resources"
            break
        }

        $ipAddressResources = $resources | Where-Object {
          ($_.ResourceType -eq 'IP Address') -and
          ($_.OwnerGroup -eq 'Cluster Group')
          }
        $ipResources = [System.Collections.Generic.List[PSCustomObject]]::New()
        foreach ( $ipResource in $ipAddressResources ){
            Write-Verbose "$f Getting details for IPAddress Resource `'$($ipResource.Name)`'"
            $resObj = $ipResource | Get-ClusterParameter -Name Address,Network,SubnetMask
            if ( '' -ne $Cluster ) {
                $ipObj = [PSCustomObject]@{
                  'Name'       = $ipResource.Name
                  'Address'    = ($resobj | Where-Object {$_.name -eq 'Address'}).value
                  'SubnetMask' = ($resobj | Where-Object {$_.name -eq 'SubnetMask'}).value
                  'Network'    = ($resobj | Where-Object {$_.name -eq 'Network'}).value
                  'State'      = $ipResource.State
                  'Cluster'    = $Cluster
              }
            } else {
                $ipObj = [PSCustomObject]@{
                  'Name'       = $ipResource.Name
                  'Address'    = ($resobj | Where-Object {$_.name -eq 'Address'}).value
                  'SubnetMask' = ($resobj | Where-Object {$_.name -eq 'SubnetMask'}).value
                  'Network'    = ($resobj | Where-Object {$_.name -eq 'Network'}).value
                  'State'      = $ipResource.State
                }
            }

            $ipResources.add($ipObj)
        }
    }
    End
    {
      return $ipResources
    }
}
