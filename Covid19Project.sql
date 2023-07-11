-- Query to confirm table was uploaded correctly

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Looking at total cases vs total deaths
-- Shows liklihood of dying if you have a confirmed covid infection by country  

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid19..CovidDeaths
--WHERE location like '%Kingdom' 
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at total cases vs population to show what % of the population were confirmed to have contracted covid19 at some point in the data timescale 

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_population_covid
FROM Covid19..CovidDeaths
--WHERE location like '%Kingdom'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population 

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS percentage_population_covid
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY percentage_population_covid DESC;

-- Show countries with highest death count per population 

SELECT location, MAX(total_deaths) as total_death_count
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Show continents with highest death count per population 

SELECT continent, MAX(total_deaths) as total_death_count
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

SELECT location, MAX(total_deaths) as total_death_count
FROM Covid19..CovidDeaths
WHERE continent IS NULL -- This works because in the data any location that is a continent has the continent column as NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Daily global death percentage grouped by date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100  AS death_percentage
FROM Covid19..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Global death rate

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100  AS death_percentage
FROM Covid19..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- This is the standard join (inner join) query to more efficiently link the two tables

SELECT * FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Looking at total population vs vaccinations. I made a CTE so further calculations can be performed on the created "total_vaccinations_rolling_count" column

WITH PopVsVac (continent, location, date, population, new_vaccinations, total_vaccinations_rolling_count) 
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS total_vaccinations_rolling_count
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (total_vaccinations_rolling_count/population)*100 AS percentage_population_vaccinated FROM PopVsVac

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(continent NVARCHAR(255), location NVARCHAR(255), date Date, population Numeric, new_vaccinations Numeric, total_vaccinations_rolling_count Numeric)
 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS total_vaccinations_rolling_count
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY date

SELECT *, (total_vaccinations_rolling_count/population)*100 AS percentage_population_vaccinated FROM #PercentPopulationVaccinated

-- Creating views to store data for future visualisations

--DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) AS total_vaccinations_rolling_count
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated;

CREATE VIEW DeathPercentage as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid19..CovidDeaths
--WHERE location like '%Kingdom' 
WHERE continent IS NOT NULL

SELECT * FROM DeathPercentage;

CREATE VIEW PercentagePopulationCovid as
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_population_covid
FROM Covid19..CovidDeaths
--WHERE location like '%Kingdom'
WHERE continent IS NOT NULL

SELECT * FROM PercentagePopulationCovid;


CREATE VIEW InfectionRateByPopulation as
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS percentage_population_covid
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location

SELECT * FROM InfectionRateByPopulation
ORDER BY percentage_population_covid DESC;

CREATE VIEW DeathRateByCountry as
SELECT location, MAX(total_deaths) as total_death_count
FROM Covid19..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

SELECT * FROM DeathRateByCountry
ORDER BY total_death_count DESC;

CREATE VIEW ContinentDeathRate as
SELECT location, MAX(total_deaths) as total_death_count
FROM Covid19..CovidDeaths
WHERE continent IS NULL 
GROUP BY location

SELECT * FROM ContinentDeathRate
ORDER BY total_death_count DESC;

CREATE VIEW GlobalMortalityRate as
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100  AS death_percentage
FROM Covid19..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date

SELECT * FROM GlobalMortalityRate
ORDER BY 1, 2


