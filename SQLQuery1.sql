Select *
From PortfolioProject..CovidDeaths
order by 3, 4 

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4 

--Select data that we are going to be using 

Select Location,date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2
---Looking at Total Cases vs Total deaths 
--showing likelihood of dying if you contract covid 
Select Location,date,total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%serbia%'
order by 1,2


--- Looking at total cases vs population 
--shows what percentage of populaction got covid 

Select Location,date,total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where Location like '%serbia%'
order by 1,2

-- looking at coutries with highest infection rate compared to Population 

Select Location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
GROUP BY Location,population
order by InfectedPercentage desc 

--showing counties with highest death count per population 


Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
GROUP BY Location,population
order by TotalDeathCount desc 

-- lets break thing down by continent 

---showing continent with highest death count 


Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
GROUP BY continent
order by TotalDeathCount desc 

---Global numbers

Select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group by date
order by 1,2

--Looking at total populations vs vaccination  JOIN 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date ) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CTE

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date ) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date ) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create View for later visualisation 

Create View PercentPopulationVaccinated2 as 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date ) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

