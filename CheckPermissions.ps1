param (
    [string]$user,
    [string]$Path='C:\ProgramData\',     
    [switch]$inherit=$False
 )
 

function CheckPermissions([string]$user, [string]$Path, [bool]$inherit) {

    #$user = 'Everyone'
    Write-Host $user #$Path$inherit
    #Get-ChildItem -recurse -Path $Path -ErrorAction SilentlyContinue

    ForEach($file in (Get-ChildItem -recurse -Path $Path -ErrorAction SilentlyContinue)) {
    
    try{    $acl = Get-Acl -path $file.PSPath -ErrorAction SilentlyContinue }
    catch { continue }
    
    if ($acl.Owner -eq 'BUILTIN\Administrators' -or $acl.Owner -eq 'NT AUTHORITY\SYSTEM')
    {
        ForEach($ace in $acl.Access) {
            If(
               (($ace.FileSystemRights -eq [Security.AccessControl.FileSystemRights]::FullControl) -or 
                ($ace.FileSystemRights -match 'Write') -or 
                ($ace.FileSystemRights -match 'Modify') -or 
                ($ace.FileSystemRights -match 'AppendData') -or 
                ($ace.FileSystemRights -match 'ChangePermissions') -or 
                ($ace.FileSystemRights -match 'Create') -or 
                ($ace.FileSystemRights -match 'TakeOwnership')
               ) -and 
                ($ace.IdentityReference.Value -in $user) -and 
                ($ace.IsInherited -eq $inherit)) 
                {
                 Convert-Path $file.PSPath 
                } 
            }
        }
   }
}



if ($PSBoundParameters.ContainsKey('user'))
 { 
  #$user='BUILTIN/User'
  CheckPermissions $user $Path $inherit
 }
else
{
    $users = 'Everyone','Guest','BUILTIN\Users','NT AUTHORITY\Authenticated Users'
    ForEach($i in $users)
        {
            CheckPermissions $i $Path $inherit
        }
}

