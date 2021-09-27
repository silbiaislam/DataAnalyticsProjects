/*

Cleaning Data in SQL Queries 

*/

Select *
From DAProject.dbo.[NashvilleHousing ]

----------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, CONVERT(Date, SaleDate)
From DAProject.dbo.[NashvilleHousing ]

Update [NashvilleHousing ]
SET SaleDate = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------

--Populate Property Address data

Select *
From DAProject.dbo.[NashvilleHousing ]
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DAProject.dbo.[NashvilleHousing ] a
JOIN DAProject.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DAProject.dbo.[NashvilleHousing ] a
JOIN DAProject.dbo.[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------

--Breaking out address into Individual Columns(Address, City, State)

Select PropertyAddress
From DAProject.dbo.[NashvilleHousing ]
--Where PropertyAddress is null
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From DAProject.dbo.[NashvilleHousing ]

--Creating two new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [NashvilleHousing ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From DAProject.dbo.[NashvilleHousing ]

Select OwnerAddress
From DAProject.dbo.[NashvilleHousing ]

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DAProject.dbo.[NashvilleHousing ]

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From DAProject.dbo.[NashvilleHousing ]
-----------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DAProject.dbo.[NashvilleHousing ]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DAProject.dbo.[NashvilleHousing ]

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DAProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From DAProject.dbo.NashvilleHousing 
-------------------------------------------------------------------------------

--Deleting Unused Columns

Select *
From DAProject.dbo.NashvilleHousing


ALTER TABLE DAProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

------------------------------------------------------------------------------------