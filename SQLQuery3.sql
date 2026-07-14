USE Portfolio;
SELECT * FROM [Data Cleaning]

--Populate Property Address Data

SELECT *
 FROM [Data Cleaning]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning] a
JOIN [Data Cleaning] b
   ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning] a
JOIN [Data Cleaning] b
   ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, State, City)

SELECT PropertyAddress
 FROM [Data Cleaning]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX( ',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address

FROM [Data Cleaning]

ALTER TABLE [Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX( ',', PropertyAddress) -1)

ALTER TABLE [Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Data Cleaning]

ALTER TABLE [Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [Data Cleaning]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------------------------------------------------------------------------

---Change 0 and 1 to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
 FROM [Data Cleaning];
 GROUP BY (SoldAsVacant)
 ORDER BY 2

 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 0 THEN 'No'
      WHEN SoldAsVacant = 1 THEN 'Yes'
      END SoldAsVacantText
   FROM [Data Cleaning];

   ALTER TABLE [Data Cleaning]
   ADD SoldAsVacantText  VARCHAR(3);

UPDATE [Data Cleaning]
SET SoldAsVacantText =  
CASE WHEN SoldAsVacant = 0 THEN 'No'
     WHEN SoldAsVacant = 1 THEN 'Yes'
END;
  
ALTER TABLE [Data Cleaning]
DROP COLUMN SoldAsVacant;


-----------------------------------------------------------------------

---Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
              ORDER BY
                      UniqueID
                      ) AS row_num

FROM  [Data Cleaning]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

-------------------------------------------------------------------------

---Delete Unused Columns

SELECT *
 FROM [Data Cleaning]

 ALTER TABLE [Data Cleaning]
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate