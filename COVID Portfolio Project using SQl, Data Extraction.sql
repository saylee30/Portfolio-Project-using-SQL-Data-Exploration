Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccination
--order by 3,4

Select location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Total cases vs Population
-- Shows what percentage of population gor Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2

-- Countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location,population
order by PercentPopulationInfected desc


--Countries with highest Death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location
order by TotalDeathCount desc


--looking by Continent
-- Continets with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2


--Total Population vs vaccination

Select *
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVaccination vac
	On dae.location = vac.location
	and dae.date = vac.date

Select dae.continent,dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dae.location)
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVaccination vac
	On dae.location = vac.location
	and dae.date = vac.date
--Where dae.continent is not null
Order by 2,3


Select dae.continent,dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
Over (Partition by dae.location Order by dae.location, dae.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVaccination vac
	On dae.location = vac.location
	and dae.date = vac.date
Where dae.continent is not null
Order by 2,3


--USE CET

With POPvsVac (continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dae.continent,dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
Over (Partition by dae.location Order by dae.location, dae.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVaccination vac
	On dae.location = vac.location
	and dae.date = vac.date
Where dae.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From POPvsVac


--Create view to store data for visualization

Create View PercentPopulationVaccinated as
Select dae.continent,dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
Over (Partition by dae.location Order by dae.location, dae.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVaccination vac
	On dae.location = vac.location
	and dae.date = vac.date
Where dae.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated