param([Parameter(Mandatory=$true)][string] $InputFileName,
[ValidateSet("archive","unarchive","delete")][string]$Action = "archive")

. .\CopyTCProjects_Functions.ps1

$DebugPreference = "Continue"

# Checking if file exists
if (!(Test-Path $InputFileName))
{
	Write-Error "File ""$InputFileName"" not found!";
	return;
}

Write-Output "Input file: ""$InputFileName""";

Write-Output "Please provide username and password to connect to teamcity"
$Credential = Get-Credential

$XmlDocument = [xml] (Get-Content -Path $InputFileName);

$ProjectNodes = Select-Xml -Xml $XmlDocument -XPath "/CopyTCProjectsScenario/Projects/Project";
if ($ProjectNodes -eq $Null)
{
	Write-Error "No projects found in ""$InputFileName"" - please check the file format";
	return;
}
Write-Output "Found $($ProjectNodes.Count) project(s) in the input file";

foreach ($ProjectName in $ProjectNodes)
{
	Write-Output "`r`n=====================================================";
	Write-Output "Processing project ""$($ProjectName)...""";
	$ProjectId = FindTCProjectIdByName -ProjectName $ProjectName;
	if ($ProjectId -eq "unknown")
	{
		Write-Error "Cannot lookup Id for the project ""$SourceProjectName""";
	}
	else
	{
		write-output "Project ID found"
		Switch($Action)
		{
			"archive" {ArchiveProject -ProjectId $ProjectId -ParamValue "true";}
			"unarchive" {ArchiveProject -ProjectId $ProjectId -ParamValue "false";}
			"delete" {DeleteProject -ProjectId $ProjectId;}
		}	
	}
}

Write-Output "Script finished";
