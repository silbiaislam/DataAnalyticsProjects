Select * 
From DAProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From DAProject..CovidVaccination
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From DAProject..CovidDeaths

order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows how likely one might die in infected with covid in their country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DAProject..CovidDeaths
where location like '%India%'
order by 1,2


-- looking at Total Cases vs Population
-- shows what % of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From DAProject..CovidDeaths
--where location like '%India%'
order by 1,2

-- Looking at Countris with Highest Infection Rate comapred to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From DAProject..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

-- Looking at Countris with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From DAProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Breaking things down by Continent
-- change loation to continent if later face issues
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From DAProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS by Date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From DAProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- GLOBAL NUMBERS 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From DAProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinted
, 
From DAProject..CovidDeaths dea
Join DAProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinted
From DAProject..CovidDeaths dea
Join DAProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulatonVaccinated
Create Table #PercentPopulatonVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatonVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinted
From DAProject..CovidDeaths dea
Join DAProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulatonVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinted
From DAProject..CovidDeaths dea
Join DAProject..CovidVaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulatonVaccinated