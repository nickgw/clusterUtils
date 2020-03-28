<#
.Synopsis
   Returns a subnet mask address from a given CIDR
.DESCRIPTION
   Returns an IPAddress object representing a subnet mask address from a given CIDR
.EXAMPLE
    Get-SubnetMaskfromCIDR -CIRDNotation 24
    #returns
      Address            : 16777215
      AddressFamily      : InterNetwork
      ScopeId            :
      IsIPv6Multicast    : False
      IsIPv6LinkLocal    : False
      IsIPv6SiteLocal    : False
      IsIPv6Teredo       : False
      IsIPv4MappedToIPv6 : False
      IPAddressToString  : 255.255.255.0
.EXAMPLE
    Get-SubnetMaskfromCIDR -CIDRNotation  25
    #returns
        Address            : 2164260863
        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        IPAddressToString  : 255.255.255.128
#>
function Get-SubnetMaskfromCIDR
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([IPAddress])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateRange(0,32)]
        [Int]
        $CIDRNotation
    )

    Begin
    {
    }
    Process
    {
         # This CIDR => Subnetmask code was shamelessly stolen from https://www.reddit.com/r/PowerShell/comments/81x324/shortest_script_challenge_cidr_to_subnet_mask/dv6jkj5
        [IPAddress]$SubnetMask = (0..3|%{(,0*($_*8+1)+('Ààðøüþÿ'|% t*y|%{+$_})+,255*(24-$_*8))[$CIDRNotation]})-join'.'
    }
    End
    {
        return $SubnetMask
    }
}