--Query for extracting duplicate files from the database
--
-- Version	Date		Author 			Notes
--	0.1		09-APR-2017	Staid03			Initial
--

select a.FileName, b.FileName, a.FileSizeBytes , a.FileSizeBytes, a.MD5Checksum, a.FileLocation, b.FileLocation
from Files a, Files b
where
a.MD5Checksum = b.MD5Checksum and
a.FileName <> b.FileName and
a.MD5Checksum <> ""