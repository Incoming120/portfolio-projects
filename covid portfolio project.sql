SELECT *
From portfolioProject..CovidDeaths
order by 3,4


--SELECT *
--From portfolioProject..CovidVaccinations
--order by 3,4

--select data we are going to using

select location, date, total_cases, total_deaths, population
from portfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths
--showing likehood of dying if you contact covid in your country

select location, date total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
from portfolioProject..CovidDeaths
where location  like '%nigeria%'
order by 1,2 desc

--looking at total cases vs population
--shows what percentange of population got covid

select location, date, population, total_cases, (total_cases/population) * 100 as DeathPercentage 
from portfolioProject..CovidDeaths
where location  like '%nigeria%'
order by 1,2 desc

--showing country with highest inefection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
from portfolioProject..CovidDeaths
--where location  like '%nigeria%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with Highest Death Count per population
select location, MAX(total_deaths) as TotalDeathCount
from portfolioProject..CovidDeaths
Group by location, population
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_Death, sum(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from portfolioProject..CovidDeaths
--where location  like '%nigeria%'
where continent is not null
--group by date 
order by 1,2 


--looking at Total_population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingpPeopleVaccinations
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with popvsvac (continent, location, Date, population,new_Vaccinations, RollingpPeopleVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date)as RollingpPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpPeopleVaccinations/population) * 100
from popvsvac

-- TEMP TABLE
DROP Table if exists #percentpopulationVaccinated
create Table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date)as RollingpPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationVaccinated

--create a view to store data for later visualizations
create view percentpopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date)as RollingpPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
