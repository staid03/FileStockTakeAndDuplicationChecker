--create database for File Stocktake
--create database if not exists 'File_Stocktake';
-- USE 'File_Stocktake';
DROP TABLE 'Files';

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
	'FileTimeModified' int(8) DEFAULT NULL,
	'FileTimeCreated' int(8) DEFAULT NULL	
);