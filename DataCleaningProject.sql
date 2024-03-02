select * from PortfolioProject.dbo.HousingData;

select SaleDate from PortfolioProject.dbo.HousingData;

-- To convert date from date format to datetime format and add a new column to populate the converted date values

select SaleDate,convert(datetime,SaleDate) as DateNtime
from PortfolioProject.dbo.HousingData;

Alter table PortfolioProject.dbo.HousingData
Add SaleDateTime datetime;

Update PortfolioProject.dbo.HousingData
set SaleDateTime = convert(datetime,SaleDate);

-- Populate actual values in place of null values present in the field PropertyAddress

select * from PortfolioProject.dbo.HousingData
where PropertyAddress is null;

-- Assuming the Parcel ID should be uniquely mapped to Property address, we are going to use Parcel ID as a reference point to populate PropertyAddress wherever it is missing

select * from PortfolioProject.dbo.HousingData
order by ParcelID;

-- Using self join

select set1.ParcelID,set1.PropertyAddress,set2.ParcelID,set2.PropertyAddress,ISNULL(set1.PropertyAddress,set2.PropertyAddress)
from PortfolioProject.dbo.HousingData set1
join PortfolioProject.dbo.HousingData set2
	on set1.ParcelID = set2.ParcelID
	and set1.UniqueID <> set2.UniqueID
where set1.PropertyAddress is null;

Update set1
set PropertyAddress = ISNULL(set1.PropertyAddress,set2.PropertyAddress)
from PortfolioProject.dbo.HousingData set1
join PortfolioProject.dbo.HousingData set2
	on set1.ParcelID = set2.ParcelID
	and set1.UniqueID <> set2.UniqueID
where set1.PropertyAddress is null;


-- Splitting address into separate fields for address and city: Using sunstring and charindex

select PropertyAddress from PortfolioProject.dbo.HousingData;

select 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)) as Adress,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),len(PropertyAddress)) as City
from PortfolioProject.dbo.HousingData;


Alter table PortfolioProject.dbo.HousingData
Add PropertyAddressSplit nvarchar(255);

Alter table PortfolioProject.dbo.HousingData
Add PropertyCitySplit nvarchar(255);

Update PortfolioProject.dbo.HousingData
set PropertyAddressSplit = SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1));

Update PortfolioProject.dbo.HousingData
set PropertyCitySplit= SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),len(PropertyAddress));


-- Splitting address into separate fields for address, city and state: Using parsename

select OwnerAddress from PortfolioProject.dbo.HousingData;


select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from PortfolioProject.dbo.HousingData;


Alter table PortfolioProject.dbo.HousingData
Add OwnerAddressSplit nvarchar(255);

Alter table PortfolioProject.dbo.HousingData
Add OwnerCitySplit nvarchar(255);

Alter table PortfolioProject.dbo.HousingData
Add OwnerStateSplit nvarchar(255);

Update PortfolioProject.dbo.HousingData
set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

Update PortfolioProject.dbo.HousingData
set OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

Update PortfolioProject.dbo.HousingData
set OwnerStateSplit= PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-- Change 0 & 1 in SoldAsVacant field to Yes and No

select DISTINCT SoldAsVacant from PortfolioProject.dbo.HousingData;

Select CONVERT(varchar, SoldAsVacant) as SoldAsVacant2
FROM PortfolioProject.dbo.HousingData;

Alter table PortfolioProject.dbo.HousingData
Add SoldAsVacant2 nvarchar(255);

Update PortfolioProject.dbo.HousingData
set SoldAsVacant2 = IIF(SoldAsVacant =0,'No','Yes');

-- Remove Duplicates using CTE
-- Assuming that if everything else barring unique ID is the same for more than 1 row, then there are duplicate values


-- To identify the duplicates
select *,
	ROW_NUMBER() OVER (
	PARTITION BY
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	Order by UniqueID) as row_num
from PortfolioProject.dbo.HousingData
order by ParcelID

-- To delete the duplicates

WITH RowNumCTE As(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	Order by UniqueID) as row_num
from PortfolioProject.dbo.HousingData
)
Delete from RowNumCTE
where row_num >1;


-- Delete unused columns in the table
Alter Table PortfolioProject.dbo.HousingData
Drop column PropertyAddress,OwnerAddress;