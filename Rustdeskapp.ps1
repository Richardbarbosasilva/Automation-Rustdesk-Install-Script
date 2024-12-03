
############################## Defines network folder, local folder and executable paths ##########################

Unblock-File "path-to-unc-rustdesk-executable"

$rustdeskNetwork = "unc-path-to-rustdesk-folder"

$destinationRustdesk = "C:\"

$rustdeskExecutable = "C:\Rustdesk\rustdesk.exe"

$rustdesknetworkexecutable = "unc-path-to-rustdesk-executable"


######################################### Get current user #################################################


$currentUser = $env:USERNAME

Write-Output "Current user: $currentUser"


########################### Step 1: Verify if the network RustDesk folder exists and copy files #########################


if (Test-Path -Path $rustdeskNetwork -PathType Container) {

    # Copy all files and folders from the network RustDesk folder to the destination

    Copy-Item -Path $rustdeskNetwork -Destination $destinationRustdesk -Recurse -Force -WarningAction SilentlyContinue

    Write-Output "Files copied successfully to $destinationRustdesk"

} else {

    Write-Output "The RustDesk network folder does not exist at $rustdeskNetwork"

    Exit
}


################################# Step 2: Create symbolic link on Desktop ####################################################


Write-Host "Creating symbolic link (shortcut) on user's desktop from local installation folder"

Start-Sleep 2
 
$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Rustdesk.lnk")

$shell = New-Object -ComObject WScript.Shell

$shortcut = $shell.CreateShortcut($shortcutPath)

$shortcut.TargetPath = $rustdesknetworkExecutable

$shortcut.Save()

Write-Host "Shortcut created on $shortcutPath"


############################### Step 3: Unblock the RustDesk executable file ############################################


Unblock-File -Path $rustdeskExecutable

Write-Output "Unblocked RustDesk executable."


############################ Step 4: Verify and create RustDesk service ###########################################


Write-Host "Verifying if there is any RustDesk service..."


# Verify if the service exists

$service = Get-Service -Name "Rustdesk" -ErrorAction SilentlyContinue


if ($null -eq $service) {

    Write-Host "There is no Rustdesk service on this computer. Trying to create it."

    # Define the command to create the service

    $serviceCreateCommand = {

        New-Service -Name 'Rustdesk' -DisplayName 'Rustdesk' -Description 'Rustdesk remote access app running as a background Windows service' -StartupType Automatic -BinaryPathName "C:\Rustdesk\rustdesk.exe --service"
        
        Write-Host "Rustdesk service created!"
    }

    # Run the service creation command with elevated credentials

    $Domain = "your-domain"  # Replace with your actual domain name

    $User = "$Domain\admin-username"  # Domain and username (needs to have local admin to create windows service)

    $Password = "admin-password"  # Replace with the actual password

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    $Credential = New-Object System.Management.Automation.PSCredential($User, $SecurePassword)

    # Start PowerShell as a new process with the elevated credentials

    Start-Process powershell.exe -Credential $Credential -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-Command & { $($serviceCreateCommand.Invoke()) }" -Wait

} else {

    Write-Host "Rustdesk service already exists."
}



############################# Step 5: Verify that both instances are running #############################################


# Defining logic to troubleshoot the rustdesk service and verify if it's running

$iterations = 2

for ($i = 1; $i -le $iterations; $i++) {

    if ($service -and $service.Status -eq 'Running') {

        Write-Host "RustDesk service is running. Ending troubleshoot"

        break  # Exit the loop if service is running

    } else {

        Write-Host "RustDesk service failed to start or is not running (dormant). Trying to start it on (services.msc)"

        Start-Service -Name "Rustdesk" | Start-Service -ErrorAction SilentlyContinue

        Write-Host "Rustdesk service may be running now. Double check will be done."
    }

    Start-Sleep -Seconds 1  # Wait a few seconds before retrying
}




########################################## Stop the current script process ###############################################


stop-process -id $PID 



