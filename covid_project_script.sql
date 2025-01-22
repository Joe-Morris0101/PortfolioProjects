-- Select the data that will be used

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project.Covid_Deaths
order by 1, 2;

-- Total cases vs total deaths in UK
-- Shows likelihood of dying after contracting the virus in the UK

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project.Covid_Deaths
where location like '%kingdom%'
order by 1, 2;

-- Total cases vs population
-- Shows proportion of population that contracted covid

select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from portfolio_project.Covid_Deaths
order by 1, 2;

-- Ordering all countries (and dates) by percent of population infected
-- Included for use in tableau project later

select location, population, date, max(total_cases) as peak_cases,  max((total_cases/population))*100 as percent_population_infected
from portfolio_project.Covid_Deaths
group by 1, 2, 3
order by percent_population_infected desc;

-- Finding countries with highest infection rate compared to population

select location, population, max(total_cases) as peak_cases, (max(total_cases)/population)*100 as percentage_infected_at_peak
from portfolio_project.Covid_Deaths
group by 1, 2
order by 4 desc;

-- Finding countries with highest death count

select location, max(total_deaths)
from portfolio_project.Covid_Deaths
where continent not like ''
group by location
order by 2 desc;

-- Showing continents with the highest death count

select location, sum(new_deaths) as total_death_count
from portfolio_project.Covid_Deaths
where continent like ''
and location not in ('World', 'European Union', 'International')
group by location
order by 2 desc;

-- Showing global totals and death rate

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from portfolio_project.Covid_Deaths
where continent not like '' 
order by 1, 2;

-- Showing new cases and deaths globally per day

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from portfolio_project.Covid_Deaths
where continent not like ''
group by date
order by 1;

-- Total population vs total vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like '';

-- Using a CTE to find a rolling vaccination rate for each country

with PopvsVac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like ''
)
select *, (rolling_people_vaccinated/population)*100 as rolling_vax_rate
from PopvsVac;

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
where continent not like '';

-- Achieving the same result but this time with a temp table

drop temporary table if exists RollingVax;
create temporary table RollingVax (
    continent varchar(255),
    location varchar(255),
    date datetime,
    population bigint,
    new_vaccinations int,
    rolling_people_vaccinated bigint
);

insert into RollingVax
select dea.continent, dea.location, dea.date, dea.population, coalesce(nullif(vac.new_vaccinations, ''), 0), sum(coalesce(nullif(vac.new_vaccinations, ''), 0)) over (partition by dea.location order by dea.date)
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent not like '';

select *, (rolling_people_vaccinated/population)*100 as rolling_vax_rate
from RollingVax
order by location;

-- Finding max (latest) vaccination rate for each country within a view

drop view if exists MaxVaccinatedRateView;
create view MaxVaccinatedRateView as
with PopvsVac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolio_project.Covid_Deaths dea
join portfolio_project.Covid_Vaccinations vac
on dea.location  = vac.location and dea.date = vac.date
where dea.continent not like ''
)
select location, population, max(rolling_people_vaccinated) as num_vaccinated, max((rolling_people_vaccinated/population)*100) as max_vax_rate
from PopvsVac
group by 1,2;

select *
from MaxVaccinatedRateView;

-- Finding the date each country had the most daily cases using a CTE and row_number()

with RankedCases as (
    select location, new_cases as peak_daily_cases, date as peak_cases_date, row_number() over (partition by location order by new_cases desc, date asc) as rnk
    from portfolio_project.Covid_Deaths
    where continent not like ''
)
select location, peak_daily_cases, peak_cases_date
from RankedCases
where rnk = 1
order by peak_daily_cases desc;

-- Now the same but with deaths

with RankedDeaths as (
    select location, new_deaths as peak_daily_deaths, date as peak_deaths_date, row_number() over (partition by location order by new_deaths desc, date asc) as rnk
    from portfolio_project.Covid_Deaths
    where continent not like ''
)
select location, peak_daily_deaths, peak_deaths_date
from RankedDeaths
where rnk = 1
order by peak_daily_deaths desc;

-- Finally, joining the two

with RankedCases as (
    select location, new_cases as peak_daily_cases, date as peak_cases_date, row_number() over (partition by location order by new_cases desc, date asc) as rnk
    from portfolio_project.Covid_Deaths
    where continent not like ''
),
RankedDeaths as (
    select location, new_deaths as peak_daily_deaths, date as peak_deaths_date, row_number() over (partition by location order by new_deaths desc, date asc) as rnk
    from portfolio_project.Covid_Deaths
    where continent not like ''
)
select rc.location, rc.peak_daily_cases, rc.peak_cases_date, rd.peak_daily_deaths, rd.peak_deaths_date
from RankedCases rc
join RankedDeaths rd
on rc.location = rd.location
where rc.rnk = 1 and rd.rnk = 1
order by rc.peak_daily_cases desc;