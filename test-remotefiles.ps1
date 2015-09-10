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
#$ADList = Get-ADComputer -Filter {(cn -eq "js-virt-7")} | %{$_.name}

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

foreach($comp in $ADList) {
	if(Test-Connection -ComputerName $comp -Count 1 -Quiet){
		foreach ($file in $files){
			if(Test-Path ($file | ConvertLocalToRemote -ComputerName $comp)){
				write-warning "$file exists on $comp"
				"$file exists on $comp" | out-file -Append foundFiles.txt
			} else {
				write-host "$file does not exist on $comp"
				"$file does not exists on $comp" | out-file -Append notfound.txt
			}
		}
	}
}

Pop-Location