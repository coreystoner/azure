#Connect to Azure AD
$Credentials = Get-Credential 
Connect-AzureAD -Credential $Credentials
get-azureadgroup | select DisplayName



$WVDGroup = Read-Host -Prompt 'Enter Group Name'
$WVDGroupID = Get-AzureADGroup -SearchString $WVDGroup
$useradd = Get-AzureADGroupMember -ObjectId $WvdGroupID.ObjectID | Select UserPrincipalName

$brokerurl = "https://rdbroker.wvd.microsoft.com"

#Connect to the WVD tenant
    
     Write-Host -Message "Authenticating to WVD Tenant: $tenantName" 
     Add-RdsAccount -DeploymentUrl $brokerurl -Credential $Credentials

# Get List of Tenant Names
     Get-rdstenant | Select TenantName



# Enter Tenant Name
    $tenantName = Read-Host - Prompt 'Enter WVD Tenant Name'

# Get List of Host Pools
   get-rdshostpool $tenantName | select HostPoolName

# Enter Host Pool Name
    $HostPool = Read-Host -Prompt 'Enter Host Pool Name'

# Get list of App Groups
    get-rdsappgroup $tenantName $HostPool | Select AppGroupName

# Enter AppGroup
    $AppGroup = Read-Host -Prompt 'App Group Name'

#Assign users to the WVD Host Pool
    foreach ($names in $useradd)
        {
            $upn = $names.UserPrincipalName

            #Assign user to the WVD Host Pool
            Write-Host -Message "Adding single user: $upn" 
            Write-Host -Message "Adding user: $($upn) to WVD"  
            Add-RdsAppGroupUser -TenantName $tenantName -HostPoolName $HostPool -AppGroupName $AppGroup -UserPrincipalName $upn -ErrorAction Stop
            Write-Host -Message "Successfully added user" 
}

Get-RdsAppGroupUser -TenantName $tenantName -HostPoolName $HostPool -AppGroupName $AppGroup

