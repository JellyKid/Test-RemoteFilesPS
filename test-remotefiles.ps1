param
(
	[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
	[string]$FileList
)

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    exit
}

Push-Location $PsScriptRoot

$files = Get-Content $FileList
$ADList = Get-ADComputer -Filter {Enabled -eq $true} | %{$_.name} #Automatically populate list of computers with enabled AD machines

#Helper function to convert local c:\somedir\some.file path to remote \\computer.local\c$\somedir\some.file path
function ConvertLocalToRemote{ 
	param
	(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string]$file,
		[Parameter(Mandatory=$True,ValueFromPipeline=$False)]
		[string]$ComputerName
	)
	
	process
	{
		$file = ($file -split ':') -join '$'
		return "\\$ComputerName\$file"
	}
}



#Cleanup found/not found lists
if(Test-Path foundFiles.txt){
	Remove-Item .\foundFiles.txt
}

if(Test-Path notfound.txt){
	Remove-Item .\notfound.txt
}

$CompObj = @{
	'Computer'			= '';
	'Files Found'	= @();
	'Errors'			= '';
}

$CompList = @()

foreach($comp in $ADList) {
	$NewComp = New-Object -TypeName PSObject -Property $CompObj
	$NewComp.Computer = $comp
	
	if(Test-Connection -ComputerName $comp -Count 1 -Quiet){
		foreach ($file in $files){
			if(Test-Path ($file | ConvertLocalToRemote -ComputerName $comp)){
				$NewComp.'Files Found' += $file
			} 
		}
		
	} else {
		$NewComp.Errors = 'Cannot ping machine'
	}
	
	$NewComp.'Files Found' = $NewComp.'Files Found' -join "`n"
			
	$CompList += $NewComp
}

return $CompList | select computer,'Files Found',Errors | sort computer

Pop-Location