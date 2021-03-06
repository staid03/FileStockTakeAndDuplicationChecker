﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

;Script for creating a CSV containing all file details from a specified location

;Version	Date		Author		Notes
;	0.1		14-MAR-2017	Staid03		Initial
;	0.2		15-MAR-2017	Staid03		Updating for C drive. Fixed an issue with Y flags not cleaning up the FileLocation.
;	0.3		19-MAR-2017	Staid03		Added MD5checksum retrieval and addition to JSON file
;	0.4		19-MAR-2017	Staid03		Fixing output so it allows talking marks in the JSON file (searching for escape chars for JSON) " '
;									Escape char = \  eg. \"		\'
;	0.5		08-APR-2017	Staid03		Updated mechanism for md5checksum retrieval to use powershell and not fciv.exe. Note that md5checksum
;									retrieval is purely for determining file duplication and not for file security.
;	0.6		09-APR-2017	Staid03		Updated script for logging details of start/stop times, number of files, and cleaned variables
;	0.7		09-APR-2017	Staid03		If file is over specified size limit, then do not retrieve MD5checksum

formattime , atime ,, yyyyMMdd_HHmmss

infolder = d:\
givenNameForTheDrive = laptop_d
outputFile = FileStockTake_%givenNameForTheDrive%_%atime%.json
jsonProgram = "C:\Program Files (x86)\Notepad++\notepad++.exe"
checksumoutfile = ~checksumoutfile.xml
MD5checksumExclusionSizeBytes = 500000000		;500mb
exclusionExt = xls|doc|png		;just examples
exclusionExtArray := StrSplit(exclusionExt, "|")
;exclusionDir = $RECYCLE.BIN|system|System32|Program Files|DIAD|eSupport|Logs|NVIDIA|PerfLogs|Users|Windows|Boot|ProgramData
exclusionDir = $RECYCLE.BIN|$AVG
exclusionDirArray := StrSplit(exclusionDir, "|")
cleanedVarsFNNum = 0
cleanedVarsDRNum = 0
cleanedVarsEXNum = 0
scriptRunLog = Script_Run_Details.log

testlimit = null		;update this to a number if you only want to test to
						;a certain number of files
anum = 1

main:
;declare a main body
{
	FormatTime , nTimeStamp , , yyyyMMddHHmm
	starttime = %nTimeStamp%
	;begin looping through each file from the specified source folder
	oDirCheck = 
	GoSub , beginJSONFile					;create the JSON file and the first few lines
	Loop , %infolder%*.* , 0 , 1
	{
		;search through the specified folder for files to collect metadata on		
		GoSub , resetVars					;reset the variables
		SplitPath , a_loopfilefullpath , oFileName , oDir , oExt , oNameNoExt , oDrive
		GoSub , excludedFileCheck			;check if this file/folder has been excluded from being recorded
		IfEqual , excluded , y				;if it has been returned to exclude this file/folder, then move onto the next file
		{
			Continue
		}
		ifnotequal , oDirCheck , %oDir%
		{
			oDirCheck = %oDir%
			DRVarClean = N
			if oDir is not space 
			{
				varToClean = DRClean_%oDir%
				gosub , cleanVar		
				oDir = %cleanVarOut%
			}
			ifgreater , anum , 1
			{
				gosub , fileLocationJSON
			}
			else 
			{
				gosub , newfileLocationJSON
			}
		}
		FileGetSize , oSize , %a_loopfilefullpath% , 
		FileGetTime , oModifiedTimeRaw , %a_loopfilefullpath% , M
		FileGetTime , oCreatedTimeRaw , %a_loopfilefullpath% , C
		{
			FNVarClean = N
			if oFileName is not space
			{
				varToClean = FNClean_%oFileName%
				gosub , cleanVar		
				oFileName = %cleanVarOut%
			}
			
			EXVarClean = N
			if oExt is not space
			{
				varToClean = EXClean_%oExt%
				gosub , cleanVar
				oExt = %cleanVarOut%
			}		
		}	
		
		;getting the script to ignore MD5checksums that are over a specified size limit
		ifless , oSize , %MD5checksumExclusionSizeBytes%
		{
			gosub , generateMD5Checksum	
		}
		else
		{
			MD5checksum = too_large
		}
		
		gosub , createJSON
		ifequal , anum , %testlimit%				;break the loop upon reaching testlimit variable loop times
		{
			break
		}
		anum++
	}
	gosub , endJSONFile
	gosub , outputLogDetails
	run , %jsonProgram% %outputFile%
	msgbox ,,, script %a_scriptname% completed - %anum% number of rows
}
Return

resetVars:
;reset the variables for the next iteration of the loop
{
	oFileName = 
	oDir = 
	oExt = 
	oSize = 
	oModifiedTimeRaw = 
	oCreatedTimeRaw = 
	excluded = n
}
Return

excludedFileCheck:
;check for any excluded file types
{
	Loop % exclusionDirArray.MaxIndex()
	{
		exclusionDir := exclusionDirArray[a_index]
		ifinstring , oDir , %exclusionDir%
		{
			excluded = y
			break
		}
	}	
}
Return 

cleanVar:
;runs through the vars that could have talking marks in them to remove the talking marks for JSON file
;creates a record of which variable was required to be cleaned
{
	cleanVarOut = 
	ifinstring , varToClean , "		;"
	{
		stringreplace , cleanVarOut , varToClean , " , \" , A
		stringleft , cleanedVarType , varToClean , 2
		ifequal , cleanedVarType , FN
		{
			FNVarClean = Y
			cleanedVarsFNNum++
		}
		ifequal , cleanedVarType , DR
		{
			DRVarClean = Y
			cleanedVarsDRNum++
		}
		ifequal , cleanedVarType , EX
		{
			EXVarClean = Y
			cleanedVarsEXNum++
		}
	}	
	stringtrimleft , cleanVarOut , varToClean , 8
}
Return 

generateMD5Checksum:
{
	filedelete , %checksumoutfile%
	MD5checksum = 		;reset in case it fails
	md5line = 			;reset in case it fails
	runwait , powershell.exe Get-FileHash '%a_loopfilefullpath%' -Algorithm MD5 | Format-List > %checksumoutfile% , , min
	sleep , 300
	filereadline , md5line , %checksumoutfile% , 4
	stringtrimleft , MD5checksum , md5line , 12
}
Return

beginJSONFile:
{
	outputline = {`n
	outputline = %outputline%	"ScriptTimeStamp": "%nTimeStamp%"`n
	outputline = %outputline%	"DriveName": "%givenNameForTheDrive%"`n
	outputline = %outputline%	"FileLocationDetails": `n	{
	
	fileappend , %outputline% , %outputFile%
}
Return 

fileLocationJSON:
{
	outputline = `n
	outputline = %outputline%	}`n
	outputline = %outputline%	"FileLocationDetails": `n	{
	
	fileappend , %outputline% , %outputFile%
}

newfileLocationJSON:
{
	outputline = `n
	outputline = %outputline%		"FileLocation": "%oDir%"`n
	outputline = %outputline%		"FileLocationCleanRequired": "%DRVarClean%"
	
	fileappend , %outputline% , %outputFile%
}
Return

createJSON:
;create the JSON file
{
	outputline = `n
	outputline = %outputline%		"FileDetails": `n		{`n
	outputline = %outputline%			"FileName": "%oFileName%"`n
	outputline = %outputline%			"FileNameCleanRequired": "%FNVarClean%"`n
	outputline = %outputline%			"FileExt": "%oExt%"`n
	outputline = %outputline%			"FileExtCleanRequired": "%EXVarClean%"`n
	outputline = %outputline%			"FileSizeBytes": "%oSize%"`n
	outputline = %outputline%			"MD5checksum": "%MD5checksum%"`n
	outputline = %outputline%			"FileTimeModified": "%oModifiedTimeRaw%"`n
	outputline = %outputline%			"FileTimeCreated": "%oCreatedTimeRaw%"`n
	outputline = %outputline%		}
	
	fileappend , %outputline% , %outputFile%
}
Return 

endJSONFile:
{
	outputline = 
	outputline = `n	}`n}
	
	fileappend , %outputline% , %outputFile%
}
Return 

outputLogDetails:
{
	FormatTime , endtime , , yyyyMMddHHmm
	thisScriptRunLogDetails = %starttime%,%endtime%,%anum%,%cleanedVarsFNNum%,%cleanedVarsDRNum%,%cleanedVarsEXNum%
	fileappend , %thisScriptRunLogDetails%`n, %scriptRunLog%
}
Return 