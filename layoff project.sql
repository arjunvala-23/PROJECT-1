
select * from world_layoffs.layoffs ;

-- Remove duplicates 
-- standarize it 
-- null values 
-- remove outliers 

create table layoffs_staging like layoffs;
insert layoffs_staging 
select * from layoffs ;

select * from layoffs_staging ;

select * ,
row_number()
 over (PARTITION BY company,industry,total_laid_off,percentage_laid_off,'date') as row_num
from layoffs_staging ;

with duplicate_cte as
( select * ,
row_number()
 over (PARTITION BY company,location,stage,country,funds_raised_millions,industry,total_laid_off,percentage_laid_off,'date') as row_num
from layoffs_staging )
select * from duplicate_cte 
where row_num > 1 ;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2 
select * ,
row_number()
 over (PARTITION BY company,location,stage,country,funds_raised_millions,industry,total_laid_off,percentage_laid_off,'date') as row_num
from layoffs_staging ;

delete 
from layoffs_staging2
where row_num > 1 ;

SET SQL_SAFE_UPDATES = 0;
Delete from layoffs_staging2 where row_num > 1;

select * from layoffs_staging2  ;

-- standarizing data 

select company , trim(company) from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry from layoffs_staging2 ;

select * from layoffs_staging2 where industry like "crypto%" ;

update layoffs_staging2 
set industry = 'crypto'
where industry like 'crypto%';

select distinct country , trim(trailing  '.' from country ) from layoffs_staging2;

update layoffs_staging2 
set country = 'united states'
where country like 'uniteted states%';

select * from layoffs_staging2;

select `date` ,
STR_TO_DATE(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2 
set `date` = STR_TO_DATE(`date`,'%m/%d/%Y') ;

alter table layoffs_staging2
modify column `date` DATE;

select t1.industry , t2.industry from layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company = t2.company 
where (t1.industry is null or t1.industry like '')
and t2.industry is not null ;

update layoffs_staging2 
set industry = null 
where industry = '';

select industry is null from layoffs_staging2;

update layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company = t2.company 
set t1.industry = t2.industry 
where t1.industry is null 
and t2.industry is not null ;

select * from layoffs_staging2 where company = 'airbnb';

select * from layoffs_staging2 where percentage_laid_off is null and total_laid_off is null ;

delete from layoffs_staging2 where percentage_laid_off is null and total_laid_off is null ;

delete from layoffs_staging2 where industry is null ;