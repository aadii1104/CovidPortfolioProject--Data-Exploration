select * from PortfolioProject..CovidDeaths
order by 3,4

alter table CovidDeaths alter column total_cases float 

--select location,date,total_cases,total_deaths from CovidDeaths
--order by 1,2

--looking for Total cases vs Total deaths 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--looking at the Total cases vs Population 
--Shows what percentage of population got covid 

select location,date,population,total_cases,(total_cases/population)*100 as CovidAffectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

--Looking for Countries with Highest Infection Rate compared to population 
 
 select location,population,max(total_cases)as HighestInfectionCount,(max(total_cases)/population)*100 as CovidAffectedPercentage 
 from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by CovidAffectedPercentage desc

--Showing Countries with Highest Death Count per population 

select location ,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths where continent is not null
group by location 
order by TotalDeathCount desc

--Let's find out data by Continent 

--showing continents with highest death counts 

select continent ,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent 
order by TotalDeathCount desc

--Global numbers



select date,sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases<>0 and  new_deaths<>0
group by date 
order by 1,2

select sum(new_cases) as total_cases ,sum(new_deaths) as total_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases<>0 and  new_deaths<>0
--group by date 
order by 1,2


--Total population vs total vactination 

alter table PortfolioProject..CovidVactinations alter column new_vaccinations bigint 

select dea.continent, dea.location , dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as VactinationCount
--(VactinationCount/population)*100
from PortfolioProject..CovidVactinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location    
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

--use CTE

with popVSvac (continent,loaction,date,population,new_vacctinations,VactinationCount)
as
(
select dea.continent, dea.location , dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as VactinationCount
--(VactinationCount/population)*100
from PortfolioProject..CovidVactinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location    
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
select * ,(VactinationCount/population)*100 as VactinationPercentage
from popVSvac 


--TEMP Table 

drop table if exists #VactinatedPopulationPercent
create table #VactinatedPopulationPercent
(
continent nvarchar(250),
location nvarchar(250),
Date datetime,
Population numeric,
New_vacctinations numeric,
VactinationCount numeric
)
insert into #VactinatedPopulationPercent

select dea.continent, dea.location , dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as VactinationCount
--(VactinationCount/population)*100
from PortfolioProject..CovidVactinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location    
and dea.date = vac.date 
--where dea.continent is not null 
--order by 2,3

select * ,(VactinationCount/population)*100 as VactinationPercentage
from #VactinatedPopulationPercent 


--Creating view to store data for visualizations

create view VactinatedPopulationPercent as
select dea.continent, dea.location , dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as VactinationCount
--(VactinationCount/population)*100
from PortfolioProject..CovidVactinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location    
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

select * from VactinatedPopulationPercent