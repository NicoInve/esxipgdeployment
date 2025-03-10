# VMware ESXi Port Group Deployment Script (PowerShell)

## 📌 Overview
This PowerShell script automates the creation of **Port Groups** on multiple **VMware ESXi hosts**. 
It takes two CSV files as input:
- **`hosts.csv`** → Contains the list of ESXi hosts where Port Groups will be created.
- **`portgroups.csv`** → Contains the Port Groups to be created, along with their VLAN ID and associated vSwitch.

The script uses **PowerCLI** to connect to ESXi hosts and create the specified Port Groups.

---

## 🚀 Prerequisites
Before running the script, ensure you have the following:
1. **PowerShell 5.1 or later** installed on your system.
2. **VMware PowerCLI** module installed. If not, install it using:
   ```powershell
   Install-Module VMware.PowerCLI -Scope CurrentUser -Force
   ```
3. **Administrator privileges** on the ESXi hosts to create Port Groups.
4. **Place `hosts.csv` and `portgroups.csv` in the same directory as the script.**

---

## 📂 CSV File Format
The script requires two CSV files:

### `hosts.csv` (List of ESXi Hosts)
```csv
ESXiHost
esxi01.domain.local
esxi02.domain.local
esxi03.domain.local
```

### `portgroups.csv` (Port Groups Configuration)
```csv
VSwitch,PortGroup,VLAN
vSwitch0,PG-Production,10
vSwitch0,PG-Backup,20
vSwitch1,PG-Management,30
vSwitch1,PG-NoVLAN,
```
💡 If the **VLAN** column is empty, the script will assign VLAN `0` (untagged network).

---

## 📜 How to Use
1. **Place the script and CSV files** in the same directory.
2. **Open PowerShell as Administrator**.
3. **Navigate to the script folder**:
   ```powershell
   cd "C:\Path\To\Script"
   ```
4. **Run the script**:
   ```powershell
   .\portgroup_deploy.ps1
   ```
5. **Enter credentials** when prompted (ESXi administrator account).

---

## 🛠️ Script Functionality
- Connects to each **ESXi host** listed in `hosts.csv`.
- Reads the **Port Groups** from `portgroups.csv`.
- **Checks if the Port Group already exists** to avoid duplicates.
- Creates the Port Groups with the specified **VLAN ID** and **vSwitch**.
- **Handles empty VLAN fields** by setting VLAN `0` (untagged network).
- **Outputs success messages in green** when a Port Group is created successfully.
- **Disconnects** from each host after configuration.

---

## ⚠️ Error Handling
| Issue | Solution |
|--------|----------|
| Missing CSV files | Ensure `hosts.csv` and `portgroups.csv` exist in the script directory. |
| Connection failed to ESXi | Check if the ESXi host is reachable and credentials are correct. |
| Port Group already exists | The script will **skip** existing Port Groups to avoid conflicts. |
| VLAN conversion error | Ensure VLAN IDs in `portgroups.csv` are numbers or left empty for VLAN `0`. |

---

## 📢 Notes
- The script **requires PowerCLI** to be installed before running.
- It is recommended to **test on a single ESXi host** before deploying on multiple hosts.
- If running on **Windows Server**, ensure **PowerShell Execution Policy** allows scripts:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope Process -Force
  ```

---

## 📄 License
This script is provided "as-is" without warranty. Use at your own risk.

