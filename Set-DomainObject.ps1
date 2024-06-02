function Set-DomainObject {	
    param (
        [string]$Identity,
        [hashtable]$Set = @{},
        [string[]]$Clear = @(),
        [string]$Domain
    )

    function Get-ADSIUser {
        param (
            [string]$samAccountName,
            [string]$Domain
        )
        if ($Domain) {
            $root = "$Domain" -replace "\.",",DC="
            $domainPath = "DC=" + "$root"
        } else {
            $root = [ADSI]"LDAP://RootDSE"
            $domainPath = $root.defaultNamingContext
        }
        $searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"LDAP://$domainPath")
        $searcher.Filter = "(&(sAMAccountName=$samAccountName))"
        $result = $searcher.FindOne()

        if ($result -ne $null) {
            return $result.GetDirectoryEntry()
        }
        else {
            throw "Object with samAccountName '$samAccountName' not found."
        }
    }

    function Set-Values {
        param (
            [ADSI]$Entry,
            [hashtable]$Set
        )

        foreach ($key in $Set.Keys) {
            $value = $Set[$key]
            Write-Host "Setting $key to $value for $($Entry.sAMAccountName)"
            try {
                $Entry.put($key, $value)
            }
            catch {
                Write-Warning "[Set-DomainObject] Error setting/replacing property '$key' for object '$($Entry.sAMAccountName)' : $_"
            }
        }
    }

    function Clear-Values {
        param (
            [ADSI]$Entry,
            [string[]]$Clear
        )

        foreach ($key in $Clear) {
            Write-Host "Clearing $key for $($Entry.sAMAccountName)"
            try {
                $Entry.psbase.Properties[$key].Clear()
            }
            catch {
                Write-Warning "[Set-DomainObject] Error clearing property '$key' for object '$($Entry.sAMAccountName)' : $_"
            }
        }
    }

    try {
        $Entry = Get-ADSIUser -samAccountName $Identity -Domain $Domain
    }
    catch {
        Write-Warning "[Set-DomainObject] Error retrieving object with Identity '$Identity' : $_"
        return
    }

    if ($Set.Count -gt 0) {
        Set-Values -Entry $Entry -Set $Set
        try {
            $Entry.SetInfo()
        }
        catch {
            Write-Warning "[Set-DomainObject] Error committing changes for object '$Identity' : $_"
        }
    }

    if ($Clear.Length -gt 0) {
        Clear-Values -Entry $Entry -Clear $Clear
        try {
            $Entry.SetInfo()
        }
        catch {
            Write-Warning "[Set-DomainObject] Error committing changes for object '$Identity' : $_"
        }
    }
}
