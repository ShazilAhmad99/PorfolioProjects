-- In this project, we will be looking at many COVID-19 statistics from countires across the world, with a focus on the country of Japan. The data was provided by the paper "Coronavirus (COVID-19) Deaths" by Mathieu et al. 
-- We will start by looking at the case and mortality table data for Japan. 

-- Looking at the Total Cases vs Total Deaths for Japan with a ratio.
SELECT date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100),2) AS death_to_case_percentage
FROM deaths
WHERE location='Japan'
ORDER BY 1 DESC;
-- Here we can see that, for Japan, the most recent datapoint gives a death to case ratio of 0.22%. This means that someone who tests postive for COVID-19 has a 0.22% chance of dying, in general.

-- Next we will look at the Total Cases vs Population with a ratio.
SELECT date, total_cases, population, ROUND((total_cases/population*100),2) AS case_pop_percentage
FROM deaths
WHERE location='Japan'
ORDER BY date DESC;
-- Here we can see that the most recent datapoont gives us a case to population percentage of 27%. This also means a resident of Japan has a 27% chance of contracting COVID-19, in general.

-- Now we will do the same comparison, but try to find when the case to population percentage first reached 10%
SELECT date, total_cases, population, ROUND((total_cases/population*100),2) AS case_pop_percentage
FROM deaths
WHERE location='Japan' AND ROUND((total_cases/population*100),2) LIKE '10%'
ORDER BY date
LIMIT 1;
-- Here we can see that the data shows the case to population percentage first reached 10% on July 31, 2022. 

-- Now we will do the same comparison, but try to find when the case to population percentage first reached its maximum amount.
SELECT date, (ROUND((total_cases/population*100),2)) AS max_case_pop_percentage
FROM deaths
WHERE location='Japan' AND (ROUND((total_cases/population*100),2)) = (
	SELECT 
	MAX((ROUND((total_cases/population*100),2))) 
    FROM deaths 
    WHERE location='Japan' )
ORDER BY 1 
;
-- Here we can see that the case to population percentage first reached the maximum amount of 27.27% on May 14, 2023. 

-- Next we will take a quick look at the day Japan had the highest amount of deaths by looking at the new_deaths column.
SELECT date, new_deaths
FROM deaths
WHERE location = 'Japan'
ORDER BY new_deaths DESC
LIMIT 1;
-- Here we can see that on February 5, 2023, Japan had almost 11,000 new confirmed deaths. This is the highest death day. 

-- Now we will look at all countries in the dataset and their maxiumum infection rates. 
SELECT location, population, MAX(total_cases) as highest_case_count, MAX((ROUND((total_cases/population*100),2))) AS max_case_pop_percentage
FROM deaths
GROUP BY 1,2
ORDER BY 4 DESC;
-- Cyprus has the highest case to population percentage, the low population count may contribute to this higher value. 

-- Next we will look at the death counts of different countries.
SELECT location, MAX(total_deaths) as highest_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
-- Here we see that the United States has had the highest death count. 

-- Next we can look at the death rates for the locations other than specific countries.  
SELECT location, MAX(total_deaths), MAX(total_deaths/population*100) as  death_percentage
FROM deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2  DESC;
-- Here we see that Europe is the continent with the highest death count.

-- Let us take a final look at worldwide mortality rates using SUM()
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)*100) AS death_to_case_percentage
FROM deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;
-- Here we see that from the total confirmed cases worldwide, 0.91% have lead to death. 

-- Now that we have explored the "deaths" table, let us also join it with the another table, "vaccines," and explore the resulting table. 

-- We will look at the total vaccinations for Japan going by date by using a running sum
SELECT deaths.location, deaths.date, deaths.population, new_vaccinations, 
SUM(new_vaccinations) OVER (ORDER BY deaths.date) AS running_sum_of_vacc
FROM deaths
JOIN vaccines
ON deaths.date=vaccines.date AND deaths.location=vaccines.location
WHERE deaths.location='Japan'
;
-- The running sum stopped increasing on May 8, 2023, so this is that last recorded instance of new vaccinations being administered. 

-- Let's do the same with all countries in the dataset.
SELECT deaths.location, deaths.date, deaths.population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS running_sum_of_vacc
FROM deaths
JOIN vaccines
ON deaths.date=vaccines.date AND deaths.location=vaccines.location
WHERE deaths.continent IS NOT NULL
;

-- We will use this joined table in a CTE to further look at the vaccinations to population ratios
With RunningVac AS (
SELECT deaths.location, deaths.date, deaths.population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS running_sum_of_vacc
FROM deaths
JOIN vaccines
ON deaths.date=vaccines.date AND deaths.location=vaccines.location
WHERE deaths.continent IS NOT NULL)
SELECT location, population, new_vaccinations, running_sum_of_vacc, (running_sum_of_vacc/population*100) AS percent_pop_vacc
FROM RunningVac
;
-- Many countries end up with a percentage of above 100%. This is because many people get multiple vaccines which count towards the running sum, so the vaccine count can go over the population count. 

-- For the final query, we will rank the countries based on the max percentage of people in the fully vaccinated column to the population while also adding a ranking by percentage
SELECT RANK() OVER(ORDER BY MAX(people_fully_vaccinated/population*100) DESC) AS ranking, 
	deaths.location, population, MAX(people_fully_vaccinated), MAX(people_fully_vaccinated/population*100) AS fully_vacc_percentage
FROM deaths
JOIN vaccines
ON deaths.date=vaccines.date AND deaths.location=vaccines.location
WHERE deaths.continent IS NOT NULL
GROUP BY deaths.location, population
ORDER BY ranking
;
-- Again we see countries with over 100% values. This is due to the unchanging population count for each country throughout the dataset. This could be a problem to be addressed within the data collection process. Nonetheless, it seems that Gibraltar has the highest rank of fully vaccinated persons percentage at 127%. And Japan is rank 31 at 83%. 
