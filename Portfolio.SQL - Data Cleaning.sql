-- Cleaning Data in SQL Queries

Select * From NashvilleHousing

-- Standardize Sale Date

Update NashvilleHousing 
Set SaleDate = convert(date,saledate);

Alter table nashvillehousing
Add SaleDateConverted Date; 

Update NashvilleHousing 
Set SaleDateConverted = convert(date,saledate);

Select saledateconverted, saledate
From NashvilleHousing;

-- Populate Property Address Data

Select *, PropertyAddress 
From NashvilleHousing
-- Where propertyaddress is null;
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null
;

Update a
set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
;

--Breaking out address into individual columns (address, city, state)

Select PropertyAddress 
From NashvilleHousing
-- Where propertyaddress is null
-- order by ParcelID;

SELECT 
SUBSTRING(Propertyaddress, 1, charindex(',',propertyaddress) -1) as Address
, SUBSTRING(Propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress)) as City
From NashvilleHousing
;

Alter table nashvillehousing
Add propertysplitaddress nvarchar(255); 

Update NashvilleHousing 
Set propertysplitaddress = SUBSTRING(Propertyaddress, 1, charindex(',',propertyaddress) -1)

Alter table nashvillehousing
Add propertysplitcity nvarchar(255); 

Update NashvilleHousing 
Set propertysplitcity = SUBSTRING(Propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress))

Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select
owneraddress 
,PARSENAME(replace(owneraddress, ',','.'),3)
 ,PARSENAME(replace(owneraddress, ',','.'),2)
  ,PARSENAME(replace(owneraddress, ',','.'),1)
From NashvilleHousing

Alter table nashvillehousing
Add ownersplitaddress nvarchar(255); 

Update NashvilleHousing 
Set ownersplitaddress = PARSENAME(replace(owneraddress, ',','.'),3)

Alter table nashvillehousing
Add ownersplitcity nvarchar(255); 

Update NashvilleHousing 
Set ownersplitcity = PARSENAME(replace(owneraddress, ',','.'),2)

Alter table nashvillehousing
Add ownersplitstate nvarchar(255); 

Update NashvilleHousing 
Set ownersplitstate = PARSENAME(replace(owneraddress, ',','.'),1)

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
from NashvilleHousing


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
from RowNumCTE

-- order by parcelid
)

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
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE NashvilleHousing
DROP COLUMN saledate
