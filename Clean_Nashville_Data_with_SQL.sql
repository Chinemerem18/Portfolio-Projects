-- CLEANING DATA WITH SQL
SELECT *
FROM PortfolioProjects.dbo.Nashville;

-- NORMALISE SALE DATE
ALTER TABLE Nashville
ADD SalesDate DATE;

UPDATE Nashville
SET SalesDate = CONVERT(DATE, SaleDate);

-- IMPUTE MISSING PROPERTY ADDRESS WITH PARCELID
SELECT alpha.ParcelID, 
alpha.PropertyAddress, 
beta.ParcelID, 
beta.PropertyAddress
FROM PortfolioProjects.dbo.Nashville AS alpha
JOIN PortfolioProjects.dbo.Nashville AS beta
	ON alpha.ParcelID = beta.ParcelID
	AND alpha.[UniqueID ] <> beta.[UniqueID ]
WHERE alpha.PropertyAddress IS NULL ;

UPDATE alpha
SET alpha.PropertyAddress = ISNULL(alpha.PropertyAddress, beta.PropertyAddress)
FROM PortfolioProjects.dbo.Nashville AS alpha
JOIN PortfolioProjects.dbo.Nashville AS beta
	ON alpha.ParcelID = beta.ParcelID
	AND alpha.[UniqueID ] <> beta.[UniqueID ]
WHERE alpha.PropertyAddress IS NULL ;

-- SEPARATE PROPERTY ADDRESS INTO COLUMNS USING SUBSTRING
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM PortfolioProjects.dbo.Nashville;

ALTER TABLE Nashville
ADD PropAddress NVARCHAR(255);

UPDATE Nashville
SET PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville
ADD PropCity NVARCHAR(255);

UPDATE Nashville
SET PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- SEPARATE OWNER ADDRESS INTO COLUMNS USING PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProjectS.dbo.Nashville;

ALTER TABLE Nashville
ADD OwnAddress NVARCHAR(255);

UPDATE Nashville
SET OwnAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Nashville
ADD OwnCity NVARCHAR(255);

UPDATE Nashville
SET OwnCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


ALTER TABLE Nashville
ADD OwnState NVARCHAR(255);

UPDATE Nashville
SET OwnState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- CONVERT Y AND N TO YES AND NO IN SOLD_AS_VACANT COLUMN
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.Nashville
GROUP BY SoldAsVacant;

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjects.dbo.Nashville;

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- REMOVE DUPLICATES

-- Find Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjects.dbo.Nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Delete Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjects.dbo.Nashville
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

-- DELETE UNNECESSARY/UNUSED COLUMNS
ALTER TABLE Nashville
DROP COLUMN OwnerAddress, 
TaxDistrict, 
PropertyAddress, 
SaleDate;

-- FINAL DATA CHECK
SELECT TOP(1000) *
FROM PortfolioProjects.dbo.Nashville;
