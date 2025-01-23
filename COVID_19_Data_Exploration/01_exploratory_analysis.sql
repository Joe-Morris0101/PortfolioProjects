-- Select the data that will be used

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project.Covid_Deaths
order by location, date;

-- Select all rows where total cases is not null
-- This only selects dates from the first reported case in each country

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project.Covid_Deaths
where total_cases is not null
order by location, date;

-- Total cases vs total deaths in UK
-- Shows likelihood of dying after contracting the virus in the UK

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project.Covid_Deaths
where location like '%kingdom%'
order by location, date;

-- Total cases vs population
-- Shows proportion of population that contracted covid

select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from portfolio_project.Covid_Deaths
order by location, date;