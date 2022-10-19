
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs total death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%'
and continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Populations
--Show what precentage of populations got Covid


SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPrecentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%'
ORDER BY 1,2

--Looking at Countries with Highest Rate Compared to Populations


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PrecentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Indonesia%'
GROUP BY location, population
ORDER BY PrecentPopulationInfected DESC

--Showing Countries with Highest Death Count per Populations
--On the Max Total Deaths, we need to cast data type into int
--"WHERE continent is not null" is the problem solving when there was a location that didnt show country.
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Indonesia%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THING DOWN BY CONTINENT


--Showing continents with the hihgest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Indonesia%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Indonesia%'
where continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total populations vs vaccinations
--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- BY 2, 3
)

Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 