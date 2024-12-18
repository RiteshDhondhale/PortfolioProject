SELECT * 
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Case and Total Deaths

SELECT location, total_cases AS TotalCases, SUM(CONVERT(FLOAT, total_deaths)) AS TotalDeaths, (SUM(CONVERT(FLOAT, total_deaths))/SUM(total_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
GROUP BY location, total_cases
ORDER BY 2 DESC


-- Highest Infection Rate to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, AVG((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Total Deaths by Continent

SELECT continent, SUM(CAST(total_deaths as FLOAT)) AS TotalDeathCount , MAX(CAST(total_deaths as INT)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Showing continents with the highest death count per population
SELECT continent, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS float)) AS TotalDeaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

-- Looking at Total Population vs Vaccinations
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RolliingVaccinationCount
-- (RolliingVaccinationCount/population)*100
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL 
ORDER BY 1, 2, 3

-- Use CTE
WITH PopVSVac (Continent, Location, Date, Population, NewVaccination, RollingVaccinationCount)
AS 
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RolliingVaccinationCount
-- (RolliingVaccinationCount/population)*100
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (NewVaccination/Population)*100
FROM PopVSVac
WHERE Location = 'India'

DROP TABLE IF EXISTS #PopVSVac

CREATE TABLE #PopVSVac(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
NewVaccination numeric, 
RollingVaccinationCount numeric
)

INSERT INTO #PopVSVac
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RolliingVaccinationCount
-- (RolliingVaccinationCount/population)*100
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (NewVaccination/Population)*100 AS PercentPopulationNewVaccinated
FROM #PopVSVac
ORDER BY 2, 3

-- Create View to store data for later visualizations

CREATE VIEW PopVSVac AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RolliingVaccinationCount
-- (RolliingVaccinationCount/population)*100
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date

SELECT * FROM PopVSVac