-- Creation of the Portfolio_Covid_Deaths table
DROP TABLE IF EXISTS NashvilleHousing;
CREATE TABLE NashvilleHousing (
    UniqueID INT,
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(255),
    SalePrice DECIMAL(10, 2),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(3), -- Assuming Yes/No
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(5, 2),
    TaxDistrict VARCHAR(255),
    LandValue DECIMAL(10, 2),
    BuildingValue DECIMAL(10, 2),
    TotalValue DECIMAL(10, 2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.1/Data/budget/Nashville_Housing.csv'
INTO TABLE NashvilleHousing
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' -- Corrected the line termination character
IGNORE 1 ROWS;

-- Cleaning Data in SQL Queries

Select * From NashvilleHousing;

-- Standardize Sale Date

-- UPDATE NashvilleHousing
-- SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

Select * From NashvilleHousing;


Alter table nashvillehousing
Add Column SaleDateConverted datetime; 

Update NashvilleHousing 
Set SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');

Select saledateconverted, saledate
From NashvilleHousing;

-- Populate Property Address Data

Select *, PropertyAddress 
From NashvilleHousing
order by ParcelID
;

-- Check if any address data is missing

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID AS b_ParcelID, b.PropertyAddress AS b_PropertyAddress
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE a.PropertyAddress IS NULL
;

-- Breaking out address into individual columns (address, city, state)

Select PropertyAddress 
From NashvilleHousing;
-- Where propertyaddress is null
-- order by ParcelID;

SELECT 
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM NashvilleHousing;

Alter table nashvillehousing
Add propertysplitaddress VARCHAR(255);

UPDATE NashvilleHousing
SET propertysplitaddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1)
WHERE PropertyAddress LIKE '%,%';

Alter table nashvillehousing
Add propertysplitcity nvarchar(255); 

Update NashvilleHousing 
Set propertysplitcity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, length(propertyaddress));

Select *
From NashvilleHousing;

-- A second methond in breaking out address into individual columns (address, city, state)

Select OwnerAddress
From NashvilleHousing;

SELECT
  owneraddress,
  SUBSTRING_INDEX(owneraddress, ',', -1) AS State,
  SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -2), ',', 1) AS City,
  SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -3), ',', 1) AS Address
FROM
  NashvilleHousing;
  
-- A third methond in breaking out address into individual columns (address, city, state)

Alter table nashvillehousing
Add ownersplitaddress nvarchar(255); 

Update NashvilleHousing 
Set ownersplitaddress = substring_index(substring_index(owneraddress, ',', -3),',', 1);

Alter table nashvillehousing
Add ownersplitcity nvarchar(255); 

Update NashvilleHousing 
Set ownersplitcity = substring_index(substring_index(owneraddress, ',', -2),',', 1);

Alter table nashvillehousing
Add ownersplitstate nvarchar(255); 

Update NashvilleHousing 
Set ownersplitstate = substring_index(substring_index(owneraddress, ',', -1),',', 1);

select * from NashvilleHousing;


-- Change Y and N to Yes and No in 'Sold as Vacant' field


select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2
;


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing;


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
;


-- Remove Duplicates

With RowNumCTE AS(
select *
, ROW_NUMBER() Over (
  Partition By parcelid,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   ORDER BY 
					UniqueID
					) row_num
from NashvilleHousing
)
select * 
from RowNumCTE;

-- order by parcelid

With RowNumCTE AS(
select *
, ROW_NUMBER() Over (
  Partition By parcelid,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   ORDER BY 
					UniqueID
					) row_num
from NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
-- order by PropertyAddress
;



-- Delete Unused Columns

select * 
from NashvilleHousing
;

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

ALTER TABLE NashvilleHousing
DROP COLUMN saledate;
