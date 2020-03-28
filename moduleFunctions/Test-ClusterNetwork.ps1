
<#
.Synopsis
   Checks whether the ClusterNetwork for a given IPAddress has been added to a Cluster
.DESCRIPTION
   Given an IPAddress and SubnetMask this cmdlet will check if the correct ClusterNetwork has
   been added to the cluster.
.EXAMPLE
   Test-ClusterNetwork -IPAddress 10.245.10.32 -SubnetMask 255.255.255.0
.EXAMPLE
   Test-ClusterNetwork -IPandSubnet 10.245.10.32/255.255.255.0
#>
function Test-ClusterNetwork
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
        Write-Verbose "$f Getting all networks added to this cluster."
        $clusterNetworks = New-Object "System.Collections.Generic.List[PSCustomObject]"
        Foreach ( $network in Get-ClusterNetwork ) {
            $clusterNetworks.Add([PSCustomObject]@{
                Address     = $network.Address
                AddressMask = $network.AddressMask
            })

            Write-Verbose "$f Found cluster network $($network.Address)/$($Network.AddressMask)"
        }

        Write-Verbose "$f Getting the subnet of the given IPAddress $IPAddress with subnet mask $SubnetMask"
        $subnet = $(Get-Subnet -IPAddress $IPAddress -SubnetMask $SubnetMask -Verbose)
        Write-Verbose "$f IPAddress $IPAddress with Subnet Mask $SubnetMask is in subnet $Subnet"

        $returnObj = $False

        foreach ( $network in $clusterNetworks ) {
          if (
               ( $network.Address -eq $subnet.IPAddressToString ) -and
               ( $network.AddressMask -eq $SubnetMask.IPAddressToString )
            ){
            Write-Verbose "$f Subnet $($network.address) for IPAddress $IPAddress network $subnet is added to the cluster"
            $returnObj = $True
          }
        }
    }
    End
    {
        return $returnObj
    }
}