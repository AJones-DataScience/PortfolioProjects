-- Assessing and cleaning Data from a housing database 

-- Confirm data has been uploaded

SELECT * FROM NashvilleHousing

-- Standardise SaleDate Column as it is currently DATETIME data type where time is not needed 

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

-- Populate Address Data

SELECT * FROM NashvilleHousing
WHERE PropertyAddress IS NULL 

SELECT * FROM NashvilleHousing
ORDER BY ParcelID;

-- I have identified that parcel ID matches with the property address therefore this could be used to fill out NULL rows

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvileHousing.dbo.NashvilleHousing a
JOIN NashvileHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvileHousing.dbo.NashvilleHousing a
JOIN NashvileHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

-- Spliting Address Into Indivdual Columns (Address, City, State)

SELECT PropertyAddress FROM NashvilleHousing

-- There is only one comma in the PropertyAddress fields so I can use SUBSTRING function to cut off at the comma delimiter to give the address without the city and then using same function giving the city

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, -- -1 removes the comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address -- + 1 removes the comma 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Remove original column now new seperated ones have been set up 

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress 

SELECT * FROM NashvilleHousing

-- Owner address also needs to be split, this also has state intitals so has two comma's in the string for this I can use PARSENAME function
-- I embedded a REPPLACE within the PARSENAME so PARASENAME only recognises periods not comma's

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvilleHousing

-- Remove original Owner address column as split columns have now been added

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress

-- Currently values in the SoldAsVacant are 1 and 0 to indicate yes or no to prevent confusion I will convert these into Yes or No 

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '0' THEN 'No'
	WHEN SoldAsVacant = '1' THEN 'Yes'
	END
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SoldVacant nvarchar(255);

UPDATE NashvilleHousing
SET SoldVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
	WHEN SoldAsVacant = '1' THEN 'Yes'
	END

ALTER TABLE NashvilleHousing
DROP COLUMN SoldAsVacant

-- Remove Duplicates 

WITH ROWCTE AS(
SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID,
	PropertyStreetAddress,
	PropertyCity,
	SalePrice,
	SaleDate,
	LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleHousing)

-- This query ran with the one above will show all rows that have duplicates
-- SELECT * FROM ROWCTE
-- WHERE row_num > 1

-- This deletes the duplicates they show with a row_num of 2 or above 
DELETE FROM ROWCTE
WHERE row_num > 1

-- The aim of cleaning this data is too make the data available much more accessable and usable for the process of analysing 
-- This table is now more functional and clear after these steps 