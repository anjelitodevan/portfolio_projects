-- Standardize date format

SELECT SaleDate, CONVERT(DATE, SaleDate) 
FROM PortfolioProject.dbo.Housing;

ALTER TABLE Housing
ADD SaleDateConverted DATE;

UPDATE Housing
SET SaleDateConverted = CONVERT(DATE, SaleDate);	 

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.Housing;

-----------------------------------------------------------------------------------------------------

-- Populate property address data

SELECT PropertyAddress
FROM Housing
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-----------------------------------------------------------------------------------------------------

-- Breaking up property address into individual columns (address, city, state)

SELECT PropertyAddress
FROM Housing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Housing;

ALTER TABLE Housing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);	 

ALTER TABLE Housing
ADD PropertySplitCity NVARCHAR(255);
UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));	

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM Housing;

-----------------------------------------------------------------------------------------------------

-- Breaking up owner address into individual columns (address, city, state)

SELECT * FROM Housing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing;

ALTER TABLE Housing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);	 

ALTER TABLE Housing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);	 

ALTER TABLE Housing
ADD OwnerSplitState NVARCHAR(255);
UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM Housing;

-----------------------------------------------------------------------------------------------------

-- Clean soldasvacant column (Y and N to Yes and No)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2 DESC;

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing;

UPDATE Housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-----------------------------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE AS
(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
			) row_no
FROM Housing
)
SELECT *
FROM RowNumCTE
WHERE row_no > 1
ORDER BY PropertyAddress;


WITH RowNumCTE AS
(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
			) row_no
FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_no > 1;

-----------------------------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE Housing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate;

ALTER TABLE Housing
DROP COLUMN SaleDate;

SELECT * FROM Housing;