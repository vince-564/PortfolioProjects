select *
from Portofolio..Covid_Deaths
where continent is not null
order by 3,4
;

select *
from Portofolio..Covid_Vaccinations
order by 3,4
;

-- Select data that we going to be using

Select location, date_entered, total_cases, new_cases, total_deaths, population
From Portofolio..Covid_Deaths
order by 1, 2;

 
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date_entered, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
From Portofolio..Covid_Deaths
where location like '%states%'
order by 1, 2;
;


-- Looking at Total Cases  vs Population
-- Shows what percentage of population got covid

Select location, date_entered, population, total_cases, (total_cases/population)*100 as cases_percentage
From Portofolio..Covid_Deaths
where location like '%states%'
order by cases_percentage ASC
;

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionControl, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portofolio..Covid_Deaths
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected DESC
;


-- Looking at countries with highest death rate

Select location, cast(MAX(total_deaths) as INT) as TotalDeathCount
From Portofolio..Covid_Deaths
where continent is not null
-- where location like '%states%'
group by location
order by TotalDeathCount DESC
;

-- Lets break things down by location

Select location, max(cast(total_deaths as INT)) as TotalDeathCount
From Portofolio..Covid_Deaths
-- where location like '%states%'
where continent is null and location NOT IN ('upper middle income', 'lower middle income', 'high income', 'low income')
group by location
order by TotalDeathCount DESC
;

-- Lets break things down by continent

Select continent, max(cast(total_deaths as INT)) as TotalDeathCount
From Portofolio..Covid_Deaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC
;

--  Global Numbers

Select date_entered, sum(new_cases) AS Total_Cases, sum(cast(new_deaths as INT)) AS Total_Deaths, sum(cast(new_deaths AS INT))/sum(new_cases) * 100 AS death_percentage
From Portofolio..Covid_Deaths
-- where location like '%states%'
where continent is not null
group by date_entered
order by 1, 2
;

--  Total Global Numbers

Select sum(new_cases) AS Total_Cases, sum(cast(new_deaths as INT)) AS Total_Deaths, sum(cast(new_deaths AS INT))/sum(new_cases) * 100 AS death_percentage
From Portofolio..Covid_Deaths
-- where location like '%states%'
where continent is not null
-- group by date_entered
order by 1, 2
;

-- Looking at total population vs total vaccinations

Select cd.continent, cd.location, cd.date_entered, CD.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS BIGINT)) OVER (partition by cd.location order by cd.location, cd.date_entered) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portofolio..Covid_Deaths AS CD
JOIN Portofolio..Covid_Vaccinations AS CV
	ON CD.location = CV.location
	AND cd.date_entered = CV.date_entered
where cd.continent is not null
order by 2,3
;

-- Use CTE

With PopvsVac (Continent, Location, Date_Entered, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date_entered, CD.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS BIGINT)) OVER (partition by cd.location order by cd.location, cd.date_entered) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portofolio..Covid_Deaths AS CD
JOIN Portofolio..Covid_Vaccinations AS CV
	ON CD.location = CV.location
	AND cd.date_entered = CV.date_entered
where cd.continent is not null
-- order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date_entered, CD.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS BIGINT)) OVER (partition by cd.location order by cd.location, cd.date_entered) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portofolio..Covid_Deaths AS CD
JOIN Portofolio..Covid_Vaccinations AS CV
	ON CD.location = CV.location
	AND cd.date_entered = CV.date_entered
-- where cd.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated;


CREATE VIEW PercentPopulationVaccinated AS
Select cd.continent, cd.location, cd.date_entered, CD.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations AS BIGINT)) OVER (partition by cd.location order by cd.location, cd.date_entered) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portofolio..Covid_Deaths AS CD
JOIN Portofolio..Covid_Vaccinations AS CV
	ON CD.location = CV.location
	AND cd.date_entered = CV.date_entered
where cd.continent is not null
-- order by 2, 3

select * 
from PercentPopulationVaccinated