-- Finding a rolling vaccination rate for each country
-- This time with a temp table


-- Dropping the temp table if it exists
drop temporary table if exists RollingVax;

-- Creating the temp table
create temporary table RollingVax (
    continent varchar(255),
    location varchar(255),
    date datetime,
    population bigint,
    new_vaccinations int,
    rolling_people_vaccinated bigint
);

-- Inserting into the newly created temp table
insert into RollingVax
select dea.continent, dea.location, dea.date, dea.population, coalesce(nullif(vac.new_vaccinations, ''), 0), sum(coalesce(nullif(vac.new_vaccinations, ''), 0)) over (partition by dea.location order by dea.date)
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent not like '' and dea.population > 0;

-- Now calculating and showing rolling vaccination rates
select *, (rolling_people_vaccinated/population)*100 as rolling_vax_rate
from RollingVax
order by location;


-- Finding max (latest) vaccination rate for each country within a view


-- Dropping view if it already exists
drop view if exists MaxVaccinatedRateView;

-- Creating the view using a CTE
create view MaxVaccinatedRateView as
with PopvsVac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like '' and dea.population > 0
)
select location, population, max(rolling_people_vaccinated) as num_vaccinated, max((rolling_people_vaccinated/population)*100) as max_vax_rate
from PopvsVac
group by location, population;

-- Selecting all data from the created view
select *
from MaxVaccinatedRateView;