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

-- Now the same but with daily deaths

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