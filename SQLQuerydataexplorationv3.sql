/*

Data Exploration of World Covid Data till 25-05-2023

*/

SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 2,3


----------------------------------------------------------------------------------------------

-- SELECT the columns needed

SELECT location, date , total_cases, new_cases , total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2


------------------------------------------------------------------------------------------------

-- Look at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid in your country

SELECT location, date , total_cases,total_deaths , (total_deaths /total_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


SELECT location, date , total_cases, total_deaths ,(total_deaths/total_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE location like '%Pakist%'
ORDER BY 1,2


----------------------------------------------------------------------------------------------

-- Look at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date , total_cases,Population , (total_cases/population)*100 AS CasesPercantage
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


SELECT location, date , total_cases,Population , (total_cases/population)*100 AS CasesPercantage
FROM CovidDeaths
--WHERE location like '%pakistan%'
ORDER BY 1,2


----------------------------------------------------------------------------------------------

-- Look at countaries with Highest infection rate compared to population

SELECT location, Population , MAX( total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 AS PercenatagePopulationInfected
FROM CovidDeaths
GROUP BY location , Population
ORDER BY PercenatagePopulationInfected DESC


----------------------------------------------------------------------------------------------

-- Looking at countaries with Highest death count compared to population

SELECT location, Population , MAX( total_deaths) AS HighestDeathCount, 
MAX(total_deaths/ population)*100 AS PercenatagePopulationDeath
FROM CovidDeaths
GROUP BY location , Population
ORDER BY HighestDeathCount DESC 


SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL


SELECT location,Population , MAX( total_deaths) AS HighestDeathCount, 
MAX(total_deaths/ population)*100 AS PercenatagePopulationDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location , Population
ORDER BY HighestDeathCount DESC 


----------------------------------------------------------------------------------------------

-- Break down Death Count by continent

SELECT continent, MAX( total_deaths) AS HighestDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC 


SELECT *
FROM CovidDeaths
WHERE continent is null
--WHERE location = 'Asia'


---------------------------------------------------------------------------------------------

-- Find the continent with highest deathcount per population

SELECT continent, MAX( total_deaths) AS HighestDeathCount , 
MAX(total_deaths/ population)*100 AS PercenatagePopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercenatagePopulationDeath DESC 


----------------------------------------------------------------------------------------------

-- Gloabal Numbers

SELECT  date , total_cases, total_deaths ,(total_deaths/total_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date , total_cases, total_deaths
ORDER BY DeathPercantage DESC

DELETE
FROM CovidDeaths 
WHERE total_deaths > total_cases


SELECT  date, SUM(new_cases) AS DailyCases , SUM(new_deaths) AS DailyDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


SET ANSI_WARNINGS OFF
GO

SELECT  date, SUM(new_cases) AS DailyCases , SUM (new_deaths) AS DailyDeaths, 
SUM(new_deaths)/ NULLIF (SUM(new_cases),0) *100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY  1,2

SELECT SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths, 
SUM(new_deaths)/SUM (new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null


---------------------------------------------------------------------------------------------

SELECT *
FROM CovidVaccinations


SELECT * 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location


---------------------------------------------------------------------------------------------

-- Look at Total Population vs Vaccination

SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3 DESC


SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations ,
SUM (cast(new_vaccinations as bigint)) OVER (PARTITION BY dea.location) 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM (CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3


----------------------------------------------------------------------------------------------

-- Use CTE

WITH PopvsVac (continent, Location, date, new_vaccinations, population, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations , dea.population,
SUM (cast (vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
)

SELECT * , (RollingPeopleVaccinated/population )* 100 AS RPVRate
FROM PopvsVac


----------------------------------------------------------------------------------------------

--Use Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population,
SUM (cast (vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location

SELECT * , (RollingPeopleVaccinated / NULLIF(population,0) ) * 100 AS RPVRate
FROM #PercentPopulationVaccinated


----------------------------------------------------------------------------------------------

-- Creating View to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population,
SUM (cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null

SELECT *
FROM PercentagePopulationVaccinated 