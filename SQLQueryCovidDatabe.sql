SELECT * FROM dbo.CovidDeath
WHERE continent IS NOT NULL


--Select the data to use

SELECT location,date, total_cases,new_cases,total_deaths,population 
FROM dbo.CovidDeath
ORDER BY location,date

--Total cases vs Total deaths
SELECT location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage_Vs_Cases
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY location,date

-- Total cases vs Population
SELECT location,date, total_cases,population, (total_cases/population)*100 AS Infection_rate
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY location,date


-- Max Infection rate by countries
SELECT location,MAX(total_cases) AS InfectionCount,population, Max((total_cases/population))*100 AS Infection_rate
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

-- Countries with the highest death count
SELECT location,MAX(CAST(total_deaths AS int)) AS DeathCount,MAX(CAST(total_deaths AS int)/population) *100 AS DeathPercentageVSpopulation
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 DESC

-- Continent with the highest death count
SELECT continent,MAX(CAST(total_deaths AS int)) AS DeathCount
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--World Numbers
SELECT date,SUM(new_cases) AS InfectionCount, SUM(CAST(new_deaths AS int)) AS death_count, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageByCases
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY date

-- Total death vs Cases
SELECT SUM(new_cases) AS InfectionCount, SUM(CAST(new_deaths AS int)) AS death_count, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageByCases
FROM dbo.CovidDeath
WHERE continent IS NOT NULL


---- Vacination----

SELECT * FROM CovidVaccination

-- Join the Death and Vacination tables

SELECT * FROM CovidDeath CD
JOIN CovidVaccination CV
ON CD.location = CV.location
AND CD.date = CV.date

-- Total Population VS Vacination

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
FROM CovidDeath CD
JOIN CovidVaccination CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
AND CV.new_vaccinations IS NOT NULL
ORDER BY 1,2,3

-- Total Population VS Vacination (With Rolling vacination)
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CV.date )
AS Rolling_Vac_Nbr
FROM CovidDeath CD
	JOIN CovidVaccination CV
	ON CD.location = CV.location
	AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL 
		AND CV.new_vaccinations IS NOT NULL
		ORDER BY 1,2,3



-- Percentage of people vaccinated (CTE)

WITH PopvsVac (continent,location,date,population,new_vaccinations,Rolling_Vac_Nbr)
AS
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CV.date )
AS Rolling_Vac_Nbr
FROM CovidDeath CD
	JOIN CovidVaccination CV
	ON CD.location = CV.location
	AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL 
		AND CV.new_vaccinations IS NOT NULL
		--ORDER BY 1,2,3
)
SELECT *, (Rolling_Vac_Nbr/population)*100 AS VacPercentage 
FROM PopvsVac
ORDER BY 1,2,3


-- Percentage of people vaccinated (Temp Table)
DROP TABLE IF EXISTS PercentPeopleVaccinated
CREATE TABLE PercentPeopleVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
Rolling_Vac_Nbr NUMERIC
)

INSERT INTO PercentPeopleVaccinated
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CV.date )
AS Rolling_Vac_Nbr
FROM CovidDeath CD
	JOIN CovidVaccination CV
	ON CD.location = CV.location
	AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL 
		AND CV.new_vaccinations IS NOT NULL

SELECT *, (Rolling_Vac_Nbr/population)*100 AS VacPercentage 
FROM PercentPeopleVaccinated
ORDER BY 1,2,3


-- Creating view to store DATA for later vizualisation

CREATE VIEW PercentPoPVaccinated AS
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CV.date )
AS Rolling_Vac_Nbr
FROM CovidDeath CD
	JOIN CovidVaccination CV
	ON CD.location = CV.location
	AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL 
		AND CV.new_vaccinations IS NOT NULL