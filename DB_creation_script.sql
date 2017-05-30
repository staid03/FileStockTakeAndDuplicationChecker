--Create database for File Stocktake
--Create database if not exists 'File_Stocktake';
-- USE 'File_Stocktake';
--
-- Version	Date		Author 			Notes
--	0.1		14-MAR-2017	Staid03			Initial
--	0.2		20-MAR-2017	Staid03			Adding md5Checksum field
--  0.3		09-APR-2017	Staid03			Adding field to flag a file OK




DROP TABLE IF EXISTS 'Files';

CREATE TABLE IF NOT EXISTS 'Files' (
	-- 'ID' int(8) NOT NULL,
	'ScriptTimeStamp' int(8) DEFAULT NULL,
	'DriveName' varchar(20) DEFAULT NULL,
	'FileLocation' varchar(100) DEFAULT NULL,
	'FileLocationCleanRequired' int(1) DEFAULT NULL,
	'FileName' varchar(100) DEFAULT NULL,
	'FileNameCleanRequired' int(1) DEFAULT NULL,
	'FileExt' varchar(10) DEFAULT NULL,
	'FileExtCleanRequired' int(1) DEFAULT NULL,
	'FileSizeBytes' int(8) DEFAULT NULL,
	'FlaggedOK' int(1) DEFAULT NULL
);