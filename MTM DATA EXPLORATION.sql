--EXPLORING CUSTOMER DATA COLLECTED FROM JAN 23 - JUN 23 FOR THE MADE TO MEASURE SERVICE OF A TAILORING SHOP I WORK FOR IN ORDER TO GAIN VALUABLE INSIGHTS INTO 
--CUSTOMER BEHAVIOUR BASED ON A SET NUMBER OF CHARACTERISTICS, WHICH WAS USED TO ASSIST THE MARKETING TEAM IN OPTIMISING THEIR DIGITAL MARKETING STRATEGY. 

--Data was collected manually over a 6 month period and stored in a secure Excel spreadsheet on a secure server. This contained information on the customers name, what they purchased, 
--their age, reason for purchase and whether they were new or returning customers, amongst other variables. 
--Please note that due to client confidentiality, the database name has been changed for this file. 

SELECT *
FROM Client.dbo.mtm

--Calculating the total sum of MTM orders for the first half of the year

SELECT SUM([Total Value (£)]) as Total_overall_value
FROM Client.dbo.mtm 

--Calculating the Average Transaction Value for the first half of the year 

SELECT AVG([Total Value (£)]) as Average_transaction_value
FROM Client.dbo.mtm 

--Calculating the Units Per Transaction Value for the first half of the year 

SELECT AVG([Total items]) as Units_per_transaction
FROM Client.dbo.mtm 

--Calculating the Total Sales by Consultant 

SELECT Consultant, SUM([Total Value (£)]) as Total_sales_by_staff
FROM Client.dbo.mtm
GROUP BY Consultant
ORDER BY 2 desc

--Calculating the Average Transaction Value by Consultant

SELECT Consultant, AVG([Total Value (£)]) as Total_sales_by_staff
FROM Client.dbo.mtm
GROUP BY Consultant
ORDER BY 2 desc

--Calculating the Units Per Transaction by Consultant

SELECT Consultant, AVG([Total items]) as Total_sales_by_staff
FROM Client.dbo.mtm
GROUP BY Consultant
ORDER BY 2 desc

--CUSTOMER EXPLORATION

--Checking the make up of customers by age

SELECT [Age range], SUM([C# count]) as Age_range_sum
FROM Gieves.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]

SELECT [Age range], 
       COUNT([C# count]) as Age_range_count, 
       COUNT([C# count])*100/((SELECT COUNT([C# count]) FROM Gieves.dbo.mtm)) as Age_range_percentage
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]
ORDER BY 3 desc


--Checking the make up of customers by reason of purchase 

SELECT [Reason], SUM([C# count]) as Reason_sum
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]

SELECT [Reason], 
       COUNT([C# count]) as Reason_count, 
       COUNT([C# count])*100/((SELECT COUNT([C# count]) FROM Gieves.dbo.mtm)) as Reason_percentage
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]
ORDER BY 3 desc


--Comparing the spend of customers by age

SELECT [Age range], SUM([Total Value (£)]) as Sum_of_Total_Value_by_age_range
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]
ORDER BY 2 desc

--Comparing the share of spend of customers by age

SELECT [Age range], 
       SUM([Total Value (£)]) as Age_range_count, 
       SUM([Total Value (£)])*100/((SELECT SUM([Total Value (£)]) FROM Gieves.dbo.mtm)) as Spend_Age_range_percentage
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]
ORDER BY 3 desc


--Comparing the spend of customers by reason 

SELECT [Reason], SUM([Total Value (£)]) as Sum_of_Total_Value_by_reason
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]
ORDER BY 2 desc

--Comparing the share of spend of customers by Reason

SELECT [Reason], 
       SUM([Total Value (£)]) as Reason_sum, 
       SUM([Total Value (£)])*100/((SELECT SUM([Total Value (£)]) FROM Gieves.dbo.mtm)) as Spend_reason_percentage
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]
ORDER BY 3 desc


--Checking for the Average Transaction Value (ATV) by age

SELECT [Age range], AVG([Total Value (£)]) as ATV_by_age_range
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]
ORDER BY 2 desc

--Checking for Average Transaction Value (ATV) by reason 

SELECT [Reason], AVG([Total Value (£)]) as ATV_by_reason
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]
ORDER BY 2 desc

--Checking for Units Per Transaction by age range 

SELECT [Age range], AVG([Total items]) as UPT_age_range
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL 
GROUP BY [Age range]
ORDER BY 2 DESC 

--Checking for Units Per Transaction by reason 

SELECT [Reason], AVG([Total items]) as UPT_reason
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL 
GROUP BY [Reason]
ORDER BY 2 DESC 

--FURTHER EXPLORATION OF CUSTOMER PURCHASE PATTERNS BY PRODUCT AND CLOTH MILL

--Finding out what item/item pairs sold the most by number of orders

--SELECT [Item], COUNT([C# count])
--FROM Client.dbo.mtm
--GROUP BY [Item]

SELECT [Primary Mill], 
      SUM([P#Value (£)]) as Total_value_by_mill
FROM Client.dbo.mtm
GROUP BY [Primary Mill]
ORDER BY 2 DESC

SELECT [Primary Mill], 
      SUM([P#Value (£)]) as Total_value_by_mill, 
	  SUM([P#Value (£)])*100/((SELECT SUM([P#Value (£)]) FROM Gieves.dbo.mtm)) AS Primary_mill_sale_percentage
FROM Client.dbo.mtm
GROUP BY [Primary Mill]
ORDER BY 2 DESC

--CREATING TEMP TABLES FOR VISUALISATION AND FURTHER ANALYSIS

--Temp table analysing the relationship of customer age groups relative to make up and spend

CREATE TABLE #analysisbyage
(
age_range nvarchar(255),
number_of_customers numeric,
percentage_of_customers numeric,
sales_value numeric,
percentage_of_sales numeric,
ATV numeric,
UPT numeric
)

INSERT INTO #analysisbyage
SELECT 
      [Age range], 
      COUNT([C# count]), 
      COUNT([C# count])*100/((SELECT COUNT([C# count]) FROM Gieves.dbo.mtm)), 
      SUM([Total Value (£)]), 
      SUM([Total Value (£)])*100/((SELECT SUM([Total Value (£)]) FROM Gieves.dbo.mtm)), 
      AVG([Total Value (£)]), 
      AVG([Total items])
FROM Client.dbo.mtm
WHERE [Age range] is NOT NULL
GROUP BY [Age range]
ORDER BY 3, 4 

SELECT * 
FROM #analysisbyage

--Temp table analysing the relationship of reasons for purchase relative to make up and spend

CREATE TABLE #analysisbyreason
(
reason nvarchar(255),
number_of_customers numeric,
percentage_of_customers numeric,
sales_value numeric,
percentage_of_sales numeric,
ATV numeric,
UPT numeric
)

INSERT INTO #analysisbyreason
SELECT 
      [Reason], 
      COUNT([C# count]), 
      COUNT([C# count])*100/((SELECT COUNT([C# count]) FROM Gieves.dbo.mtm)), 
      SUM([Total Value (£)]), 
      SUM([Total Value (£)])*100/((SELECT SUM([Total Value (£)]) FROM Gieves.dbo.mtm)), 
      AVG([Total Value (£)]), 
      AVG([Total items])
FROM Client.dbo.mtm
WHERE [Reason] is NOT NULL
GROUP BY [Reason]
ORDER BY 3, 4 

SELECT *
FROM #analysisbyreason
