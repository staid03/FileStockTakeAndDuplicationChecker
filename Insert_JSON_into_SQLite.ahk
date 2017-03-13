﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

;Script for converting JSON file into SQL insert file

;Version	Date		Author		Notes
;	0.1		14-MAR-2017	Staid03		Initial

formattime , atime ,, yyyyMMdd_HHmmss

; {
	; "ScriptTimeStamp": "201703140253"
	; "DriveName": "laptop_d"
	; "FileLocationDetails": 
	; {
		; "FileLocation": "d:"
		; "FileLocationCleanRequired": "N"
		; "FileDetails": 
		; {
			; "FileName": "avira_vpn_option.png"
			; "FileNameCleanRequired": "N"
			; "FileExt": "png"
			; "FileExtCleanRequired": "N"
			; "FileSizeBytes": "25112"
			; "FileTimeModified": "20160426131303"
			; "FileTimeCreated": "20160426131303"
		; }
		; "FileDetails": 
		; {
			; "FileName": "Contacts.vcf"
			; "FileNameCleanRequired": "N"
			; "FileExt": "vcf"
			; "FileExtCleanRequired": "N"
			; "FileSizeBytes": "300332"
			; "FileTimeModified": "20170302065002"
			; "FileTimeCreated": "20170303215150"
		; }



JSONfile = FileStockTake_laptop_d_20170314_041817.json
SQLinsertfile = SQLinsertfile_%atime%.sql
SQLProgram = "C:\Program Files (x86)\Notepad++\notepad++.exe"


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
			;msgbox ,,, timestamp is %ScriptTimeStamp%
			ScriptTimeStamp = %thisVar%
		}
		
		ifequal , thisVarType , DriveName
		{
			DriveName = %thisVar%
		}
		
		ifequal , thisVarType , FileLocation
		{
			FileLocation = %thisVar%
		}
		
		ifequal , thisVarType , FileLocationCleanRequired
		{
			FileLocationCleanRequired = %thisVar%
		}
		
		ifequal , thisVarType , FileName
		{
			FileName = %thisVar%
		}
		
		ifequal , thisVarType , FileNameCleanRequired
		{
			FileNameCleanRequired = %thisVar%
		}
		
		ifequal , thisVarType , FileExt
		{
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
		
		ifequal , thisVarType , FileTimeModified
		{
			FileTimeModified = %thisVar%
		}

		ifequal , thisVarType , FileTimeCreated
		{
			FileTimeCreated = %thisVar%
		}
	}
}
return

; CREATE TABLE IF NOT EXISTS 'Files' (
	; 'ScriptTimeStamp' int(8) DEFAULT NULL,
	; 'DriveName' varchar(20) DEFAULT NULL,
	; 'FileLocation' varchar(100) DEFAULT NULL,
	; 'FileLocationCleanRequired' int(1) DEFAULT NULL,
	; 'FileName' varchar(100) DEFAULT NULL,
	; 'FileNameCleanRequired' int(1) DEFAULT NULL,
	; 'FileExt' varchar(10) DEFAULT NULL,
	; 'FileExtCleanRequired' int(1) DEFAULT NULL,
	; 'FileSizeBytes' int(8) DEFAULT NULL,
	; 'FileTimeModified' int(8) DEFAULT NULL,
	; 'FileTimeCreated' int(8) DEFAULT NULL	
; );

writeSQL:
{
	outSQLvalues = '%ScriptTimeStamp%','%DriveName%','%FileLocation%','%FileLocationCleanRequired%','%FileName%','%FileNameCleanRequired%'
	outSQLvalues = %outSQLvalues%,'%FileExt%','%FileExtCleanRequired%','%FileSizeBytes%','%FileTimeModified%','%FileTimeCreated%'
	outSQLline = INSERT into 'Files' ('ScriptTimeStamp','DriveName','FileLocation','FileLocationCleanRequired','FileName','FileNameCleanRequired'
	outSQLline = %outSQLline%,'FileExt','FileExtCleanRequired','FileSizeBytes','FileTimeModified','FileTimeCreated') Values(%outSQLvalues%)
	fileappend , %outSQLline%`;`n , %SQLinsertfile%
}
return 