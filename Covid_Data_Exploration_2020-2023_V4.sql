/*
--COVID 19 DATA EXPLORATION 
--Data collected from https://ourworldindata.org/covid-deaths
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, Aliases

*/

--CHECKING UPLOADED TABLES
--After formatting on Excel, checking both tables have uploaded correctly 

SELECT *
FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidPortfolioProject..covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--EXPLORING DEATHS RELATIVE TO POPULATION

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..covid_deaths
ORDER BY 1,2 

--Total Cases vs Total Deaths (CAST function used to convert total_deaths column from nvarchar to numeric)
--This shows the likelihood of dying from Covid in your country. In this case, the United Kingdom has been selected

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS NUMERIC))/
CAST(total_cases AS NUMERIC)*100 as death_percentage
FROM CovidPortfolioProject..covid_deaths
WHERE location = 'United Kingdom' 
ORDER BY 1,2 


--Total Cases vs Population (CAST function used to convert total_cases column from nvarchar to numeric)
--Shows percentage of people who tested positive for Covid relative to population size (Continuing with the United Kingdom)

SELECT location, date, total_cases, population, (CAST(total_cases AS NUMERIC))/
CAST(population AS NUMERIC)*100 AS cases_percentage_population
FROM CovidPortfolioProject..covid_deaths
WHERE location = 'United Kingdom'
ORDER BY 1,2 


-- Looking at Countries with Highest Infection Rate compated to population (This needs to be explored further as results are showing %s based on cumulative cases since the start of the pandemic till 2023)

SELECT location, population, MAX(CAST(total_cases AS NUMERIC)) AS highest_infection_count, 
(MAX((CAST(total_cases AS NUMERIC)))/CAST(population AS NUMERIC))*100 AS cases_percentage_population
FROM CovidPortfolioProject..covid_deaths
GROUP BY Location, Population 
ORDER BY cases_percentage_population DESC


--Showing Countries with the Hihest Death Count per Population 

SELECT location, MAX(CAST(total_deaths AS NUMERIC)) AS Total_Death_Count
FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_Death_Count DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death counts

SELECT continent, MAX(cast(Total_deaths AS NUMERIC)) as Total_Death_Count
FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Sum_new_cases , SUM(CAST(total_deaths AS NUMERIC)) AS Total_Death_Count
FROM CovidPortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (Partition by dea.Location, dea.Date) AS Rolling_People_Vaccinated
 FROM CovidPortfolioProject..covid_deaths dea
 JOIN CovidPortfolioProject..covid_vaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as Rolling_People_Vaccinated
 FROM CovidPortfolioProject..covid_deaths dea
 JOIN CovidPortfolioProject..covid_vaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*, (Rolling_People_Vaccinated/population)*100 AS percentage_vaccinated
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_People_Vaccinated
 FROM CovidPortfolioProject..covid_deaths dea
 JOIN CovidPortfolioProject..covid_vaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100 AS Percentage_Vaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW 
PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..covid_deaths dea
 JOIN CovidPortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 


--WORK FILE

SELECT *
FROM PercentPopulationVaccinated
