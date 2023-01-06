SELECT * FROM dbo.CovidDeath
WHERE continent IS NOT NULL


--Query for visualisation--

-- Total death vs Cases

CREATE VIEW TotalDeathVSCases AS
SELECT SUM(new_cases) AS InfectionCount, SUM(CAST(new_deaths AS int)) AS death_count, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageByCases
FROM dbo.CovidDeath
WHERE continent IS NOT NULL

--Death by continent--
CREATE VIEW DeathbyContinent AS
SELECT location,MAX(CAST(total_deaths AS int)) AS DeathCount,MAX(CAST(total_deaths AS int)/population) *100 AS DeathPercentageVSpopulation
FROM dbo.CovidDeath
WHERE continent IS NULL 
AND location NOT IN ('European Union','High income','Upper middle income','World','Lower middle income','Low income','International')
GROUP BY location
--ORDER BY 3 DESC

-- Max Infection rate by countries
CREATE VIEW Infection_rate_coutries_Max AS
SELECT location,MAX(total_cases) AS InfectionCount,population, Max((total_cases/population))*100 AS Infection_rate
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location,population
--ORDER BY 4 DESC


-- Total cases vs Population
CREATE VIEW TotalCasesVSPop AS
SELECT location,date, population,MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) AS PopInfection_rate
FROM dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location,date, population
--ORDER BY location, date


-- Total Population VS Vacination (With Rolling vacination)
CREATE VIEW Rolling_Vaccination AS
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