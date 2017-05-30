#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

;Script for converting JSON file into SQL insert file

;Version	Date		Author		Notes
;	0.1		14-MAR-2017	Staid03		Initial
;	0.2		20-MAR-2017	Staid03		Updated for MD5Checksum plus modified JSONfile 
;									to be a selected file rather than entering the
;									filename in every time
;	0.3		09-APR-2017 Staid03		Added computer name and user name to SQL output
;									file for tracking purposes.
;	0.4		30-MAY-2017	Staid03		Removing MD5 functionality for speed purposes
;

main:
{
	;variables - declare and get (in case of retrieving filename)
	formattime , atime ,, yyyyMMdd_HHmmss
	EnvGet , computerName , COMPUTERNAME
	EnvGet , userName , USERNAME
	SQLinsertfile = SQLinsertfile_%computerName%__%userName%_%atime%.sql
	SQLProgram = "C:\Program Files (x86)\Notepad++\notepad++.exe"

	FileSelectFile , JSONfile , , %A_ScriptDir% ,, *.json
	if errorlevel
	{
	 msgbox ,,, no file was chosen
	 exit
	}

	loop , read , %JSONfile%
	{
		gosub , processline
		ifequal , writeSQLline , y
		{
			gosub , writeSQL
			writeSQLline = n
		}
	}
	run , %SQLProgram% %SQLinsertfile%
}
return

processline:
{	
	ifinstring , a_loopreadline , ": "
	{
		stringsplit , aSplit , a_loopreadline , "					;"
		stringreplace , thisVarType , aSplit2 , %a_space% ,, A
		stringreplace , thisVarType , thisVarType , " ,, A 			;"
		stringreplace , thisVar , aSplit4 , " , , A					;"
		ifequal , thisVarType , FileTimeCreated
		{
			FileTimeCreated = %thisVar%
			writeSQLline = y
		}
		
		ifequal , thisVarType , ScriptTimeStamp
		{
			ScriptTimeStamp = %thisVar%
		}
		
		ifequal , thisVarType , DriveName
		{
			DriveName = %thisVar%
		}
		
		ifequal , thisVarType , FileLocation
		{
			gosub , cleanUpTalkingMark
			FileLocation = %thisVar%			
		}
		
		ifequal , thisVarType , FileLocationCleanRequired
		{
			FileLocationCleanRequired = %thisVar%
		}
		
		ifequal , thisVarType , FileName
		{
			gosub , cleanUpTalkingMark
			FileName = %thisVar%
		}
		
		ifequal , thisVarType , FileNameCleanRequired
		{
			FileNameCleanRequired = %thisVar%
		}
		
		ifequal , thisVarType , FileExt
		{
			gosub , cleanUpTalkingMark
			FileExt = %thisVar%
		}
		
		ifequal , thisVarType , FileExtCleanRequired
		{
			FileExtCleanRequired = %thisVar%
		}
		
		ifequal , thisVarType , FileSizeBytes
		{
			FileSizeBytes = %thisVar%
		}
	}
}
return

cleanUpTalkingMark:
{
	ifinstring , thisVar , '
	{
		StringReplace , thisVar , thisVar , ' , '' , A
	}
}
Return

writeSQL:
{
	outSQLvalues = '%ScriptTimeStamp%','%DriveName%','%FileLocation%','%FileLocationCleanRequired%','%FileName%','%FileNameCleanRequired%'
	outSQLvalues = %outSQLvalues%,'%FileExt%','%FileExtCleanRequired%','%FileSizeBytes%'
	outSQLline = INSERT into 'Files' ('ScriptTimeStamp','DriveName','FileLocation','FileLocationCleanRequired','FileName','FileNameCleanRequired'
	outSQLline = %outSQLline%,'FileExt','FileExtCleanRequired','FileSizeBytes') Values(%outSQLvalues%)
	fileappend , %outSQLline%`
}
return 