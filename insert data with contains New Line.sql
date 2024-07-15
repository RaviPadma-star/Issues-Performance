update boxcode
set AdditionalInfo='1   Nespresso Cup       EC1207
1   Nespresso Saucers   EC1206
6   Mug F/c             EC1201
13  Medium Plate F/c    EC1209
1   Full Ace Tmat Blu   EB1588
8   Cup F/c             EC1200
8   Saucer F/c          EC1202
1   Mug F/c             EC1201\'
where code='FC1' and ID=2856

select * from dba.dbo.BoxcodeHeaders_21Feb2017
where code='FC1' 

select a.AdditionalInfo,b.AdditionalInfo from boxcode A
join dba.dbo.BoxcodeHeaders_21Feb2017 B on a.code=b.code
where a.code='FC1' 

select a.AdditionalInfo,b.AdditionalInfo from boxcode A
join dba.dbo.BoxcodeHeaders_21Feb2017 B on a.code=b.code
where a.code='FC1' 

Update A set a.AdditionalInfo=REPLACE(b.AdditionalInfo,'\n','
') from boxcode A
join dba.dbo.BoxcodeHeaders_21Feb2017 B on a.code=b.code
where a.unitid In (101)


PRINT REPLACE('Line 2`Line 3','`','
')

PRINT REPLACE('Line 2\nLine 3','\n','
')

select REPLACE(AdditionalInfo,'\n','
') from  dba.dbo.BoxcodeHeaders_21Feb2017
where code='FC1' 