-- This is an exploratory data analysis of a comprehensive collection of fictional data pertaining to 1500 individuals diagnosed with OCD, with a wide variety of parameters. 
-- This is a link to the dataset: https://www.kaggle.com/datasets/ohinhaque/ocd-patient-dataset-demographics-and-clinical-data/

-- 1. Count and percentage of males vs females that were diagnosed with OCD. This code uses a Subquery as well.
SELECT Gender,COUNT(Gender) AS `Patient Count`, ROUND((COUNT(Gender)/(SELECT COUNT(Gender) FROM ocd)*100),2) AS `Gender Percentage`  FROM ocd
GROUP BY Gender;
-- We can see that the male to female count is 753 (50.2%) to 747 (48.80%) respectively. 	

-- 2. Count and Average Obsession Score by Ethnicity 
SELECT Ethnicity, COUNT(Ethnicity) AS `Patient Count`, ROUND(AVG(`Y-BOCS Score (Obsessions)`),2) AS `Avg Obsession Score`
FROM ocd
GROUP BY Ethnicity
ORDER BY 3 DESC
;
-- Here we can see that Asian patients have the highest average obsession score, with African having the lowest. The Obsession score represents the frequency/intensity of impulses or ideas that intrudes on one's ability to resist these impulses. 

-- 3. Patient count based on Compulsion Type and the respective Obsession Score
SELECT `Compulsion Type`,COUNT(*) AS `Patient Count`, ROUND(AVG(`Y-BOCS Score (Obsessions)`),2) AS `Average Obsession Score` 
FROM ocd
GROUP BY `Compulsion Type`
ORDER BY 3 DESC
;
-- Here it is shown that the the "Counting" Compulsion Type has the highest average obsession score, meaning they have the most intense/frequent interference to thinking due to obsessions. 

-- 4. Number of people diagnosed with OCD, with running sum by date, and percent change month by month (Using LAG)
WITH CTE AS(
SELECT 
	DATE_FORMAT(`OCD Diagnosis Date`,'%Y-%m') AS Date, 
    COUNT(`Patient ID`) AS `Patient Count`
FROM ocd
GROUP BY 1
ORDER BY 2 DESC
)
SELECT 
	Date,
    `Patient Count`,
    ROUND((`Patient Count` - LAG(`Patient Count`) OVER(ORDER BY Date)) / LAG(`Patient Count`) OVER(ORDER BY Date) * 100,2) AS `Percent Change of Patients from Previous Month`,
    SUM(`Patient Count`) OVER(ORDER BY Date) AS `Running Sum of OCD Patients`
    FROM CTE
    ORDER BY Date

;
-- Here we can see that June to July of 2019 had the highest change of OCD Patient Count in a one month interval with a change of 143%. 

-- 5. Most common Obession Type and it's respective Average Obsession Score
SELECT 
	`Obsession Type`,
    COUNT(`Obsession Type`) AS `Type Count`,
    AVG(`Y-BOCS Score (Obsessions)`) AS `Average Obsession Score`
FROM ocd
GROUP BY `Obsession Type`
ORDER BY COUNT(`Obsession Type`) DESC
;
-- Here we see that "Harm-related" Obession Type is the most common with an average Obsession score of 20.65.

-- 6. Relating Anxiety Diagnoses to severity of Obsessions
With CTE AS(
SELECT `Anxiety Diagnosis`,
	CASE
		WHEN `Y-BOCS Score (Obsessions)` <= 7 THEN 'Subclinical'
        WHEN `Y-BOCS Score (Obsessions)` BETWEEN 8 AND 15 THEN 'Mild'
        WHEN `Y-BOCS Score (Obsessions)` BETWEEN 16 AND 23 THEN 'Moderate'
        WHEN `Y-BOCS Score (Obsessions)` BETWEEN 24 AND 31 THEN 'Severe'
        ELSE 'Extreme' END AS `Obsession Severity`
FROM ocd)
SELECT COUNT(`Anxiety Diagnosis`) AS `Anxiety Diagnosis Count`, `Obsession Severity`  FROM CTE
WHERE `Anxiety Diagnosis` = 'Yes'
GROUP BY 2
ORDER BY 1 DESC
;
-- Here we can see that the highest amount of Anxiety diagnoses is correlated with an "Extreme" severity of Obsession. Interestingly, the second highest count is related to subclinical severity.  
