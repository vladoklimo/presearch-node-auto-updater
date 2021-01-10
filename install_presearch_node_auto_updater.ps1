### Author: Vladimir Klimo
### 
### This is installation script to inicialize Windows Scheduled Task for node updater
### 
### Please be aware that I do not take any responsibility for your actions with this script.
### Use at your own risk. No guarantees.
###

###
### Few configuration things before you execute anythng
###
param (
	[switch]$Force = $false
)

# name of the folder on C:\ driver, where script download the node updater script
$folderName = "presearch_node_updater"

###
### Configuration done
###

### After this line, edit at your own risk



$installFolder = "C:\" + $folderName
$installFile = $installFolder + "\" + "preserach_node_check.ps1"

$githubURL = "https://raw.githubusercontent.com/vladoklimo/presearch-node-auto-updater/main/presearch_node_check.ps1"

function checkFile {
	[CmdletBinding()]
	param ([Parameter(Mandatory)] $file)
	
	return Test-Path $file -PathType leaf
}

function checkFolder {
	[CmdletBinding()]
	param ([Parameter(Mandatory)] $folder)
	
	return Test-Path $folder
}

function install_presearch_node_updater {
	[CmdletBinding()]
	param ([switch]$Force = $false)

	if ( (checkFolder -folder $installFolder) -and -not($Force) ) {
		#do some stuff
		Write-Host "Already installed ?? Nothing to do (maybe not)"
	}
	else {
		Write-Host "Not installed ... so starting up"
		
		if (checkFolder -folder $installFolder) {
			Write-Host "$installFolder already exists ... skipping create folder routine"
		}
		else {
			Write-Host "Creating folder $installFolder"
			New-Item -Path "C:\" -Name $folderName -ItemType "directory" | out-null
		}
		
		Write-Host 'Starting downloading the GitHub Repository'
		Invoke-RestMethod -Uri $githubURL -OutFile $installFile
		Write-Host 'Download finished'
		
		$presearch_node_registration_code = read-host "Please provide your presearch node registration code"
		
		Write-Host "Configuring updater - adding your registration code"
		((Get-Content -path $installFile -Raw) -replace '<PUT-YOUR-PRESEARCH-CODE-HERE>',$presearch_node_registration_code) | Set-Content -Path $installFile
		
		$job_action = New-ScheduledTaskAction -Execute $installFile -WorkingDirectory "$installFolder"
		
		if ($job_action -eq $null) {
			Write-Host "Cannot inicialize task action parameter"
			return
		}
		
		$job_trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RandomDelay (New-TimeSpan -Minutes 10) -RepetitionInterval (New-TimeSpan -Minutes 10)
		
		if ($job_trigger -eq $null) {
			Write-Host "Cannot inicialize task trigger parameter"
			return
		}
		
		$job_settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
		
		if ($job_settings -eq $null) {
			Write-Host "Cannot inicialize task settings parameter"
			return
		}
		
		$existingTask = Get-ScheduledTask -TaskName "Presearch Node Auto-Updater"
		if ($existingTask -ne $null) {
			Write-Host "Removing previous scheduled task: Presearch Node Auto-Updater"
			Unregister-ScheduledTask -InputObject $existingTask	-Confirm:$false
		}
		
		$task = New-ScheduledTask -Action $job_action -Trigger $job_trigger -Settings $job_settings
		if ($task -eq $null) {
			Write-Host "Cannot inicialize task for registration" 
		}
		
		$registration = Register-ScheduledTask -TaskName "Presearch Node Auto-Updater" -InputObject $task
		if ($registration -eq $null) {
			Write-Host "Cannot register Scheduled task - Presearch Node Auto-Updater" 
			return
		}
		else {
			Write-Host "Created recurring task to check presearch node for an updates. Scheduled Task Name: Presearch Node Auto-Updater"
		}
		
	}
}

install_presearch_node_updater -Force:$Force