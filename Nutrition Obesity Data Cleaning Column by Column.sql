/*

Nutrition, Physical Activity, and Obesity on Behavioral Risk 
Data Cleaning: Cleaning Data in order of Columns Left to Right
Commentary and Thought Process Included
Skills Used: Aggregate Functions, CASE, CTE's, Windows Functions, Converting Data Types, Alter Table

*/

select *
from Nutrition_PA_Obesity
	-- total row count 88,629

--Evaluate YearStart and YearEnd Columns
select YearStart, YearEnd
from Nutrition_PA_Obesity
where YearStart <> YearEnd
	-- All rows start and end in the same year. This can be condensed into one column named Year.
		--YearStart renamed to Year using sidebar
			--YearEnd column dropped
			Alter Table Nutrition_PA_Obesity
			Drop column YearEnd
		
--Evaluate LocationAbbr Column 
select distinct LocationAbbr
from Nutrition_PA_Obesity
	--55 Results, 50 States in USA, Additional 5: DC (District of Columbia), GU (Guam), PR (Puerto Rico), US (National), VI (Virgin Islands)

--Evaluate LocationDesc Column 
	--Verify all LocationDesc match to correct LocationAbbr
	with location_verify as 
		(select locationabbr, count(locationabbr) as countabbr, count(locationdesc) as countdesc
		from Nutrition_PA_Obesity
		group by LocationAbbr)

		select locationabbr, countabbr, countdesc
		from location_verify 
		where countabbr <> countdesc
		--All are correctly matched and syntaxed

--Evaluate Datasource Column 
select distinct datasource
from Nutrition_PA_Obesity

select count(datasource)
from Nutrition_PA_Obesity
	--All rows have identical input (Behavioral Risk Factor Surveillance System) and none are null. This Column is not needed and can be dropped
		Alter Table Nutrition_PA_Obesity
		Drop Column datasource

--Evaluate Class and Topic Columns
select distinct class
from Nutrition_PA_Obesity

select class
from Nutrition_PA_Obesity
where class is null

select distinct Topic
from Nutrition_PA_Obesity
	--Both Class and Topic Columns have 3 distinct rows, only difference is Topic has '-Behavior' at end of 2 of 3.
	--Topic can be dropped because is dupe column to Class and Class renamed to Topic for easiness.
		alter table Nutrition_PA_Obesity
		drop column Topic

--Evaluate Question Column
select distinct Question
from Nutrition_PA_Obesity
	--9 distinct questions
select Question
from Nutrition_PA_Obesity
where question is null
	--no nulls
		--leave column as if for now

--Evaluate Data_Value_Unit Column
select distinct Data_Value_Unit
from Nutrition_PA_Obesity
	--only nulls
select sum(case when Data_Value_Unit is null then 1 else 0 end)
from Nutrition_PA_Obesity
	--verify only nulls
		--drop column, provides no value
			alter table Nutrition_PA_Obesity
			drop column Data_Value_Unit

--Evaluate Data_Value_Type Column
select distinct Data_Value_Type
from Nutrition_PA_Obesity
	--only 'Value', Drop Column
		alter table Nutrition_PA_Obesity
			drop column Data_Value_Type

--Evaluate Data_Value_Alt, Data_Value_Footnote_Symbol, Data_Value_Footnote
	--Round Data Value to whole number
	--Drop Data_Value_Alt because same as Data_Value
	--Drop Both 'Footnote Columns' because have no info
		update Nutrition_PA_Obesity 
		set Data_value = round(data_value,0)

		alter table Nutrition_PA_Obesity
			drop column Data_Value_Alt
		
		alter table Nutrition_PA_Obesity
			drop column Data_Value_Footnote_Symbol
		
		alter table Nutrition_PA_Obesity
			drop column Data_Value_Footnote

--Evaluate Low and High Confidence Limit Columns
	--Round to whole numbers
	update Nutrition_PA_Obesity 
		set Low_Confidence_Limit = round(Low_Confidence_Limit,0)
	update Nutrition_PA_Obesity 
		set High_Confidence_Limit = round(High_Confidence_Limit,0)

--Keep Sample Size same for now

--Evaluate Total, Age_Years, Education 
	
select distinct total
from Nutrition_PA_Obesity

select distinct Age_Years 
from Nutrition_PA_Obesity

select distinct Education 
from Nutrition_PA_Obesity
	--drop Total, convert nulls in columns to Not Reported
		alter table Nutrition_PA_Obesity
			drop column Total 

		update Nutrition_PA_Obesity
		set Age_Years = case when Age_Years is null then 'Not Reported' else Age_Years end

		update Nutrition_PA_Obesity
		set Education = case when Education is null then 'Not Reported' else Education end

		update Nutrition_PA_Obesity
		set Gender = case when Gender is null then 'Not Reported' else Gender end



--Evaluate Income
select distinct Income, count(*)
from Nutrition_PA_Obesity
group by income 
	--change wacky data and nulls to data not reported
		update Nutrition_PA_Obesity
			set income = case when income = 'Data not reported' then 'Not Reported'
				when income is null then 'Not Reported' else income end

--Evaluate Race_Ethnicity
select distinct Race_Ethnicity
from Nutrition_PA_Obesity
	--change null to Not Reported
		update Nutrition_PA_Obesity
		set Race_Ethnicity = case when Race_Ethnicity is null then 'Not Reported' else Race_Ethnicity end

		--Evaluate GeoLocation
			--Seperate Latitude and Longitude into two new columns and round to 4 decimal places
			--Drop Geolocation

			alter table Nutrition_PA_Obesity
			add Latitude float

			update Nutrition_PA_Obesity
			set Latitude = round(substring(geolocation,2,8),4)

			alter table Nutrition_PA_Obesity
			add Longitude float

			update Nutrition_PA_Obesity
			set Longitude = round(replace(parsename(trim('()' from replace(replace(geolocation,'.','/'),',','.')),1),'/','.'),4)

			alter table Nutrition_PA_Obesity
			drop column Geolocation 
				--Leave nulls in Latitude and Longitude Column because dont want 'Not Reported' in float column

--Evaluate ClassID,TopicID
--Drop both columns because Topic Column alone can provide filtering
	alter table Nutrition_PA_Obesity
	drop column ClassID
	
	alter table Nutrition_PA_Obesity
	drop column TopicID

--Drop DataValueTypeID, StratificationCategory1,Stratification1 StratificationCategoryID1, and StratificationID1.
--These Columns provide no additional substance to table and are repeats of Age, Education,Gender, and Income. Each Row/Study used only 1/4 filters.

alter table Nutrition_PA_Obesity
drop column DataValueTypeID

alter table Nutrition_PA_Obesity
drop column StratificationCategory1

alter table Nutrition_PA_Obesity
drop column Stratification1

alter table Nutrition_PA_Obesity
drop column StratificationCategoryId1

alter table Nutrition_PA_Obesity
drop column StratificationId1

--Evaluate QuestionID and LocationID
	--I dont feel locationID adds additional depth to data. Drop Column
	--Change QuestionID to number by in relatoion to topic
		alter table Nutrition_PA_Obesity
		drop column LocationID

		alter table Nutrition_PA_Obesity
		drop column QuestionID


		alter table Nutrition_PA_Obesity
		add QuestionID tinyint

		update Nutrition_PA_Obesity
		set QuestionID = case when question like 'Percent of adults aged 18 years and older who have an overweight classification' then 1
							  when question like 'Percent of adults aged 18 years and older who have obesity' then 2
							  when question = 'Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)' then 3
							  when question = 'Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic physical activity and engage in muscle-strengthening activities on 2 or more days a week' then 4
							  when question like 'Percent of adults who achieve at least 300 minutes a week of moderate-intensity aerobic physical activity or 150 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)' then 5
							  when question like 'Percent of adults who engage in muscle-strengthening activities on 2 or more days a week' then 6
							  when question like 'Percent of adults who engage in no leisure-time physical activity' then 7
							  when question like 'Percent of adults who report consuming fruit less than one time daily' then 8
							  when question like 'Percent of adults who report consuming vegetables less than one time daily' then 9
							  else 0 
							  end 
		

--Rename Columns to be more clear

--Delete Rows that have no Data_Value
Delete from Nutrition_PA_Obesity where Data_Value is null 
8778 affected 

select count(*)
from Nutrition_PA_Obesity
where Data_value is null 
8778 

--Check and Remove Duplicates
with dup_table as (
select *,
	ROW_NUMBER() over (
	partition by year, data_value, sample_size, questionID, locationabbr, questionid, low_confidence_limit order by year) duplicates
	from Nutrition_PA_Obesity
	)
select *
from dup_table
where duplicates > 1
--10 results
	--After further analysis I decided not to delete these because they are duplicates but except for Age_range,education, gender, income reporting is one per row. Example 2 same rows, one has age info, one has income info.
select *
from Nutrition_PA_Obesity
where year = 2019 and locationabbr = 'MN' and data_value = 41 and sample_size = 1046
	--example of reasoning for statement above ^

select *
from Nutrition_PA_Obesity
--79851 rows

--end 

--Exploratory Data Analysis

--1.Return The number of surveys by question in the year 2012

select question, count(*) as cnt
from Nutrition_PA_Obesity
group by year, question
having year = 2012

--2.Return the avg data value for questionid 2 of Obesity Topic (% obese adults) by state, order by desc
select location, round(avg(data_value),2) as avg
from Nutrition_PA_Obesity
group by location, questionid
having questionid = 2
order by avg(data_value) desc

--3.Return the top location by year who eats the most fruit and vegatables on average

select year, location, min(data)
from (select year, location, round(avg(data_value),2) as data
	from Nutrition_PA_Obesity
	where questionid = 8 or questionid = 9
	group by year,location) as a
group by year, location
order by min(data) asc

select year, min(data)
from (select year, location, round(avg(data_value),2) as data
	from Nutrition_PA_Obesity
	where questionid = 8 or questionid = 9
	group by year,location) as a
group by year
--Vermont 2017, Vermont 2019, Maine 2021 ate the most fruits and vegatables on aveage

--4.Return the  location with the 5 worst reults of question 5 and 6 averaged
	--locations workout the least
select Location, round(avg(data_value),2)
from Nutrition_PA_Obesity
where questionid = 5 or questionid = 6
group by location 
order by avg(data_value) asc
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY








