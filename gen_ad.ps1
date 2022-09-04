param( [Parameter(Mandatory=$true) ] $JSONFile)

function CreateADGroup(){
    param ( [Parameter(Mandatory=$true) ] $groupObject )

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
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

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach($group in $json.groups){

    CreateADGroup $group
}
foreach($user in $json.users){
    CreateADUser $user
}