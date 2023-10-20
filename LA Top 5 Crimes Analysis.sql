
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
--Categorizing Victim Age
--created a new table to upload into Power BI and make relationship in the model view
select 
vict_age, case when Vict_age = '0' then 'Unknown'
				when Vict_age is null then 'Unknown'
				when Vict_age between '1' and '12' then 'Child'
				when Vict_age between '13' and '17' then 'Teenager'
				when Vict_age between '18' and '24' then 'Young Adult'
				when Vict_age between '25' and '64' then 'Adult'
				when Vict_age between '65' and '100' then 'Elderly'
				else 'Unknown'
				end as Age_Cat
into Ages_Table 
from Filtered_Crime_LA
---------------------------------------
--Categorizing Time of Day
select 
time_occ, case when cast(time_occ as varchar) between '06' and '12' then 'Morning'
			when convert(varchar,time_occ) between '12' and '17' then 'Afternoon'
			when convert(varchar,time_occ) between '17' and '21' then 'Evening'
			when convert(varchar,time_occ) between '21' and '24' then 'Nighttime'
			when convert(varchar,time_occ) between '00' and '06' then 'After Midnight'
			else cast(time_occ as varchar)
			end as Crime_Time
into CrimeTime_Table 
from Filtered_Crime_LA

--Import into PowerBi and perform the rest of cleaning and analysis
--using Dax and Power Query Editor