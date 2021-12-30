UPDATE `covid_death`
SET `date` = str_to_date( `date`, '%d/%m/%Y' );

UPDATE `covid_vaccinations`
SET `date` = str_to_date( `date`, '%d/%m/%Y' );

UPDATE covid_death
SET
    continent = CASE continent WHEN '' THEN NULL ELSE continent END,
    location = CASE location WHEN '' THEN NULL ELSE location END;

-- shows likelihood of dying if you contract Covid in particular country
SELECT 
    location, population, date, total_cases, new_cases, total_deaths, round((total_deaths/total_cases)*100,2) AS death_percentage
FROM
    covid_death
WHERE location = "Indonesia"
ORDER BY location , date;

-- show the percentage of covid patient in particular country
SELECT 
    location, population, date, total_cases, new_cases, total_deaths, round((total_cases/population)*100,2) AS covid_percentage
FROM
    covid_death
WHERE location = "Indonesia"
ORDER BY location , date;

-- show the country with the highest infection rate
SELECT 
    location, population, date, MAX(total_cases) as highest_infection_count, 
    round((max(total_cases)/population)*100,2) AS percent_pop_infected
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY percent_pop_infected DESC;

-- show the country with the highest death count
SELECT location, population, date, MAX(CAST(total_deaths AS UNSIGNED)) as highest_death_count
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- show the country with the highest death count per pop
SELECT 
    location, population, date, MAX(total_deaths) as highest_death_count, 
    round((max(total_deaths)/population)*100,2) AS percent_death_per_pop
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY percent_death_per_pop DESC;

-- show the continent with the highest death count
SELECT location, population, MAX(CAST(total_deaths AS UNSIGNED)) as death_count
FROM covid_death
WHERE continent IS NULL and location !=  "Upper middle income" and location != "High income" and location != "Low income"
	and location != "Lower middle income" and location != "European union"
GROUP BY location
ORDER BY death_count DESC;

-- worldwide total cases and total deaths
SELECT 
    date, total_cases, total_deaths 
FROM
    covid_death
WHERE location = "World"
GROUP BY date
ORDER BY date;

-- worldwide new cases and new deaths
SELECT 
    date, new_cases, new_deaths 
FROM
    covid_death
WHERE location = "World"
GROUP BY date
ORDER BY date;