-- Creation of the Portfolio_Covid_Deaths table
DROP TABLE IF EXISTS Portfolio_Covid_Deaths;
CREATE TABLE Portfolio_Covid_Deaths (
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date TEXT,
    total_cases INT,
    new_cases INT,
    new_cases_smoothed INT,
    total_deaths INT,
    new_deaths INT,
    new_deaths_smoothed INT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients INT,
    icu_patients_per_million FLOAT,
    hosp_patients INT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions INT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions INT,
    weekly_hosp_admissions_per_million FLOAT,
    new_tests INT,
    total_tests INT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed INT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(255),
    total_vaccinations INT,
    people_vaccinated INT,
    people_fully_vaccinated INT,
    new_vaccinations INT,
    new_vaccinations_smoothed INT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million INT,
    stringency_index FLOAT,
    population INT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);

-- Load of the datafile
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.1/Data/budget/CovidDeaths.csv'
INTO TABLE Portfolio_Covid_Deaths
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Convert date2 as a DATETIME data type
alter table Portfolio_Covid_Deaths
add date2 datetime;

UPDATE Portfolio_Covid_Deaths
SET date2 = STR_TO_DATE(date, '%m/%d/%Y');

select *
from Portfolio_Covid_Deaths
where continent is not null
order by 3,4;

select *
from Portfolio_Covid_Deaths
order by 3,4
;

-- Select data that we going to be using

Select location, date2, total_cases, new_cases, total_deaths, population
From Portfolio_Covid_Deaths
order by 1, 2;

 
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date2, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
From Portfolio_Covid_Deaths
where location like '%states%'
order by 1, 2;
;


-- Looking at Total Cases  vs Population
-- Shows what percentage of population got covid

Select location, date2, population, total_cases, (total_cases/population)*100 as cases_percentage
From Portfolio_Covid_Deaths
where location like '%states%'
order by cases_percentage ASC
;

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionControl, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Covid_Deaths
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected DESC
;


-- Looking at countries with highest death rate

Select location, MAX(total_deaths) as TotalDeathCount
From Portfolio_Covid_Deaths
where continent is not null
-- where location like '%states%'
group by location
order by TotalDeathCount DESC
;

-- Lets break things down by location

Select location, MAX(total_deaths) as TotalDeathCount
From Portfolio_Covid_Deaths
where location like '%states%'
-- where continent is null and location NOT IN ('upper middle income', 'lower middle income', 'high income', 'low income')
group by location
order by TotalDeathCount DESC
;

-- Lets break things down by continent

Select continent, MAX(total_deaths) as TotalDeathCount
From Portfolio_Covid_Deaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC
;

--  Global Numbers

Select date2, sum(new_cases) AS Total_Cases, sum(new_deaths) AS Total_Deaths, sum(new_deaths)/sum(new_cases) * 100 AS death_percentage
From Portfolio_Covid_Deaths
-- where location like '%states%'
where continent is not null
group by date2
order by 1, 2
;

--  Total Global Numbers

Select sum(new_cases) AS Total_Cases, sum(new_deaths) AS Total_Deaths, sum(new_deaths)/sum(new_cases) * 100 AS death_percentage
From Portfolio_Covid_Deaths
-- where location like '%states%'
where continent is not null
-- group by date2
order by 1, 2
;

-- Looking at total population vs total vaccinations

Select cd.continent, cd.location, cd.date2, CD.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) OVER (partition by cd.location order by cd.location, cd.date2) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
From Portfolio_Covid_Deaths AS CD
JOIN Portfolio_Covid_Deaths AS CV
	ON CD.location = CV.location
	AND cd.date2 = CV.date2
where cd.continent is not null
order by 2,3
;

-- Use CTE

With PopvsVac (Continent, Location, date2, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date2, CD.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) OVER (partition by cd.location order by cd.location, cd.date2) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
From Portfolio_Covid_Deaths AS CD
JOIN Portfolio_Covid_Deaths AS CV
	ON CD.location = CV.location
	AND cd.date2 = CV.date2
where cd.continent is not null
order by New_Vaccinations desc, RollingPeopleVaccinated desc
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac;


-- Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert Into PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date2, CD.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) OVER (partition by cd.location order by cd.location, cd.date2) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
From Portfolio_Covid_Deaths AS CD
JOIN Portfolio_Covid_Deaths AS CV
	ON CD.location = CV.location
	AND cd.date2 = CV.date2
-- where cd.continent is not null
-- order by 2, 3
;

Select *, (RollingPeopleVaccinated/Population) * 100
From PercentPopulationVaccinated;

DROP VIEW IF EXISTS PercentPopulationVaccinated_2;
CREATE VIEW PercentPopulationVaccinated_2 AS
Select cd.continent, cd.location, cd.date2, CD.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) OVER (partition by cd.location order by cd.location, cd.date2) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
From Portfolio_Covid_Deaths AS CD
JOIN Portfolio_Covid_Deaths AS CV
	ON CD.location = CV.location
	AND cd.date2 = CV.date2
where cd.continent is not null
-- order by 2, 3
;

select * 
from PercentPopulationVaccinated_2;
