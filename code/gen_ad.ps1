param( [Parameter(Mandatory=$true) ] $JSONFile)

function CreateADGroup(){
    param ( [Parameter(Mandatory=$true) ] $groupObject )

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function RemoveADGroup(){
    param ( [Parameter(Mandatory=$true) ] $groupObject )

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$False
}

function  CreateADUser() {
    param ( [Parameter(Mandatory=$true) ] $userObject )
    
    $name = $userObject.name

    $password = $userObject.password

    $firstname, $lastname = $name.Split(" ")

    $username= ($firstname[0] + $lastname).ToLower()


    $principalName = $username
    $samAccountName = $username

    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $samAccountName -UserPrincipalName $principalName@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount 

    foreach($group in $userObject.groups) {
        try {
            Get-ADGroup -Identity "$group"
            Add-ADGroupMember -Identity $group -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "User $name NOT added to group $group_name because it doest not exist"
        }

    }
    
}

function WeakenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

WeakenPasswordPolicy

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach($group in $json.groups){

    CreateADGroup $group
}
foreach($user in $json.users){
    CreateADUser $user
}