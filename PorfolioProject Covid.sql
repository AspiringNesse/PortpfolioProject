SELECT * 
FROM covid_deaths


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE location like '%states%'
ORDER BY 1,2


SELECT location, date, total_cases, total_deaths as death, (total_deaths / total_cases)*100
as Death_Percentage
FROM covid_deaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths as death, (total_deaths / total_cases)*100
as Death_Percentage
FROM covid_deaths
WHERE location like '%states%'
ORDER BY 1,2

--ALTER TABLE COLUMN TO QUERY PERCENTAGE
ALTER TABLE covid_deaths
ALTER COLUMN total_cases int

ALTER TABLE covid_deaths
ALTER COLUMN total_deaths int

--SHOW PERCENTAGE who got Infected
SELECT location, date, total_cases, population, (total_cases/population)* 100
as CovidPercentage
FROM covid_deaths
ORDER BY 1,2

--Highest Covid in Percentage
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100
AS CovidPercentageInfected
FROM covid_deaths
GROUP BY location, population
ORDER BY CovidPercentageInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeath_ByContinent
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeath_ByContinent DESC

--OVERALL NEW DEATH PERCENTAGE
SELECT SUM(new_cases)as TotalNewCases, SUM(new_deaths) as TotalNewDeath, 
SUM(new_deaths) / SUM(new_cases)*100 as DeathPercentage
FROM covid_deaths
where continent is not null
--GROUP BY date
ORDER BY 1,2



SELECT *
FROM covid_deaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--POPUPLATION, TOTAL CASES, TOTAL DEATHS, TOTAL VACCINATION AND THOSE WHO GOT BOOSTER
SELECT deaths.location, deaths.date, deaths.population, deaths.total_cases, deaths.total_deaths, 
vac.total_vaccinations, vac.total_boosters
FROM covid_deaths deaths
JOIN covidvaccinations vac
ON deaths.location = vac.location
ORDER BY location ASC


--TOTAL POPULATION vs TOTAL VACCINATIONS

SELECT death.continent, death.location, death.date, death.population, vac.total_vaccinations
FROM covid_deaths death
JOIN covidvaccinations vac
	ON death.location = vac.location

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) AS PeopleVaccinated 
FROM covid_deaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE TO GET PERCENTAGE
WITH PercentVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(real,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM covid_deaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT * ,(PeopleVaccinated / Population) as PercentageVaccinated

FROM PercentVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(real,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM covid_deaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is not null


SELECT *, (PeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATE VIEW FOR VISUALIZATION

CREATE VIEW PercentVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date)
AS PercentageOfVaccinated
FROM covid_deaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null


SELECT * FROM PercentVaccinated