#Test-RemoteFilesPS

##Usage

This is a pretty simple script. Put the paths to the files you are looking for in your environment in FileList.txt. Open a powershell command prompt as an administrator and run 'test-remotefiles.ps1 -FileList FileList.txt'. I created this script as a quick way to find out if a virus trace or malicious file is sitting out there.

##Output

PS Object is output to the console. Convert it to CSV, HTML or whatever else you would like to do with it.

##How it works

The script will scan your AD environment for computers that are enabled, make sure that it can connect to them and check for the existence of files in the list. 