-- Ordering all countries (and dates) by percent of population infected
-- Included for use in tableau project later

select location, population, date, max(total_cases) as peak_cases,  max((total_cases/population))*100 as percent_population_infected
from portfolio_project.Covid_Deaths
where population > 0
group by location, population, date
order by percent_population_infected desc;

-- Finding countries with highest infection rate compared to population

select location, population, max(total_cases) as peak_cases, (max(total_cases)/population)*100 as percentage_infected_at_peak
from portfolio_project.Covid_Deaths
where population > 0 and continent not like '' -- This filters out data for continents and only leaves records for countries
group by location, population
order by percentage_infected_at_peak desc;

-- Finding countries with highest death count

select location, max(total_deaths) as total_deaths 
from portfolio_project.Covid_Deaths
where continent not like ''
group by location
order by total_deaths desc;

-- Showing continents with the highest death count

select location, sum(new_deaths) as total_death_count
from portfolio_project.Covid_Deaths
where continent like '' -- This filters out countries and only leaves records for continents
and location not in ('World', 'European Union', 'International')
group by location
order by total_death_count desc;

-- Showing global totals and death rate

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from portfolio_project.Covid_Deaths
where continent not like '';

-- Showing new cases and deaths globally per day

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths
from portfolio_project.Covid_Deaths
where continent not like '' and total_cases is not null
group by date
order by date;