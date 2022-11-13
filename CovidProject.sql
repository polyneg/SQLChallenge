--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

--DATA TO BE USED 

SELECT
location
, date
, total_cases
, new_cases
, total_deaths
, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--LOOKING AT TOTAL CASES vs TOTAL DEATHS
--Likelihood of dying if you contract covid in your country
SELECT 
location
, date
, total_cases
, total_deaths
, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Philippines'
ORDER BY 1,2 ASC

-- LOOKING AT THE TOTAL CASES vs POPULATION
--Shows what percentage of population got Covid
SELECT 
location
, date
, population
, total_cases
, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Philippines'
ORDER BY 4 DESC

--Country with Highest Infection Rates
SELECT 
location
, population
, MAX(total_cases) as HighestInfectionCount
, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY 2 DESC

--Countries with Highest Death Count per Population
SELECT 
location
, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT 
continent
, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS 
SELECT 
date
, SUM(new_cases) as totalcases
, SUM(cast(new_deaths as int)) as totaldeaths
, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1


SELECT 
SUM(new_cases) as totalcases
, SUM(cast(new_deaths as int)) as totaldeaths
, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1

--JOINS 
Select * 
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date

--Total Population vs Vaccination

SELECT 
cd.continent
, cd.location
, cd.date
, cd.population 
, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rollingvaccinationcount
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
--AND cd.location = 'Philippines'
ORDER BY 2,3

--USING CTE 

WITH popvsvac (continent, location, date, population,new_vaccinations,rollingvaccinationcount)
AS
(
SELECT 
cd.continent
, cd.location
, cd.date
, cd.population 
, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rollingvaccinationcount
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
)

SELECT 
* 
,(rollingvaccinationcount/population)*100 as rollingpercentageofvaccinate
FROM popvsvac

--USING TEMPTABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 

CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
Rollingvaccinationcount numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT 
cd.continent
, cd.location
, cd.date
, cd.population 
, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rollingvaccinationcount
FROM PortfolioProject..CovidDeaths$ cd
JOIN PortfolioProject..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null


SELECT 
* 
,(rollingvaccinationcount/population)*100 as rollingpercentageofvaccinate
FROM #PercentPopulationVaccinated 
