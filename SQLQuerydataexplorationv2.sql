SELECT *
FROM CovidDeaths
ORDER BY 3,4



--SELECT *
--FROM CovidVaccinations
--ORDER BY 2,3



-- SELECT the columns needed
SELECT location, date , total_cases, new_cases , total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location, date , total_cases, total_deaths ,(cast(total_deaths as int) /total_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


SELECT location, date , total_cases, total_deaths ,(total_deaths/total_cases)*100 AS DeathPercantage
FROM CovidDeaths
WHERE location like '%Pakist%'
ORDER BY 1,2



--Showing what percentage of population got COvid
SELECT location, date , total_cases,Population , (total_cases/population)*100 AS CasesPercantage
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2



-- Looking at countaries with Highest infectionrate compared to population
SELECT location,Population ,  MAX( total_cases) AS HighestInfectionCount,MAX(total_cases/population)*100 AS PercenatagePopulationInfected
FROM CovidDeaths
GROUP BY location , Population
ORDER BY PercenatagePopulationInfected DESC



-- Looking at countaries with Highest death count compared to population
SELECT location,Population ,  MAX( total_deaths)AS HighestDeathCount,MAX(total_deaths/ population)*100 AS PercenatagePopulationDeath
FROM CovidDeaths
GROUP BY location , Population
ORDER BY HighestDeathCount DESC 


SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL


SELECT location,Population ,  MAX( total_deaths)AS HighestDeathCount,MAX(total_deaths/ population)*100 AS PercenatagePopulationDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location , Population
ORDER BY HighestDeathCount DESC 



-- Breaking thing down by continent
SELECT continent,  MAX( total_deaths)AS HighestDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC 


SELECT *
FROM CovidDeaths
WHERE continent is null
--WHERE location = 'Asia'


SELECT location ,  MAX( total_deaths)AS HighestDeathCount 
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC 


-- Showing the continent with highest deathcount per population
SELECT continent,  MAX( total_deaths)AS HighestDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC 



-- Gloabal Numbers
SELECT  date , total_cases, total_deaths ,(total_deaths/total_cases)*100 AS DeathPercantage
FROM CovidDeaths
GROUP BY date , total_cases, total_deaths
ORDER BY 1,2


SELECT  date , SUM (new_cases) AS DailyCases , SUM (new_deaths)AS DailyDeaths
FROM CovidDeaths
GROUP BY date 
ORDER  BY DailyDeaths DESC


SELECT  date , SUM (new_cases) AS DailyCases , SUM (cast(new_deaths as int))AS DailyDeaths, SUM (cast(new_deaths as int)) /SUM (new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY  1,2


SELECT SUM (new_cases) AS DailyCases , SUM (new_deaths)AS DailyDeaths , SUM (new_deaths)/SUM (new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null



SELECT *
FROM CovidVaccinations


SELECT * 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location



-- looking  at total population vs vaccination
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3 DESC


SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations ,
SUM (new_vaccinations) OVER (PARTITION BY dea.location) 
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3


SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations ,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY 
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
ORDER BY 2,3



-- USE CTE

WITH PopvsVac(continent, Location, date, new_vaccinations, population ,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations , dea.population,
SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
--ORDER BY 2,3
)

SELECT * ,(RollingPeopleVaccinated / population ) * 100 AS
FROM PopvsVac


--Use Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( Continent nvarchar(255),
Location nvarchare(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations , dea.population,
SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
--WHERE  dea.continent is not null
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated / population ) * 100 AS
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent , dea.location, dea.date, vac.new_vaccinations , dea.population,
SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE  dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated