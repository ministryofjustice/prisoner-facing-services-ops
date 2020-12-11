### values obtained from the vault

.\Kiosk-Code-Config-Initial.ps1 `
-codebase 'urlforstage' `
-IntUrl 'URL' ` #Some internal url
-IntUserEnc 'value' ` # some user
-IntUserPwdEnc 'some password' ` # some password
-CMSSQLInstance 'some value' `
-CMSSQLDatabaseEnc 'some value' `
-CMSSQLPasswordEnc 'some value' `
-CMSSITE '' `
-Prison 'WLI'



.\Kiosk-WebService_PFS_1.0.ps1 `
-KioskIISUser 'KioskIIS' `
-KioskIISUserPassword 'SecureP@ssw0rd' `
-CMSSITE 'WLI' ` # or BWI
-WebAppPoolName 'WLI_CMS' `
-Prison 'WLI' 

