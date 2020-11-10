#--------------------------------------------------------------------------------------------------
#                                                                                                 #
#           Author: S Abraham   Created: 6th December 2018                                        #
#           Description: Script to pull details from a list of servers                            #
#           Version: Initial release 01 Name: reportWMIaudit01 Date: 06/12/2018                   #
#                                                                                                 #
#--------------------------------------------------------------------------------------------------

#dynamic variables 
    $servers= ('WLIDDCCF001','WLIDDCCF002','WLISDHCP001','WLISCARO001','WLISCAEN001','WLISMSSQ001','WLISCMPR001','WLISSEPM001','WLISCVCS001','WLISACON001','WLISLOAP001','WLISLOAP002')
    $path="c:\Scripts\JS\01\"
    $daysSystemLog=10
    $daysApplicationLog=1

#blank variables
    $os=""
    $network=""
    $localuser=""

#static content - DO NO ALTER -------------------
#define search dates
    $datePreviousA = (date).AddDays(-$daysApplicationLog)
    $datePreviousS = (date).AddDays(-$daysSystemLog)
#Define Table
    $tab = "<style>"
    $tab = $tab + "TABLE{border-width: 1px;border-style: solid;border-color:black;}"
    $tab = $tab + "Table{background-color:#d1e0e0;border-collapse: collapse;}"
    $tab = $tab + "TH{border-width:1px;padding:5px;border-style:solid;border-color:black;background-color:#537979}"
    $tab = $tab + "TD{border-width:1px;padding-left:10px;padding-right:10px;border-style:solid;border-color:black;}"
    $tab = $tab + "</style>"
    $tab += "<BR>"
#enumerate servers
    Foreach($server in $Servers){

        #Applications installed
        $applications = Get-WmiObject -Class Win32_Product -ComputerName $server| Sort-Object Name | Select Name,version,Vendor | ConvertTo-HTML -Fragment        
        #disks
        $disks = Get-WmiObject -class Win32_LogicalDisk -ComputerName $server -Filter "DriveType=3" |select Name, FileSystem,FreeSpace,FreePercent,Size,Description,Compressed,VolumeName,VolumeDirty,VolumeSerialNumber,BlockSize | % {$_.FreePercent=(($_.FreeSpace)/($_.Size))*100;$_.FreeSpace=($_.FreeSpace/1GB);$_.Size=($_.Size/1GB);$_} | ConvertTo-HTML -Fragment 

        #$disks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" -ComputerName $server | Select DeviceID,Caption,Description,Compressed,FileSystem,VolumeName,VolumeDirty,VolumeSerialNumber | ConvertTo-HTML -Fragment 

        #OS information
        $os =Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server | Select BuildNumber,Version,Caption,Manufacturer,OSArchitecture | ConvertTo-HTML -Fragment 
        
        #memory
        $memorySource = Get-WMIObject -class Win32_PhysicalMemory -ComputerName $server 
        $mobj = New-Object PSObject
        $mobj | add-member NoteProperty "Manufacturer" ($memorySource | Select-Object -ExpandProperty Manufacturer)
        $mobj | add-member NoteProperty "Capacity" (($memorySource | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)}))
        $memory = $mobj  | ConvertTo-HTML -Fragment 

        #network data
        $networkSource = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE  -ComputerName $server 
        #build table to remove array values
        $nobj = New-Object PSObject
        $nobj | add-member NoteProperty "IPAddress" (($networkSource | Select-Object -ExpandProperty IPAddress) -join ', ')
        $nobj | add-member NoteProperty "DHCPEnabled" ($networkSource | Select-Object -ExpandProperty DHCPEnabled)
        $nobj | add-member NoteProperty "DefaultIPGateway" (($networkSource | Select-Object -ExpandProperty DefaultIPGateway) -join ', ')
        $nobj | add-member NoteProperty "Description" ($networkSource | Select-Object -ExpandProperty Description) 
        $network = $nobj  | ConvertTo-HTML -Fragment 
   
        #logs
        $systemLog = Get-EventLog -LogName System -EntryType Error -After $datePreviousS -ComputerName $server | Select Timegenerated,EventID,Source,Message | ConvertTo-HTML -Fragment 
        $applicationLog = Get-EventLog -LogName Application -EntryType Error -After $datePreviousA -ComputerName $server | Select Timegenerated,EventID,Category,Source,Message | ConvertTo-HTML -Fragment 
        
        #local user accounts
        $localUser = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" -ComputerName $server | Select Name,Description,Status,PasswordExpires,Disabled,PasswordChangeable,PasswordRequired | ConvertTo-HTML -Fragment 

        #buid the report body
        $body = "<h1>Detailed report for server $server</h1><h2>Operating System</h2>$os<br><h2>Network</h2>$network<br><h2>Memory</h2>$memory<h2>Disks</h2>$disks <br><h2>Local Users</h2>$localUser<h2>Installed Applications</h2>$applications <h2>Logs</h2><h3>System</h3>$systemLog<br><h3>Application</h3>$applicationLog"

        #convert per server
        ConvertTo-HTML -head $tab -Body $body -Title "<h1>Inventory for $server</h1>" | out-file $path$server.htm 
    }

    