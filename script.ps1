# Import VMware PowerCLI module
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
}
Import-Module VMware.PowerCLI

# Disable confirmation prompts for invalid certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# CSV file paths
$hostsCsvPath = "$scriptDir\hosts.csv"
$portGroupsCsvPath = "$scriptDir\portgroups.csv"

# Verify that the files exist
if (-Not (Test-Path $portGroupsCsvPath)) {
    Write-Host "ERROR: The file portgroups.csv does not exist at $portGroupsCsvPath" -ForegroundColor Red
    exit
}

if (-Not (Test-Path $hostsCsvPath)) {
    Write-Host "ERROR: The file hosts.csv does not exist at $hostsCsvPath" -ForegroundColor Red
    exit
}

# Import data from CSV files
$hosts = Import-Csv -Path $hostsCsvPath
$portGroups = Import-Csv -Path $portGroupsCsvPath

# Check if hosts are present in the CSV
if ($hosts.Count -eq 0) {
    Write-Host "WARNING: No hosts found in the hosts.csv file. Exiting..." -ForegroundColor Yellow
    exit
}

# Display the found hosts
Write-Host "Found hosts:"
$hosts | ForEach-Object { Write-Host $_.ESXiHost }

# Prompt for ESXi credentials
$cred = Get-Credential -Message "Enter credentials for ESXi hosts"

# Iterate over ESXi hosts
foreach ($esxi in $hosts) {
    $esxiHost = $esxi.ESXiHost.Trim()

    if ([string]::IsNullOrEmpty($esxiHost)) {
        Write-Host "WARNING: Empty host, skipping..." -ForegroundColor Yellow
        continue
    }

    Write-Host "Connecting to $esxiHost..."
    $esxiConnection = Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction SilentlyContinue

    if ($esxiConnection) {
        foreach ($pg in $portGroups) {
            $vSwitch = $pg.VSwitch
            $portGroup = $pg.PortGroup
            $vlanId = $pg.VLAN

            # Assign VLAN 0 if empty or "NONE"
            if ([string]::IsNullOrEmpty($vlanId) -or $vlanId -eq "NONE") {
                $vlanId = 0
            } else {
                $vlanId = [int]$vlanId  # Convert to integer to avoid errors
            }

            # Debugging output
            Write-Host "Creating Port Group: $portGroup - VLAN ID: $vlanId on $esxiHost"

            # Check if the Port Group already exists
            $existingPG = Get-VMHost -Name $esxiHost | Get-VirtualPortGroup | Where-Object { $_.Name -eq $portGroup }

            if ($existingPG) {
                Write-Host "WARNING: Port Group '$portGroup' already exists on $esxiHost, skipping..." -ForegroundColor Yellow
                continue
            }

            # Create Port Group and check success
            $newPG = Get-VMHost -Name $esxiHost | Get-VirtualSwitch -Name $vSwitch | New-VirtualPortGroup -Name $portGroup -VLanId $vlanId
            
            if ($newPG) {
                Write-Host "SUCCESS: Port Group '$portGroup' created on $esxiHost!" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Failed to create Port Group '$portGroup' on $esxiHost." -ForegroundColor Red
            }
        }

        # Disconnect from host
        Disconnect-VIServer -Server $esxiHost -Confirm:$false -Force
    } else {
        Write-Host "ERROR: Failed to connect to $esxiHost, skipping..." -ForegroundColor Red
    }
}

# Final message
Write-Host "Operation completed successfully!" -ForegroundColor Green
