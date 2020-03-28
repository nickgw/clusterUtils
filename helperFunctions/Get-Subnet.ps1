
<#
.Synopsis
   Given an IP Address and a Subnet Mask, returns the IP Addresses subnet.
.DESCRIPTION
   Returns an IPAddress object of the subnet mask of the given IPAddress and Subnet.
.EXAMPLE
   Get-Subnet -IPAddress 10.235.32.129 -SubnetMask 255.255.255.128
.EXAMPLE
   Get-Subnet -IPandSubnet 10.235.32.129/255.255.255.128
#>
function Get-Subnet
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([IpAddress])]
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
        $subnet = [IPAddress]($Ipaddress.Address -band $SubnetMask.Address)
    }
    End
    {
        return $Subnet
    }
}