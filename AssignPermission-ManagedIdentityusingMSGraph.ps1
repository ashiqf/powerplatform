# Install Microsoft Graph PowerShell module if not already installed
# Install-Module -Name Microsoft.Graph.Authentication -Force -Scope CurrentUser

$PermissionName = "User.Read.All"
$DisplayNameOfMSI = "ReplaceHerewiththeDisplayNameoftheAPIMInstance"
$GraphAppId = "00000003-0000-0000-c000-000000000000"

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.ReadWrite.All","AppRoleAssignment.ReadWrite.All"

# Get Managed Identity Service Principal
$MSI = (Get-MgServicePrincipal -Filter "displayName eq '$DisplayNameOfMSI'")

# Sleep for a while to allow time for service principal creation if needed
Start-Sleep -Seconds 10

# Get Microsoft Graph Service Principal
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$GraphAppId'"

# Retrieve the App Role from the Microsoft Graph Service Principal based on the specified Permission Name
$Role = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName}

# Create an App Role Assignment HashTable for assigning the role to the Managed Identity
$AppRoleAssignment = @{
    principalId = $MSI.Id
    resourceId = $GraphServicePrincipal.Id
    appRoleId = $Role.Id }
# Assign the Graph permission
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSI.Id -BodyParameter $AppRoleAssignment
