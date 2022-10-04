select * from PortfolioProject..covid_deaths$
order by 3,4

--select * from PortfolioProject..covid_vaccinaytions$
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..covid_deaths$
order by 1,2

--Total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths$
where location like '%India%'
order by 1,2

--Total cases vs Population
select location,date,total_cases,population,(total_cases/population)*100 as CasestoPop_Percentage
from PortfolioProject..covid_deaths$
where location like '%India%'
order by 1,2

--Country with highest infected rate compared to population

select location,MAX(total_cases) as HighestInfectd,population,MAX((total_cases/population))*100 as CasestoPop_Percentage
from PortfolioProject..covid_deaths$
group by location,population
order by CasestoPop_Percentage desc

select location,MAX(cast(total_deaths as int)) as DeathTotal,population 
from PortfolioProject..covid_deaths$
where continent is not null
group by location,population
order by DeathTotal desc 

select continent,MAX(CAST(total_deaths as int)) as TotalDeath
from PortfolioProject..covid_deaths$
where continent is not null
group by continent


select *
from PortfolioProject..covid_vaccinaytions$ vac
join PortfolioProject..covid_deaths$ dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 3,4

with PopvsVac (location,date,population,new_vaccinations,RollingPeoplevaccinated)
as(
select dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeoplevaccinated
from PortfolioProject..covid_deaths$ dea	
join PortfolioProject..covid_vaccinaytions$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.location like '%India%'
--order by 1,2
)
select * from PopvsVac



drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingPeoplevaccinated numeric)
Insert into #PercentPopulationVaccinated
select dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeoplevaccinated
from PortfolioProject..covid_deaths$ dea	
join PortfolioProject..covid_vaccinaytions$ vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null 
--order by 1,2
select * ,(RollingPeoplevaccinated/population)*100 from #PercentPopulationVaccinated




--creating view  for data visualizaton

drop View PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
select dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeoplevaccinated
from PortfolioProject..covid_deaths$ dea	
join PortfolioProject..covid_vaccinaytions$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 1,2
