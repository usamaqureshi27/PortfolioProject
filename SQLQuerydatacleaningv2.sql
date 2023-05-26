/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing


------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- One  Way

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Another Way

ALTER TABLE NashvilleHousing
Add SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)

SELECT SaleDate2
FROM NashvilleHousing


-------------------------------------------------------------------------------------------------

-- Populate Property Address Data 

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is Null
ORDER BY ParcelID

-- Data shows if two rows have same ParcelID, the Address will also be same

SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

-- Updating the main table

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Column (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

-- Separare the column with the deliminator ','
-- Property Address

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' ,  PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',' ,  PropertyAddress)+1 , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

-- Updating the main table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,  PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' ,  PropertyAddress)+1, LEN(PropertyAddress))


-- Owner Address

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

-- Separarte Address, City and State with Parename method

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.') , 3) AS Address,
PARSENAME (REPLACE(OwnerAddress, ',','.') , 2) AS Address,
PARSENAME (REPLACE(OwnerAddress, ',','.') , 1) AS Address
FROM NashvilleHousing

-- Updating the main table

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.') , 1)


------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

-- Updating the main table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


------------------------------------------------------------------------------------------------

--Remove Duplicates

SELECT *
, ROW_NUMBER() OVER (PARTITION BY ParcelID , PropertyAddress, SalePrice, SaleDate, LegalReference 
					 ORDER BY UniqueID) row_num
FROM NashvilleHousing
--WHERE row_num > 1

-- Updating the main table With CTE

WITH RowNumCTE AS
(
SELECT *
, ROW_NUMBER() OVER (PARTITION BY ParcelID , PropertyAddress, SalePrice, SaleDate, LegalReference 
					 ORDER BY UniqueID) row_num
FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE
FROM RowNumCTE
WHERE row_num > 1


------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, PropertyCityAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate