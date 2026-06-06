# =============================================================================
# Verify_CIS_WS2025_Status.ps1
# IF-5100 Proyecto BD - Verificador seguro de hardening Windows Server 2025
# NO modifica configuraciones. Solo audita y genera reporte.
# Verifica:
#   - Usuario adminbackup y acceso de emergencia
#   - Politicas de cuenta Parte 1
#   - User Rights / Local Policies Parte 2
#   - Firewall + Advanced Audit Parte 3
#   - Registry Administrative Templates Parte 4a/4b
# =============================================================================

$ErrorActionPreference = "Continue"

$ReportDir = "C:\CIS_Hardening\Reports"
New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvPath = Join-Path $ReportDir "CIS_WS2025_Verification_$Stamp.csv"
$TxtPath = Join-Path $ReportDir "CIS_WS2025_Verification_$Stamp.txt"
$SecCfgPath = Join-Path $ReportDir "security_policy_current_$Stamp.cfg"

$Results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [string]$Area,
        [string]$Control,
        [string]$Item,
        [string]$Expected,
        [string]$Actual,
        [string]$Status,
        [string]$Note = ""
    )
    $Results.Add([pscustomobject]@{
        Area = $Area
        Control = $Control
        Item = $Item
        Expected = $Expected
        Actual = $Actual
        Status = $Status
        Note = $Note
    }) | Out-Null
}

function Test-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Add-Result "PreCheck" "Admin" "PowerShell elevated" "True" "$isAdmin" $(if($isAdmin){"PASS"}else{"FAIL"}) "Debe ejecutarse como Administrador para leer todo correctamente."
}

function Get-LocalUserSafe {
    param([string]$Name)
    try { Get-LocalUser -Name $Name -ErrorAction Stop } catch { $null }
}

function Test-UserAndRdp {
    $backupUser = Get-LocalUserSafe "adminbackup"
    if ($backupUser) {
        Add-Result "Usuarios" "adminbackup" "Existe usuario adminbackup" "Exists" "Exists" "PASS"
        Add-Result "Usuarios" "adminbackup" "Cuenta adminbackup habilitada" "True" "$($backupUser.Enabled)" $(if($backupUser.Enabled){"PASS"}else{"FAIL"})
    } else {
        Add-Result "Usuarios" "adminbackup" "Existe usuario adminbackup" "Exists" "Missing" "FAIL" "No avances con hardening si no hay usuario de rescate."
    }

    $adminGroup = (net localgroup Administrators) 2>$null
    $rdpGroup = (net localgroup "Remote Desktop Users") 2>$null

    $isAdmin = ($adminGroup -match "adminbackup")
    Add-Result "Usuarios" "adminbackup" "Miembro de Administrators" "True" "$isAdmin" $(if($isAdmin){"PASS"}else{"FAIL"})

    $isRdp = ($rdpGroup -match "adminbackup")
    Add-Result "Usuarios" "adminbackup" "Miembro de Remote Desktop Users" "True" "$isRdp" $(if($isRdp){"PASS"}else{"WARN"}) "Si es Administrator puede entrar, pero para evidencia conviene tenerlo también en Remote Desktop Users."

    $builtinAdmin = Get-LocalUserSafe "Administrator"
    if ($builtinAdmin) {
        Add-Result "Usuarios" "Administrator" "Administrator deshabilitado" "False" "$($builtinAdmin.Enabled)" $(if(-not $builtinAdmin.Enabled){"PASS"}else{"WARN"}) "No lo deshabilites hasta confirmar que adminbackup entra por RDP."
    } else {
        Add-Result "Usuarios" "Administrator" "Usuario Administrator encontrado" "Exists" "Missing or renamed" "INFO"
    }

    try {
        $rdpDeny = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -ErrorAction Stop).fDenyTSConnections
        Add-Result "RDP" "RDP" "RDP habilitado en Windows" "0" "$rdpDeny" $(if($rdpDeny -eq 0){"PASS"}else{"FAIL"})
    } catch {
        Add-Result "RDP" "RDP" "RDP habilitado en Windows" "0" "ERROR" "FAIL" "$_"
    }

    $rdpRules = Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq "True"}
    Add-Result "RDP" "Firewall" "Reglas Remote Desktop habilitadas" "At least 1" "$($rdpRules.Count)" $(if($rdpRules.Count -gt 0){"PASS"}else{"FAIL"})
}

function Test-AccountPolicies {
    secedit /export /cfg $SecCfgPath /quiet | Out-Null
    $cfg = @{}
    if (Test-Path $SecCfgPath) {
        foreach ($line in Get-Content $SecCfgPath) {
            if ($line -match "^\s*([^;][^=]+?)\s*=\s*(.*?)\s*$") {
                $cfg[$Matches[1].Trim()] = $Matches[2].Trim()
            }
        }
    }

    $checks = @(
        @{Control="1.1.1"; Name="PasswordHistorySize"; Expected="24"},
        @{Control="1.1.2"; Name="MaximumPasswordAge"; Expected="365"},
        @{Control="1.1.3"; Name="MinimumPasswordAge"; Expected="1"},
        @{Control="1.1.4"; Name="MinimumPasswordLength"; Expected="14"},
        @{Control="1.1.5"; Name="PasswordComplexity"; Expected="1"},
        @{Control="1.1.7"; Name="ClearTextPassword"; Expected="0"},
        @{Control="1.2.1"; Name="LockoutDuration"; Expected="15"},
        @{Control="1.2.2"; Name="LockoutBadCount"; Expected="5"},
        @{Control="1.2.4"; Name="ResetLockoutCount"; Expected="15"}
    )

    foreach ($c in $checks) {
        $actual = if ($cfg.ContainsKey($c.Name)) { $cfg[$c.Name] } else { "MISSING" }
        $status = if ($actual -eq $c.Expected) { "PASS" } else { "FAIL" }
        Add-Result "Parte1 Account Policies" $c.Control $c.Name $c.Expected $actual $status
    }
}

function Test-UserRights {
    $expected = ConvertFrom-Json @'
[
  {
    "Name": "SeTrustedCredManAccessPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeNetworkLogonRight",
    "Expected": "*S-1-5-32-544,*S-1-5-11"
  },
  {
    "Name": "SeTcbPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeIncreaseQuotaPrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-19,*S-1-5-20"
  },
  {
    "Name": "SeRemoteInteractiveLogonRight",
    "Expected": "*S-1-5-32-544,*S-1-5-32-555"
  },
  {
    "Name": "SeBackupPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeSystemtimePrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-19"
  },
  {
    "Name": "SeCreatePagefilePrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeCreateTokenPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeCreateGlobalPrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6"
  },
  {
    "Name": "SeCreatePermanentPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeCreateSymbolicLinkPrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-83-0"
  },
  {
    "Name": "SeDebugPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeDenyBatchLogonRight",
    "Expected": "*S-1-5-32-546"
  },
  {
    "Name": "SeDenyServiceLogonRight",
    "Expected": "*S-1-5-32-546"
  },
  {
    "Name": "SeDenyInteractiveLogonRight",
    "Expected": "*S-1-5-32-546"
  },
  {
    "Name": "SeEnableDelegationPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeRemoteShutdownPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeAuditPrivilege",
    "Expected": "*S-1-5-19,*S-1-5-20"
  },
  {
    "Name": "SeImpersonatePrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6"
  },
  {
    "Name": "SeIncreaseBasePriorityPrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-90-0"
  },
  {
    "Name": "SeLoadDriverPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeLockMemoryPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeSecurityPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeRelabelPrivilege",
    "Expected": ""
  },
  {
    "Name": "SeSystemEnvironmentPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeManageVolumePrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeProfileSingleProcessPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeSystemProfilePrivilege",
    "Expected": "*S-1-5-32-544,*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420"
  },
  {
    "Name": "SeAssignPrimaryTokenPrivilege",
    "Expected": "*S-1-5-19,*S-1-5-20"
  },
  {
    "Name": "SeRestorePrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeShutdownPrivilege",
    "Expected": "*S-1-5-32-544"
  },
  {
    "Name": "SeTakeOwnershipPrivilege",
    "Expected": "*S-1-5-32-544"
  }
]
'@
    $content = if (Test-Path $SecCfgPath) { Get-Content $SecCfgPath } else { @() }
    $cfg = @{}
    foreach ($line in $content) {
        if ($line -match "^\s*(Se[A-Za-z0-9]+)\s*=\s*(.*?)\s*$") {
            $cfg[$Matches[1].Trim()] = $Matches[2].Trim()
        }
    }

    foreach ($r in $expected) {
        $actual = if ($cfg.ContainsKey($r.Name)) { $cfg[$r.Name] } else { "MISSING" }
        # Normalizamos espacios, no ordenamos porque secedit conserva SID normalmente.
        $exp = [string]$r.Expected
        $status = if ($actual -eq $exp) { "PASS" } else { "FAIL" }
        Add-Result "Parte2 User Rights" "2.2" $r.Name $exp $actual $status
    }
}

function Test-RegistryChecks {
    $checks = ConvertFrom-Json @'
[
  {
    "CIS": "2.3.1.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "LimitBlankPasswordUse",
    "Expected": "1",
    "Desc": "Limit blank passwords to console logon only = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.2.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "SCENoApplyLegacyAuditPolicy",
    "Expected": "1",
    "Desc": "Force audit policy subcategory settings = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.2.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "CrashOnAuditFail",
    "Expected": "0",
    "Desc": "Shut down if unable to log security audits = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.4.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Print\\Providers\\LanMan Print Services\\Servers",
    "Name": "AddPrinterDrivers",
    "Expected": "1",
    "Desc": "Prevent users from installing printer drivers = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "RequireSignOrSeal",
    "Expected": "1",
    "Desc": "Digitally encrypt or sign secure channel data (always) = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "SealSecureChannel",
    "Expected": "1",
    "Desc": "Digitally encrypt secure channel data (when possible) = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "SignSecureChannel",
    "Expected": "1",
    "Desc": "Digitally sign secure channel data (when possible) = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.4",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "DisablePasswordChange",
    "Expected": "0",
    "Desc": "Disable machine account password changes = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.5",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "MaximumPasswordAge",
    "Expected": "30",
    "Desc": "Maximum machine account password age = 30 days",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.6.6",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters",
    "Name": "RequireStrongKey",
    "Expected": "1",
    "Desc": "Require strong session key = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "DisableCAD",
    "Expected": "0",
    "Desc": "Do not require CTRL+ALT+DEL = Disabled (Level 2)",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.2",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "DontDisplayLastUserName",
    "Expected": "1",
    "Desc": "Don't display last signed-in = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.3",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "InactivityTimeoutSecs",
    "Expected": "900",
    "Desc": "Machine inactivity limit = 900 seconds",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.6",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon",
    "Name": "CachedLogonsCount",
    "Expected": "4",
    "Desc": "Number of previous logons to cache = 4 (Level 2)",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.7",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon",
    "Name": "PasswordExpiryWarning",
    "Expected": "14",
    "Desc": "Prompt to change password before expiration = 14 days",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.7.9",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon",
    "Name": "ScRemoveOption",
    "Expected": "1",
    "Desc": "Smart card removal behavior = Lock Workstation",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.8.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanWorkstation\\Parameters",
    "Name": "RequireSecuritySignature",
    "Expected": "1",
    "Desc": "Network client: Digitally sign communications (always) = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.8.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanWorkstation\\Parameters",
    "Name": "EnablePlainTextPassword",
    "Expected": "0",
    "Desc": "Send unencrypted password to third-party SMB = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.9.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "AutoDisconnect",
    "Expected": "15",
    "Desc": "Idle time before suspending session = 15 minutes",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.9.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "RequireSecuritySignature",
    "Expected": "1",
    "Desc": "Network server: Digitally sign communications (always) = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.9.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "enableforcedlogoff",
    "Expected": "1",
    "Desc": "Disconnect clients when logon hours expire = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.9.4",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "SMBServerNameHardeningLevel",
    "Expected": "1",
    "Desc": "Server SPN target name validation = Accept if provided by client",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "RestrictAnonymousSAM",
    "Expected": "1",
    "Desc": "Do not allow anonymous enumeration of SAM accounts = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "RestrictAnonymous",
    "Expected": "1",
    "Desc": "Do not allow anonymous enumeration of SAM accounts and shares = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.4",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "DisableDomainCreds",
    "Expected": "1",
    "Desc": "Do not allow storage of passwords for network auth = Enabled (Level 2)",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.5",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "EveryoneIncludesAnonymous",
    "Expected": "0",
    "Desc": "Let Everyone permissions apply to anonymous users = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.7",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "NullSessionPipes",
    "Expected": "@()",
    "Desc": "Named Pipes accessible anonymously = blank",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.8",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurePipeServers\\Winreg\\AllowedExactPaths",
    "Name": "Machine",
    "Expected": "$regPaths",
    "Desc": "Remotely accessible registry paths configured",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.9",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurePipeServers\\Winreg\\AllowedPaths",
    "Name": "Machine",
    "Expected": "$regSubPaths",
    "Desc": "Remotely accessible registry paths and sub-paths configured",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.10",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "RestrictNullSessAccess",
    "Expected": "1",
    "Desc": "Restrict anonymous access to Named Pipes and Shares = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.11",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "RestrictRemoteSAM",
    "Expected": "O:BAG:BAD:(A;;RC;;;BA)",
    "Desc": "Restrict remote calls to SAM = Administrators only",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.12",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "NullSessionShares",
    "Expected": "@()",
    "Desc": "Shares accessible anonymously = None",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.10.13",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "ForceGuest",
    "Expected": "0",
    "Desc": "Sharing and security model for local accounts = Classic",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "UseMachineId",
    "Expected": "1",
    "Desc": "Allow Local System to use computer identity for NTLM = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0",
    "Name": "AllowNullSessionFallback",
    "Expected": "0",
    "Desc": "Allow LocalSystem NULL session fallback = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\pku2u",
    "Name": "AllowOnlineID",
    "Expected": "0",
    "Desc": "Allow PKU2U authentication = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.4",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\Kerberos\\Parameters",
    "Name": "SupportedEncryptionTypes",
    "Expected": "2147483640",
    "Desc": "Kerberos encryption types = AES128, AES256, Future",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.5",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters",
    "Name": "EnableForcedLogOff",
    "Expected": "1",
    "Desc": "Force logoff when logon hours expire = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.6",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "LmCompatibilityLevel",
    "Expected": "5",
    "Desc": "LAN Manager authentication level = NTLMv2 only (level 5)",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.9",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0",
    "Name": "NTLMMinClientSec",
    "Expected": "537395200",
    "Desc": "Min session security NTLM SSP clients = NTLMv2+128bit",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.10",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0",
    "Name": "NTLMMinServerSec",
    "Expected": "537395200",
    "Desc": "Min session security NTLM SSP servers = NTLMv2+128bit",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.11",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0",
    "Name": "AuditReceivingNTLMTraffic",
    "Expected": "1",
    "Desc": "Restrict NTLM: Audit Incoming NTLM Traffic = Enable auditing",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.11.13",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0",
    "Name": "RestrictSendingNTLMTraffic",
    "Expected": "1",
    "Desc": "Restrict NTLM: Outgoing NTLM traffic = Audit all",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.13.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "ShutdownWithoutLogon",
    "Expected": "0",
    "Desc": "Allow system shutdown without logon = Disabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.15.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Kernel",
    "Name": "ObCaseInsensitive",
    "Expected": "1",
    "Desc": "Require case insensitivity for non-Windows subsystems = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.15.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager",
    "Name": "ProtectionMode",
    "Expected": "1",
    "Desc": "Strengthen default permissions of internal system objects = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "FilterAdministratorToken",
    "Expected": "1",
    "Desc": "Admin Approval Mode for Built-in Administrator = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.2",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "ConsentPromptBehaviorAdmin",
    "Expected": "2",
    "Desc": "Elevation prompt for admins = Prompt for consent on secure desktop",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.3",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "ConsentPromptBehaviorUser",
    "Expected": "0",
    "Desc": "Elevation prompt for standard users = Automatically deny",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.4",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "EnableInstallerDetection",
    "Expected": "1",
    "Desc": "Detect application installations and prompt for elevation = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.5",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "EnableSecureUIAPaths",
    "Expected": "1",
    "Desc": "Only elevate UIAccess apps in secure locations = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.6",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "EnableLUA",
    "Expected": "1",
    "Desc": "Run all administrators in Admin Approval Mode = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.7",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "PromptOnSecureDesktop",
    "Expected": "1",
    "Desc": "Switch to secure desktop when prompting = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "2.3.17.8",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "EnableVirtualization",
    "Expected": "1",
    "Desc": "Virtualize file and registry write failures = Enabled",
    "Source": "CIS_WS2025_Parte2_LocalPolicies(2).ps1"
  },
  {
    "CIS": "9.1.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile",
    "Name": "EnableFirewall",
    "Expected": "1",
    "Desc": "Domain: Firewall state = On",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile",
    "Name": "DefaultInboundAction",
    "Expected": "1",
    "Desc": "Domain: Inbound connections = Block",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile",
    "Name": "DisableNotifications",
    "Expected": "1",
    "Desc": "Domain: Display a notification = No",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile\\Logging",
    "Name": "LogFilePath",
    "Expected": "%SystemRoot%\\System32\\logfiles\\firewall\\domainfw.log",
    "Desc": "Domain: Logging Name = domainfw.log",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile\\Logging",
    "Name": "LogFileSize",
    "Expected": "16384",
    "Desc": "Domain: Log size = 16384 KB",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile\\Logging",
    "Name": "LogDroppedPackets",
    "Expected": "1",
    "Desc": "Domain: Log dropped packets = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.1.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\DomainProfile\\Logging",
    "Name": "LogSuccessfulConnections",
    "Expected": "1",
    "Desc": "Domain: Log successful connections = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile",
    "Name": "EnableFirewall",
    "Expected": "1",
    "Desc": "Private: Firewall state = On",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile",
    "Name": "DefaultInboundAction",
    "Expected": "1",
    "Desc": "Private: Inbound connections = Block",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile",
    "Name": "DisableNotifications",
    "Expected": "1",
    "Desc": "Private: Display a notification = No",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile\\Logging",
    "Name": "LogFilePath",
    "Expected": "%SystemRoot%\\System32\\logfiles\\firewall\\privatefw.log",
    "Desc": "Private: Logging Name = privatefw.log",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile\\Logging",
    "Name": "LogFileSize",
    "Expected": "16384",
    "Desc": "Private: Log size = 16384 KB",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile\\Logging",
    "Name": "LogDroppedPackets",
    "Expected": "1",
    "Desc": "Private: Log dropped packets = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.2.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PrivateProfile\\Logging",
    "Name": "LogSuccessfulConnections",
    "Expected": "1",
    "Desc": "Private: Log successful connections = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile",
    "Name": "EnableFirewall",
    "Expected": "1",
    "Desc": "Public: Firewall state = On",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile",
    "Name": "DefaultInboundAction",
    "Expected": "1",
    "Desc": "Public: Inbound connections = Block",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile",
    "Name": "DisableNotifications",
    "Expected": "1",
    "Desc": "Public: Display a notification = No",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile",
    "Name": "AllowLocalPolicyMerge",
    "Expected": "0",
    "Desc": "Public: Apply local firewall rules = No",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile",
    "Name": "AllowLocalIPsecPolicyMerge",
    "Expected": "0",
    "Desc": "Public: Apply local connection security rules = No",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile\\Logging",
    "Name": "LogFilePath",
    "Expected": "%SystemRoot%\\System32\\logfiles\\firewall\\publicfw.log",
    "Desc": "Public: Logging Name = publicfw.log",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile\\Logging",
    "Name": "LogFileSize",
    "Expected": "16384",
    "Desc": "Public: Log size = 16384 KB",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.8",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile\\Logging",
    "Name": "LogDroppedPackets",
    "Expected": "1",
    "Desc": "Public: Log dropped packets = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "9.3.9",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsFirewall\\PublicProfile\\Logging",
    "Name": "LogSuccessfulConnections",
    "Expected": "1",
    "Desc": "Public: Log successful connections = Yes",
    "Source": "CIS_WS2025_Parte3_Firewall_Audit(2).ps1"
  },
  {
    "CIS": "18.1.1.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Personalization",
    "Name": "NoLockScreenCamera",
    "Expected": "1",
    "Desc": "Prevent enabling lock screen camera = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.1.1.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Personalization",
    "Name": "NoLockScreenSlideshow",
    "Expected": "1",
    "Desc": "Prevent enabling lock screen slide show = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.1.2.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\InputPersonalization",
    "Name": "AllowInputPersonalization",
    "Expected": "0",
    "Desc": "Allow online speech recognition = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.1.3",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer",
    "Name": "AllowOnlineTips",
    "Expected": "0",
    "Desc": "Allow Online Tips = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
    "Name": "LocalAccountTokenFilterPolicy",
    "Expected": "0",
    "Desc": "Apply UAC restrictions to local accounts on network logons = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\MrxSmb10",
    "Name": "Start",
    "Expected": "4",
    "Desc": "SMB v1 client driver = Disabled (4)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters",
    "Name": "SMB1",
    "Expected": "0",
    "Desc": "SMB v1 server = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.4",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Cryptography\\Wintrust\\Config",
    "Name": "EnableCertPaddingCheck",
    "Expected": "1",
    "Desc": "Enable Certificate Padding = Enabled (32-bit)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.4",
    "Path": "HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Cryptography\\Wintrust\\Config",
    "Name": "EnableCertPaddingCheck",
    "Expected": "1",
    "Desc": "Enable Certificate Padding = Enabled (64-bit)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.5",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel",
    "Name": "DisableExceptionChainValidation",
    "Expected": "0",
    "Desc": "Enable SEHOP = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.4.6",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\NetBT\\Parameters",
    "Name": "NodeType",
    "Expected": "2",
    "Desc": "NetBT NodeType = P-node (2)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon",
    "Name": "AutoAdminLogon",
    "Expected": "0",
    "Desc": "AutoAdminLogon = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.2",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip6\\Parameters",
    "Name": "DisableIPSourceRouting",
    "Expected": "2",
    "Desc": "DisableIPSourceRouting IPv6 = Highest protection (2)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
    "Name": "DisableIPSourceRouting",
    "Expected": "2",
    "Desc": "DisableIPSourceRouting IPv4 = Highest protection (2)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.4",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
    "Name": "EnableICMPRedirect",
    "Expected": "0",
    "Desc": "EnableICMPRedirect = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.6",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\NetBT\\Parameters",
    "Name": "NoNameReleaseOnDemand",
    "Expected": "1",
    "Desc": "NoNameReleaseOnDemand = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.7",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
    "Name": "PerformRouterDiscovery",
    "Expected": "0",
    "Desc": "PerformRouterDiscovery = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.8",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager",
    "Name": "SafeDllSearchMode",
    "Expected": "1",
    "Desc": "SafeDllSearchMode = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.9",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip6\\Parameters",
    "Name": "TcpMaxDataRetransmissions",
    "Expected": "3",
    "Desc": "TcpMaxDataRetransmissions IPv6 = 3",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.10",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
    "Name": "TcpMaxDataRetransmissions",
    "Expected": "3",
    "Desc": "TcpMaxDataRetransmissions IPv4 = 3",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.5.11",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Eventlog\\Security",
    "Name": "WarningLevel",
    "Expected": "90",
    "Desc": "Security event log warning level = 90%",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.4.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\DNSClient",
    "Name": "EnableMDNS",
    "Expected": "0",
    "Desc": "Configure multicast DNS (mDNS) = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.4.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\DNSClient",
    "Name": "EnableNetbios",
    "Expected": "2",
    "Desc": "Configure NetBIOS settings = Disable NetBIOS (2)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.4.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\DNSClient",
    "Name": "EnableMulticast",
    "Expected": "0",
    "Desc": "Turn off multicast name resolution = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.5.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "EnableFontProviders",
    "Expected": "0",
    "Desc": "Enable Font Providers = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "AuditClientDoesNotSupportEncryption",
    "Expected": "1",
    "Desc": "Audit client does not support encryption = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "AuditClientDoesNotSupportSigning",
    "Expected": "1",
    "Desc": "Audit client does not support signing = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "AuditInsecureGuestLogon",
    "Expected": "1",
    "Desc": "LanmanServer: Audit insecure guest logon = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "EnableAuthRateLimiter",
    "Expected": "1",
    "Desc": "Enable authentication rate limiter = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Bowser",
    "Name": "EnableMailslots",
    "Expected": "0",
    "Desc": "Enable remote mailslots (Bowser) = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "MinSmb2Dialect",
    "Expected": "785",
    "Desc": "LanmanServer MinSmb2Dialect = 785 (SMB 3.1.1)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.7.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanServer",
    "Name": "InvalidAuthenticationDelay",
    "Expected": "2000",
    "Desc": "Authentication rate limiter delay = 2000ms",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "AuditInsecureGuestLogon",
    "Expected": "1",
    "Desc": "LanmanWorkstation: Audit insecure guest logon = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "AuditServerDoesNotSupportEncryption",
    "Expected": "1",
    "Desc": "Audit server does not support encryption = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "AuditServerDoesNotSupportSigning",
    "Expected": "1",
    "Desc": "Audit server does not support signing = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "AllowInsecureGuestLogons",
    "Expected": "0",
    "Desc": "Enable insecure guest logons = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\NetworkProvider",
    "Name": "EnableMailslots",
    "Expected": "0",
    "Desc": "Enable remote mailslots (NetworkProvider) = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "MinSmb2Dialect",
    "Expected": "785",
    "Desc": "LanmanWorkstation MinSmb2Dialect = 785 (SMB 3.1.1)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.8.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LanmanWorkstation",
    "Name": "RequireEncryption",
    "Expected": "1",
    "Desc": "Require Encryption = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "AllowLLTDIOOnDomain",
    "Expected": "0",
    "Desc": "LLTDIO driver = Disabled (domain)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "AllowLLTDIOOnPublicNet",
    "Expected": "0",
    "Desc": "LLTDIO driver = Disabled (public)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "EnableLLTDIO",
    "Expected": "0",
    "Desc": "LLTDIO driver = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "ProhibitLLTDIOOnPrivateNet",
    "Expected": "0",
    "Desc": "LLTDIO driver = Disabled (private)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "AllowRspndrOnDomain",
    "Expected": "0",
    "Desc": "RSPNDR driver = Disabled (domain)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "AllowRspndrOnPublicNet",
    "Expected": "0",
    "Desc": "RSPNDR driver = Disabled (public)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "EnableRspndr",
    "Expected": "0",
    "Desc": "RSPNDR driver = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.9.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LLTD",
    "Name": "ProhibitRspndrOnPrivateNet",
    "Expected": "0",
    "Desc": "RSPNDR driver = Disabled (private)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.10.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Peernet",
    "Name": "Disabled",
    "Expected": "1",
    "Desc": "Turn off Microsoft Peer-to-Peer Networking = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.11.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections",
    "Name": "NC_AllowNetBridge_NLA",
    "Expected": "0",
    "Desc": "Prohibit Network Bridge installation = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.11.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections",
    "Name": "NC_ShowSharedAccessUI",
    "Expected": "0",
    "Desc": "Prohibit Internet Connection Sharing = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.11.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections",
    "Name": "NC_StdDomainUserSetLocation",
    "Expected": "1",
    "Desc": "Require elevation for network location = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.19.2.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip6\\Parameters",
    "Name": "DisabledComponents",
    "Expected": "255",
    "Desc": "Disable IPv6 = 0xff (all IPv6 disabled)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\Registrars",
    "Name": "EnableRegistrars",
    "Expected": "0",
    "Desc": "Windows Connect Now wireless config = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\Registrars",
    "Name": "DisableUPnPRegistrar",
    "Expected": "0",
    "Desc": "WCN UPnP Registrar = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\Registrars",
    "Name": "DisableInBand802DOT11Registrar",
    "Expected": "0",
    "Desc": "WCN InBand 802.11 = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\Registrars",
    "Name": "DisableFlashConfigRegistrar",
    "Expected": "0",
    "Desc": "WCN Flash Config = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\Registrars",
    "Name": "DisableWPDRegistrar",
    "Expected": "0",
    "Desc": "WCN WPD Registrar = Disabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.20.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WCN\\UI",
    "Name": "DisableWcnUi",
    "Expected": "1",
    "Desc": "Prohibit WCN wizards = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.21.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy",
    "Name": "fMinimizeConnections",
    "Expected": "3",
    "Desc": "Minimize simultaneous connections = 3 (Prevent Wi-Fi when on Ethernet)",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.6.21.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy",
    "Name": "fBlockNonDomain",
    "Expected": "1",
    "Desc": "Prohibit connection to non-domain networks = Enabled",
    "Source": "CIS_WS2025_Parte4a_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.3.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\Audit",
    "Name": "ProcessCreationIncludeCmdLine_Enabled",
    "Expected": "1",
    "Desc": "Include command line in process creation events = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.4.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\CredSSP\\Parameters",
    "Name": "AllowEncryptionOracle",
    "Expected": "0",
    "Desc": "Encryption Oracle Remediation = Force Updated Clients (0)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.4.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CredentialsDelegation",
    "Name": "AllowProtectedCreds",
    "Expected": "1",
    "Desc": "Remote host allows delegation of non-exportable credentials = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "EnableVirtualizationBasedSecurity",
    "Expected": "1",
    "Desc": "Turn on Virtualization Based Security = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "RequirePlatformSecurityFeatures",
    "Expected": "1",
    "Desc": "VBS Platform Security Level = Secure Boot (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "HypervisorEnforcedCodeIntegrity",
    "Expected": "1",
    "Desc": "Virtualization Based Protection of Code Integrity = Enabled with UEFI lock (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "HVCIMATRequired",
    "Expected": "1",
    "Desc": "Require UEFI Memory Attributes Table = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "LsaCfgFlags",
    "Expected": "1",
    "Desc": "Credential Guard = Enabled with UEFI lock (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.5.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard",
    "Name": "ConfigureSystemGuardLaunch",
    "Expected": "1",
    "Desc": "Secure Launch = Enabled (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.7.1.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceInstall\\Restrictions",
    "Name": "DenyDeviceIDs",
    "Expected": "1",
    "Desc": "Prevent installation of devices matching any of these device IDs = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.7.1.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceInstall\\Restrictions",
    "Name": "DenyDeviceIDsRetroactive",
    "Expected": "1",
    "Desc": "Also apply to matching devices already installed = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.7.1.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceInstall\\Restrictions",
    "Name": "DenyDeviceClasses",
    "Expected": "1",
    "Desc": "Prevent installation of devices using drivers that match device setup classes = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.7.1.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceInstall\\Restrictions",
    "Name": "DenyDeviceClassesRetroactive",
    "Expected": "1",
    "Desc": "Also apply to matching devices already installed (classes) = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.13.1",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Policies",
    "Name": "ClfsAuthenticationChecking",
    "Expected": "1",
    "Desc": "CLFS Authentication Checking = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "EnableCdp",
    "Expected": "0",
    "Desc": "Turn off CDP = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Printers",
    "Name": "DisableWebPnPDownload",
    "Expected": "1",
    "Desc": "Turn off downloading print drivers via HTTP = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\TabletPC",
    "Name": "PreventHandwritingDataSharing",
    "Expected": "1",
    "Desc": "Turn off handwriting personalization data sharing = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\HandwritingErrorReports",
    "Name": "PreventHandwritingErrorReports",
    "Expected": "1",
    "Desc": "Turn off handwriting recognition error reporting = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Internet Connection Wizard",
    "Name": "ExitOnMSICW",
    "Expected": "1",
    "Desc": "Turn off Internet Connection Wizard = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.6",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer",
    "Name": "NoWebServices",
    "Expected": "1",
    "Desc": "Turn off Internet download for Web publishing = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Printers",
    "Name": "DisableHTTPPrinting",
    "Expected": "1",
    "Desc": "Turn off printing over HTTP = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.8",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Registration Wizard Control",
    "Name": "NoRegistration",
    "Expected": "1",
    "Desc": "Turn off Registration if URL connection available = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.9",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\SearchCompanion",
    "Name": "DisableContentFileUpdates",
    "Expected": "1",
    "Desc": "Turn off Search Companion content file updates = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.10",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer",
    "Name": "NoOnlinePrintsWizard",
    "Expected": "1",
    "Desc": "Turn off the Order Prints picture task = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.11",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer",
    "Name": "NoPublishingWizard",
    "Expected": "1",
    "Desc": "Turn off the Publish to Web task = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.12",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Messenger\\Client",
    "Name": "CEIP",
    "Expected": "2",
    "Desc": "Turn off Windows Messenger Customer Experience = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.20.1.13",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows",
    "Name": "CEIPEnable",
    "Expected": "0",
    "Desc": "Turn off Windows Customer Experience Improvement = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.24.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Kernel DMA Protection",
    "Name": "DeviceEnumerationPolicy",
    "Expected": "0",
    "Desc": "Enumeration policy for external devices incompatible with DMA = Block all (0)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "BackupDirectory",
    "Expected": "1",
    "Desc": "LAPS: Configure backup directory = Active Directory (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.2",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "PasswordExpirationProtectionEnabled",
    "Expected": "1",
    "Desc": "LAPS: Do not allow password expiration longer than required = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.3",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "ADPasswordEncryptionEnabled",
    "Expected": "1",
    "Desc": "LAPS: Enable password encryption = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.5",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "PasswordComplexity",
    "Expected": "4",
    "Desc": "LAPS: Password complexity = Large letters+small+numbers+specials (4)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.6",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "PasswordLength",
    "Expected": "15",
    "Desc": "LAPS: Password length = 15",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.7",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "PasswordAgeDays",
    "Expected": "30",
    "Desc": "LAPS: Password age = 30 days",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.25.8",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\LAPS",
    "Name": "PostAuthenticationActions",
    "Expected": "3",
    "Desc": "LAPS: Post-auth actions = Reset password + logoff (3)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.26.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "AllowCustomSSPsAPs",
    "Expected": "0",
    "Desc": "Allow Custom SSPs and APs = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.26.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "RunAsPPL",
    "Expected": "1",
    "Desc": "Configures LSASS to run as a protected process = Enabled (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "BlockUserFromShowingAccountDetailsOnSignin",
    "Expected": "1",
    "Desc": "Block user from showing account details on sign-in = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "DontDisplayNetworkSelectionUI",
    "Expected": "1",
    "Desc": "Do not display network selection UI = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "DontEnumerateConnectedUsers",
    "Expected": "1",
    "Desc": "Do not enumerate connected users on domain-joined computers = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "EnumerateLocalUsers",
    "Expected": "0",
    "Desc": "Enumerate local users on domain-joined computers = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "DisableLockScreenAppNotifications",
    "Expected": "1",
    "Desc": "Turn off app notifications on lock screen = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "AllowDomainPINLogon",
    "Expected": "0",
    "Desc": "Turn off picture password sign-in = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.27.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Netlogon\\Parameters",
    "Name": "BlockNetbiosDiscovery",
    "Expected": "1",
    "Desc": "Turn on convenience PIN sign-in = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.28.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "AllowCrossDeviceClipboard",
    "Expected": "0",
    "Desc": "Allow Clipboard synchronization across devices = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.28.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System",
    "Name": "UploadUserActivities",
    "Expected": "0",
    "Desc": "Allow publishing of User Activities = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.31.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Power\\PowerSettings\\$pwrGuid1",
    "Name": "DCSettingIndex",
    "Expected": "0",
    "Desc": "Require password on wakeup (battery) = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.31.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Power\\PowerSettings\\$pwrGuid1",
    "Name": "ACSettingIndex",
    "Expected": "0",
    "Desc": "Require password on wakeup (plugged in) = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.31.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Power\\PowerSettings\\$pwrGuid2",
    "Name": "DCSettingIndex",
    "Expected": "1",
    "Desc": "Require password when computer wakes (battery) = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.31.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Power\\PowerSettings\\$pwrGuid2",
    "Name": "ACSettingIndex",
    "Expected": "1",
    "Desc": "Require password when computer wakes (plugged in) = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.35.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fAllowUnsolicited",
    "Expected": "0",
    "Desc": "Configure Offer Remote Assistance = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.35.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fAllowToGetHelp",
    "Expected": "0",
    "Desc": "Configure Solicited Remote Assistance = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.36.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Rpc",
    "Name": "EnableAuthEpResolution",
    "Expected": "1",
    "Desc": "Enable RPC Endpoint Mapper Client Authentication = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.36.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Rpc",
    "Name": "RestrictRemoteClients",
    "Expected": "1",
    "Desc": "Restrict Unauthenticated RPC clients = Authenticated (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.37.1",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\SAM",
    "Name": "SamNGCKeyROCAValidation",
    "Expected": "2",
    "Desc": "Configure validation of ROCA-vulnerable WHfB keys = Audit (2)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.37.2",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\SAM",
    "Name": "SamrChangedPasswordViaLogon",
    "Expected": "2",
    "Desc": "Configure SAM change password logon = Block (2)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.37.3",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\SAM",
    "Name": "SamrChangedPasswordViaLogonRemote",
    "Expected": "1",
    "Desc": "Configure SAM change password remote = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.1.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Application",
    "Name": "MaxSize",
    "Expected": "32768",
    "Desc": "Application log max size = 32768 KB",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.1.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Application",
    "Name": "Retention",
    "Expected": "0",
    "Desc": "Application log retention = Overwrite as needed",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.2.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Security",
    "Name": "MaxSize",
    "Expected": "196608",
    "Desc": "Security log max size = 196608 KB",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.2.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Security",
    "Name": "Retention",
    "Expected": "0",
    "Desc": "Security log retention = Overwrite as needed",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.3.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Setup",
    "Name": "MaxSize",
    "Expected": "32768",
    "Desc": "Setup log max size = 32768 KB",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.3.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Setup",
    "Name": "Retention",
    "Expected": "0",
    "Desc": "Setup log retention = Overwrite as needed",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.4.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\System",
    "Name": "MaxSize",
    "Expected": "32768",
    "Desc": "System log max size = 32768 KB",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.47.4.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\System",
    "Name": "Retention",
    "Expected": "0",
    "Desc": "System log retention = Overwrite as needed",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.52.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer",
    "Name": "DisableMotWOnInsecurePathCompletion",
    "Expected": "0",
    "Desc": "Disable MotW on insecure path completion = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.52.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer",
    "Name": "NoDataExecutionPrevention",
    "Expected": "0",
    "Desc": "Turn off Data Execution Prevention for Explorer = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.52.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer",
    "Name": "NoHeapTerminationOnCorruption",
    "Expected": "0",
    "Desc": "Turn off heap termination on corruption = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.52.4",
    "Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer",
    "Name": "PreXPSP2ShellProtocolBehavior",
    "Expected": "0",
    "Desc": "Turn off shell protocol protected mode = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.58.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\LocationAndSensors",
    "Name": "DisableLocation",
    "Expected": "1",
    "Desc": "Turn off location = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.63.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Messaging",
    "Name": "AllowMessageSync",
    "Expected": "0",
    "Desc": "Allow Message Service Cloud Sync = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.64.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\MicrosoftAccount",
    "Name": "DisableUserAuth",
    "Expected": "1",
    "Desc": "Block all consumer Microsoft account authentication = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Features",
    "Name": "PassiveRemediation",
    "Expected": "1",
    "Desc": "Defender: Configure Behavior Monitoring = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Spynet",
    "Name": "SpynetReporting",
    "Expected": "2",
    "Desc": "Join Microsoft MAPS = Advanced MAPS (2)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection",
    "Name": "DisableBehaviorMonitoring",
    "Expected": "0",
    "Desc": "Turn off behavior monitoring = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection",
    "Name": "DisableIOAVProtection",
    "Expected": "0",
    "Desc": "Scan all downloaded files and attachments = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection",
    "Name": "DisableRealtimeMonitoring",
    "Expected": "0",
    "Desc": "Turn off real-time protection = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection",
    "Name": "DisableScriptScanning",
    "Expected": "0",
    "Desc": "Turn on script scanning = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.7",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Scan",
    "Name": "DisableEmailScanning",
    "Expected": "0",
    "Desc": "Turn on e-mail scanning = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.65.8",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender",
    "Name": "PUAProtection",
    "Expected": "1",
    "Desc": "Configure detection for PUAs = Enabled (1)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.74.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\PushToInstall",
    "Name": "DisablePushToInstall",
    "Expected": "1",
    "Desc": "Turn off Push To Install service = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fDisableCcm",
    "Expected": "1",
    "Desc": "Do not allow COM port redirection = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.2",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fDisableCdm",
    "Expected": "1",
    "Desc": "Do not allow drive redirection = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.3",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fPromptForPassword",
    "Expected": "1",
    "Desc": "Always prompt for password upon connection = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.4",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fEncryptRPCTraffic",
    "Expected": "1",
    "Desc": "Require secure RPC communication = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.5",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "MinEncryptionLevel",
    "Expected": "3",
    "Desc": "Set client connection encryption level = High (3)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.6",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "SecurityLayer",
    "Expected": "2",
    "Desc": "Require use of specific security layer = SSL (2)",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.8",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "MaxIdleTime",
    "Expected": "900000",
    "Desc": "Set time limit for active but idle sessions = 15 min",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.9",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "MaxDisconnectionTime",
    "Expected": "60000",
    "Desc": "Set time limit for disconnected sessions = 1 min",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.10",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fDisableLPT",
    "Expected": "1",
    "Desc": "Do not allow LPT port redirection = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.75.11",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services",
    "Name": "fDisablePNPRedir",
    "Expected": "1",
    "Desc": "Do not allow supported Plug and Play device redirection = Enabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.82.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\ScriptedDiagnosticsProvider\\Policy",
    "Name": "DisableQueryRemoteServer",
    "Expected": "0",
    "Desc": "Microsoft Support Diagnostic Tool: Turn off MSDT = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "18.9.83.1",
    "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search",
    "Name": "AllowIndexingEncryptedStoresOrItems",
    "Expected": "0",
    "Desc": "Allow indexing of encrypted files = Disabled",
    "Source": "CIS_WS2025_Parte4b_AdminTemplates(2).ps1"
  },
  {
    "CIS": "1.1.6",
    "Path": "HKLM:\\System\\CurrentControlSet\\Control\\SAM",
    "Name": "RelaxMinimumPasswordLengthLimits",
    "Expected": "1",
    "Desc": "Relax minimum password length limits = Enabled",
    "Source": "Parte1"
  },
  {
    "CIS": "1.2.3",
    "Path": "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa",
    "Name": "AllowAdministratorLockout",
    "Expected": "1",
    "Desc": "Allow Administrator account lockout = Enabled",
    "Source": "Parte1"
  }
]
'@
    foreach ($c in $checks) {
        try {
            $prop = Get-ItemProperty -Path $c.Path -Name $c.Name -ErrorAction Stop
            $actual = [string]$prop.($c.Name)
            $expected = [string]$c.Expected
            $status = if ($actual -eq $expected) { "PASS" } else { "FAIL" }
            Add-Result "Registry CIS" $c.CIS "$($c.Path)\$($c.Name)" $expected $actual $status $c.Desc
        } catch {
            Add-Result "Registry CIS" $c.CIS "$($c.Path)\$($c.Name)" ([string]$c.Expected) "MISSING" "FAIL" $c.Desc
        }
    }
}

function Test-AuditPolicies {
    $checks = ConvertFrom-Json @'
[
  {
    "Category": "Account Logon",
    "Subcategory": "Credential Validation",
    "Setting": "Success and Failure",
    "CIS": "17.1.1",
    "Desc": "Audit Credential Validation"
  },
  {
    "Category": "Account Management",
    "Subcategory": "Application Group Management",
    "Setting": "Success and Failure",
    "CIS": "17.2.1",
    "Desc": "Audit Application Group Management"
  },
  {
    "Category": "Account Management",
    "Subcategory": "Security Group Management",
    "Setting": "Success",
    "CIS": "17.2.5",
    "Desc": "Audit Security Group Management"
  },
  {
    "Category": "Account Management",
    "Subcategory": "User Account Management",
    "Setting": "Success and Failure",
    "CIS": "17.2.6",
    "Desc": "Audit User Account Management"
  },
  {
    "Category": "Detailed Tracking",
    "Subcategory": "Plug and Play Events",
    "Setting": "Success",
    "CIS": "17.3.1",
    "Desc": "Audit PNP Activity"
  },
  {
    "Category": "Detailed Tracking",
    "Subcategory": "Process Creation",
    "Setting": "Success",
    "CIS": "17.3.2",
    "Desc": "Audit Process Creation"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Account Lockout",
    "Setting": "Failure",
    "CIS": "17.5.1",
    "Desc": "Audit Account Lockout"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Group Membership",
    "Setting": "Success",
    "CIS": "17.5.2",
    "Desc": "Audit Group Membership"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Logoff",
    "Setting": "Success",
    "CIS": "17.5.3",
    "Desc": "Audit Logoff"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Logon",
    "Setting": "Success and Failure",
    "CIS": "17.5.4",
    "Desc": "Audit Logon"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Other Logon/Logoff Events",
    "Setting": "Success and Failure",
    "CIS": "17.5.5",
    "Desc": "Audit Other Logon/Logoff Events"
  },
  {
    "Category": "Logon/Logoff",
    "Subcategory": "Special Logon",
    "Setting": "Success",
    "CIS": "17.5.6",
    "Desc": "Audit Special Logon"
  },
  {
    "Category": "Object Access",
    "Subcategory": "Detailed File Share",
    "Setting": "Failure",
    "CIS": "17.6.1",
    "Desc": "Audit Detailed File Share"
  },
  {
    "Category": "Object Access",
    "Subcategory": "File Share",
    "Setting": "Success and Failure",
    "CIS": "17.6.2",
    "Desc": "Audit File Share"
  },
  {
    "Category": "Object Access",
    "Subcategory": "Other Object Access Events",
    "Setting": "Success and Failure",
    "CIS": "17.6.3",
    "Desc": "Audit Other Object Access Events"
  },
  {
    "Category": "Object Access",
    "Subcategory": "Removable Storage",
    "Setting": "Success and Failure",
    "CIS": "17.6.4",
    "Desc": "Audit Removable Storage"
  },
  {
    "Category": "Policy Change",
    "Subcategory": "Audit Policy Change",
    "Setting": "Success",
    "CIS": "17.7.1",
    "Desc": "Audit Audit Policy Change"
  },
  {
    "Category": "Policy Change",
    "Subcategory": "Authentication Policy Change",
    "Setting": "Success",
    "CIS": "17.7.2",
    "Desc": "Audit Authentication Policy Change"
  },
  {
    "Category": "Policy Change",
    "Subcategory": "Authorization Policy Change",
    "Setting": "Success",
    "CIS": "17.7.3",
    "Desc": "Audit Authorization Policy Change"
  },
  {
    "Category": "Policy Change",
    "Subcategory": "MPSSVC Rule-Level Policy Change",
    "Setting": "Success and Failure",
    "CIS": "17.7.4",
    "Desc": "Audit MPSSVC Rule-Level Policy Change"
  },
  {
    "Category": "Policy Change",
    "Subcategory": "Other Policy Change Events",
    "Setting": "Failure",
    "CIS": "17.7.5",
    "Desc": "Audit Other Policy Change Events"
  },
  {
    "Category": "Privilege Use",
    "Subcategory": "Sensitive Privilege Use",
    "Setting": "Success and Failure",
    "CIS": "17.8.1",
    "Desc": "Audit Sensitive Privilege Use"
  },
  {
    "Category": "System",
    "Subcategory": "IPsec Driver",
    "Setting": "Success and Failure",
    "CIS": "17.9.1",
    "Desc": "Audit IPsec Driver"
  },
  {
    "Category": "System",
    "Subcategory": "Other System Events",
    "Setting": "Success and Failure",
    "CIS": "17.9.2",
    "Desc": "Audit Other System Events"
  },
  {
    "Category": "System",
    "Subcategory": "Security State Change",
    "Setting": "Success",
    "CIS": "17.9.3",
    "Desc": "Audit Security State Change"
  },
  {
    "Category": "System",
    "Subcategory": "Security System Extension",
    "Setting": "Success",
    "CIS": "17.9.4",
    "Desc": "Audit Security System Extension"
  },
  {
    "Category": "System",
    "Subcategory": "System Integrity",
    "Setting": "Success and Failure",
    "CIS": "17.9.5",
    "Desc": "Audit System Integrity"
  }
]
'@
    foreach ($a in $checks) {
        try {
            $out = auditpol /get /subcategory:"$($a.Subcategory)" 2>$null
            $line = $out | Where-Object { $_ -match [regex]::Escape($a.Subcategory) } | Select-Object -First 1
            $actual = if ($line) { ($line -replace "^\s*$([regex]::Escape($a.Subcategory))\s+", "").Trim() } else { "MISSING" }
            $expected = [string]$a.Setting

            $pass = $false
            if ($expected -eq "Success and Failure") { $pass = ($actual -match "Success" -and $actual -match "Failure") }
            elseif ($expected -eq "Success") { $pass = ($actual -match "Success" -and $actual -notmatch "Failure") }
            elseif ($expected -eq "Failure") { $pass = ($actual -match "Failure" -and $actual -notmatch "Success") }

            Add-Result "Parte3 Audit Policy" $a.CIS $a.Subcategory $expected $actual $(if($pass){"PASS"}else{"FAIL"}) $a.Desc
        } catch {
            Add-Result "Parte3 Audit Policy" $a.CIS $a.Subcategory ([string]$a.Setting) "ERROR" "FAIL" "$_"
        }
    }
}

function Test-FirewallProfiles {
    foreach ($profile in "Domain","Private","Public") {
        try {
            $p = Get-NetFirewallProfile -Profile $profile
            Add-Result "Parte3 Firewall" "9.x" "$profile Firewall Enabled" "True" "$($p.Enabled)" $(if($p.Enabled){"PASS"}else{"FAIL"})
            Add-Result "Parte3 Firewall" "9.x" "$profile DefaultInboundAction" "Block" "$($p.DefaultInboundAction)" $(if($p.DefaultInboundAction -eq "Block"){"PASS"}else{"FAIL"})
            Add-Result "Parte3 Firewall" "9.x" "$profile LogBlocked" "True" "$($p.LogBlocked)" $(if($p.LogBlocked){"PASS"}else{"FAIL"})
            Add-Result "Parte3 Firewall" "9.x" "$profile LogAllowed" "True" "$($p.LogAllowed)" $(if($p.LogAllowed){"PASS"}else{"FAIL"})
        } catch {
            Add-Result "Parte3 Firewall" "9.x" "$profile profile" "Readable" "ERROR" "FAIL" "$_"
        }
    }
}

Write-Host "`n=== CIS WS2025 VERIFICATION - READ ONLY ===" -ForegroundColor Cyan
Test-Admin
Test-UserAndRdp
Test-AccountPolicies
Test-UserRights
Test-FirewallProfiles
Test-AuditPolicies
Test-RegistryChecks

$Results | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

$summary = $Results | Group-Object Status | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Count)" }
$summary | Out-File -FilePath $TxtPath -Encoding UTF8
"`nDetalle CSV: $CsvPath" | Out-File -FilePath $TxtPath -Append -Encoding UTF8
"Security export: $SecCfgPath" | Out-File -FilePath $TxtPath -Append -Encoding UTF8

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
$Results | Group-Object Status | Sort-Object Name | Format-Table Name,Count -AutoSize

Write-Host "`n=== FALLAS / WARNINGS ===" -ForegroundColor Yellow
$Results | Where-Object { $_.Status -ne "PASS" } | Format-Table Area,Control,Item,Expected,Actual,Status -AutoSize

Write-Host "`nReporte CSV: $CsvPath" -ForegroundColor Green
Write-Host "Resumen TXT: $TxtPath" -ForegroundColor Green
Write-Host "Export secedit: $SecCfgPath" -ForegroundColor Green
Write-Host "`nNo se modificó ninguna configuración." -ForegroundColor Cyan
