-- Total population vs total vaccinated for each country
-- SUM() with OVER(PARTITION BY) is used to calculate a rolling total of people vaccinated in each country

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like '';

-- Using a CTE to find a rolling vaccination rate for each country
-- The previous query is used here as the embedded 'as' query

with PopvsVac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like ''
)
select *, (rolling_people_vaccinated/population)*100 as rolling_vax_rate
from PopvsVac
where population > 0;

-- Using this CTE to create a view

drop view if exists PercentPopulationVaccinatedView;
create view PercentPopulationVaccinatedView as
with PopvsVac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like ''
)
select continent, location, date, population, new_vaccinations, rolling_people_vaccinated
from PopvsVac
where population > 0;