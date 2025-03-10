#Requires -Version 3
function New-RubrikBootStrap
{
  <#  
      .SYNOPSIS
      Send a Rubrik Bootstrap Request
            
      .DESCRIPTION
      This will send a bootstrap request 
            
      .NOTES
      
            
      .LINK
      https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap
            
      .EXAMPLE
      New-RubrikBootStrap -server 169.254.11.25 -params
      
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api,
    [Alias('admin_id')]
    [string]$adminid = 'admin',
    [Alias('email_Address')]
    [string]$emailAddress = 'Drew.Russell@rubrik.com',
    [Alias('admin_password')]
    [string]$password = 'p@ssw0rd!',
    [Alias('enable_Software_Encryption_At_Rest')]
    [string]$enableSoftwareEncryptionAtRest = 'false',
    [Alias('rubrik_name')]
    [string]$name = 'Rubrik',
    [Alias('management_Ip_config')]
    [string]$managementIpConfig = '',
    [Alias('management_gateway')]
    [string]$gateway = '',
    [Alias('management_netmask')]
    [string]$netmask = ''
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    # This is not run due to no auth needed
    #Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    Write-Verbose -Message "Body Debug $body"
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
