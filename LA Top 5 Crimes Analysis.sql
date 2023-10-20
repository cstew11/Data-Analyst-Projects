
--Created New Database in SSMS and imported flat file of the Crime Data
select *
from Crime_LA
---
--Filter Data to Crime Date Occurred to only 2022
select *
into Filtered_Crime_LA
from [Crime LA 2020-Present]..Crime_LA
where DATE_OCC like '2022%';

--Filter Data to only the top 5 crimes committed
select Crm_Cd_Desc, count(crm_cd_desc) as count, ROW_NUMBER() over (order by count(*) desc) as RowNum
into #TempTop5
from Filtered_Crime_LA
group by Crm_cd_desc

delete from #TempTop5
where RowNum > 5

delete from Filtered_Crime_LA
where Crm_Cd_Desc NOT IN (select Crm_Cd_Desc from #TempTop5)

Drop table #TempTop5
----------------------------------
select *
from Filtered_Crime_LA
----------------------------------
--Drop Columns not going to use

alter table filtered_Crime_LA
drop column DR_NO, Rpt_Dist_No, Part_1_2,  Mocodes, Premis_Cd, Weapon_Used_Cd, Status, Crm_Cd_1,
			Crm_Cd_2, Crm_Cd_3,Crm_Cd_4, Cross_Street, Crm_Cd
-----------------------------------
--Import into PowerBi and perform the rest of cleaning and analysis
--using Dax and Power Query Editor