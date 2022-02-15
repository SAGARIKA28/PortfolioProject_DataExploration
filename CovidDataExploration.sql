/*DATA EXPLORATION*/
/*Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/
/* used data from 'OUR WORD IN DATA' website */
/*After cleaning data using 'MS-EXCEL',saved that file in .xlxs format,then imported it my 'MS-SQL SERVER' using inbuit data import feature*/
/* Name of tables:CovidDeaths,CovidVaccination*/

SET ANSI_WARNINGS OFF    /*It is used to avoid any any errors caused during aggrigate function(here,SUM) while it encounter a NULL value)*/
GO

/*select all data from both the tables order by column no 3(Location), 4(date);*/
select * from CovidDeaths  where continent is not null order by 3,4
select * from CovidVaccination where continent is not null order by 3,4

/*Setting up the required features*/  
select location,date,total_cases,new_cases,total_cases,population from CovidDeaths order by 1,2; 

/* Command to show total cases vs total death in India */

Select Location,Date,Continent,Population,Total_cases,Total_deaths,(Total_Deaths/Total_cases)*100 as DeathPercentage from CovidDeaths
where (total_deaths is not null and total_cases is not null) and location='India'   
order by 1,2;

/* Command to show total cases vs polpulation of India*/

Select Location,Date,Continent,Population,Total_cases,(Total_cases/Population)*100 as PopulationAffectedInPercentage from CovidDeaths
where (total_deaths is not null and total_cases is not null) and location='India'    /*TO  get accurate result im using where condition to avoid NULL values*/
order by 1,2;

/*country with highest rate of infection rate compared to population*/

select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population * 100))as populationpecentageInfected 
from CovidDeaths   
group by location,population
order by 1,2;

/*countries with the highest death count per poplulation*/

select location,max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths 
where continent is not null
--group by date
order by 1,2



--Table Join

select * from CovidDeaths dea join CovidVaccination vac on dea.location = vac.location and dea.date = vac.date ;

 
--Total population vs vaccination(Shows Percentage of Population that has recieved at least one Covid Vaccine)
  
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations
from CovidDeaths  dea 
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;



-- USE CTE
--(Using CTE to perform Calculation on Partition By in previous query)

With PopvsVac(Continent,location,Date,Population,new_vaccinations,RollingPeopleVaccinated) 
as(
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100)
from CovidDeaths  dea 
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Using Temp Table to perorm cacuation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopeVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100)
from CovidDeaths  dea 
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

select *,(RollingPeopeVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for ater visuaization

Create view PercentPopulationVaccinated as
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100)
from CovidDeaths  dea 
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

