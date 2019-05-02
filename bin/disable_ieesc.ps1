$AdminsKey = "SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UsersKey = "SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
$BaseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey("LocalMachine","Default")

$SubKey = $BaseKey.OpenSubkey($AdminsKey,$true)
$SubKey.SetValue("IsInstalled",0,[Microsoft.Win32.RegistryValueKind]::DWORD)
$SubKey = $BaseKey.OpenSubKey($UsersKey,$true)
$SubKey.SetValue("IsInstalled",0,[Microsoft.Win32.RegistryValueKind]::DWORD)
