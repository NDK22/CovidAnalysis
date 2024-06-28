select * from CovidDB..coviddeaths$ order by 3,4


--select * from CovidDB..covidvaccinations$ order by 3,4

--select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDB..coviddeaths$
order by 1,2


-- Alter the column to make it float from navchar
ALTER TABLE CovidDB..coviddeaths$
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE CovidDB..coviddeaths$
ALTER COLUMN total_cases FLOAT;

ALTER TABLE CovidDB..covidvaccinations$
ALTER COLUMN new_vaccinations FLOAT;



-- Total Cases vs Total Deaths
-- Shows the Likelihoof of dying if you contract covid in your country
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
from CovidDB..coviddeaths$
where continent is not null
order by 1,2

-- Total Cases vs Population
-- shows what percentage of population got covid
select location, date, total_cases, population, round((total_cases/population)*100,2) as Percentage_of_population_infected
from CovidDB..coviddeaths$
where continent is not null
order by 1,2


-- Countries with highest infection rate
select location,population, Max(total_cases) as Highest_Infection_Count, round(Max(total_cases/population)*100,2) as Percentage_of_population_infected
from CovidDB..coviddeaths$
where continent is not null
group by location, population
order by Percentage_of_population_infected desc


-- Countries with the highest death count per population
select location, Max(total_deaths) as Total_Death
from CovidDB..coviddeaths$
where continent is not null
group by location
order by Total_Death desc

-- Continients with the highest death count per population
select continent, Max(total_deaths) as Total_Death
from CovidDB..coviddeaths$
where continent is not null
group by continent
order by Total_Death desc


-- GLobal Stats per day
select date, sum(total_cases) as Cases_Per_Day, sum(total_deaths) as Deaths_Per_Day, round( sum(total_deaths)/sum(total_cases)* 100,2) as Death_Percentage
from CovidDB..coviddeaths$
where continent is not null
group by date
order by 1,2 

-- GLobal stats till Date
select  sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, round( sum(new_deaths)/sum(new_cases)* 100,2) as Death_Percentage
from CovidDB..coviddeaths$
where continent is not null


--Total Population vs Vaccination
with population_vs_vaccination(continent, location, date,population,new_vaccinations,Total_Vaccinations) as (
select d.continent, d.location, d.date,d.population,v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Total_Vaccinations
from CovidDB..coviddeaths$ d
join CovidDB..covidvaccinations$ v on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *, Round((Total_Vaccinations/population)*100,2) as Percentage_of_people_Vaccinated from population_vs_vaccination order by location,date

--Temp Table

Drop Table if exists PercentPopulationVaccinated

create Table PercentPopulationVaccinated (
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
Total_Vaccinations numeric)


insert into PercentPopulationVaccinated
select d.continent, d.location, d.date,d.population,v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Total_Vaccinations
from CovidDB..coviddeaths$ d
join CovidDB..covidvaccinations$ v on d.location=v.location
and d.date=v.date
where d.continent is not null

select *, Round((Total_Vaccinations/population)*100,2) as Percentage_of_people_Vaccinated from PercentPopulationVaccinated order by location,date


--Creating View for visualization
Drop View if exists PercentPopulationFullyVaccinated 

CREATE VIEW PercentPopulationFullyVaccinated AS
SELECT 
    d.continent, 
    d.location, 
    d.date,
    d.population,
    v.new_vaccinations, 
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Total_Vaccinations
FROM 
    CovidDB..coviddeaths$ d
JOIN 
    CovidDB..covidvaccinations$ v 
    ON d.location = v.location
    AND d.date = v.date
WHERE 
    d.continent IS NOT NULL;
