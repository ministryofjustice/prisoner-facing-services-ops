
<# 
#************************************************************************
#*
#* COMMAND FILE
#*  disks.PS1
#*
#* SYNOPSIS
#*  Finds disks, formats them. 
#*
#* ARGUMENTS
#*  NONE
#*
#* PLATFORM
#*  Common Build Framework
#*
#* AUTHOR
#*  Rich Dakin - RADITC 04-05-2020
#*
#* VERSION CONTROL
#*  1.0   :: 04-05-2020 :: Creation. 
#*
#************************************************************************
#> 


#Simply finds the expected disks and calls them IIS. If more disks are finds throws an error as this will need to be modified.

if ($rawdisk) {

$rawdisk = Get-Disk | Where partitionstyle -eq "raw"
If (($rawdisk.disknumber) -gt 2) {
    
    Throw "More disks than expected"

}  

Else { 

    $disklabel = "IIS"
    Initialize-Disk -PartitionStyle MBR -PassThru -Number $rawdisk.DiskNumber | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "$disklabel" -Confirm:$true
    Write-Host $disklabel
}

}

Else { Write-Output "Do Nothing" } 