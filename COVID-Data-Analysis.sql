SELECT *
FROM CovidDataProject..CovidDeaths
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataProject..CovidDeaths
ORDER BY 1, 2

--total cases vs total deaths
--death percentage in the US
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100,4) AS death_percentage
FROM CovidDataProject..CovidDeaths
WHERE location like 'United States'
ORDER BY 1, 2

-- total cases vs population
-- % of population with COVID in the US
SELECT location, date, total_cases, population,ROUND(total_cases/population*100,2) AS cases_percentage
FROM CovidDataProject..CovidDeaths
WHERE location like 'United States'
ORDER BY 1, 2

--countries with highest infection rate compared to population 
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidDataProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

--Countries with highest death count per population
SELECT location, MAX(cast(total_cases AS INT)) AS total_death_count
FROM CovidDataProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- global numbers
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths AS INT)) AS global_deaths, ROUND(SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100, 5) AS global_death_percentage
FROM CovidDataProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- join tables
SELECT *
FROM CovidDataProject..CovidDeaths 
JOIN CovidDataProject..CovidVaccinations 
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date

-- population vs new vaccinations 
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date,CovidDeaths.population, CovidVaccinations.new_vaccinations
,SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as people_vaccinated
FROM CovidDataProject..CovidDeaths
JOIN CovidDataProject..CovidVaccinations
 ON CovidDeaths.location = CovidVaccinations.location
 AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
ORDER BY 2, 3

WITH PopvsVac (continent, location, date, population, new_vaccinations, people_vaccinated)
AS (
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date,CovidDeaths.population, CovidVaccinations.new_vaccinations
,SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as people_vaccinated
FROM CovidDataProject..CovidDeaths
JOIN CovidDataProject..CovidVaccinations
 ON CovidDeaths.location = CovidVaccinations.location
 AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
)
SELECT *, ROUND((people_vaccinated/population)*100, 4) 
FROM PopvsVac
