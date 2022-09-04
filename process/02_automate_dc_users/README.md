# 02 Automate Domain user's creation

1. Create user schema JSON with the following options:
    - "domain"
    - "groups"
    - "users"
2. Create a PowerShell script, which does the following:
    - Accept JSON schema as a parameter.
    ```shell
        param ( [Parameter(Mandatory=$true) ] $groupObject )
        param ( [Parameter(Mandatory=$true) ] $userObject )
    ```
    - Parse this JSON as an Object.
    - Creates AD group from a file, but firstly checks if this group exists.
    ```shell
         try {
            Get-ADGroup -Identity "$group"
            Add-ADGroupMember -Identity $group -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "User $name NOT added to group $group_name because it doest not exist"
        }
    ```
   ```shell
    New-ADGroup -name $name -GroupScope Global
    ```
    - Adds new AD user.
    ```shell
        New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $samAccountName -UserPrincipalName $principalName@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount 
    ```
3. Moves this script to DC and run it on the AD schema JSON file as well.
   