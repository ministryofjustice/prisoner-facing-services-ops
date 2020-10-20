

try 
{
    # Install Package
    
     Add-ProvisioningPackage -Path ".\PFS Provisioning.ppkg" -QuietInstall -ForceInstall

    [System.Environment]::Exit(0)
}
catch
{
    [System.Environment]::Exit(1)
}


