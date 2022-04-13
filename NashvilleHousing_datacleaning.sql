--Cleaning housing data using SQL queries

--Looking at dataset before cleaning
SELECT *
FROM PortfolioProject.dbo.nashville_housing

--Converting Date Format
SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

Update nashville_housing
SET SaleDateConverted = CONVERT(date, SaleDate)


--Inserting Property Address for NULL Addresses when another row with matching ParcelID has Property Address
SELECT *
FROM PortfolioProject.dbo.nashville_housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.nashville_housing a 
JOIN PortfolioProject.dbo.nashville_housing b 
    on a.ParcelID = b.ParcelID
    and a.uniqueID <> b.uniqueID 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.nashville_housing a 
JOIN PortfolioProject.dbo.nashville_housing b 
    on a.ParcelID = b.ParcelID
    and a.uniqueID <> b.uniqueID 


--Separating Property Address into Columns (Address and City)
--USING SUBSTRING
SELECT PropertyAddress
FROM PortfolioProject.dbo.nashville_housing

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1)) Address,
TRIM(SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress))) AS City
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1))

ALTER TABLE nashville_housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress)))



--Separating Owner Address into columns (Address,City,State)
--USING PARSENAME
SELECT OwnerAddress
FROM PortfolioProject.dbo.nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



--Changing Y and N to Yes and No in SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM PortfolioProject.dbo.nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = 
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END


--Removing Duplicates
WITH RowNumCTE AS
(
SELECT *,
    ROW_NUMBER() OVER 
        (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
         ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.nashville_housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Deleting old columns that were converted into new columns
ALTER TABLE PortfolioProject.dbo.nashville_housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.nashville_housing
DROP COLUMN SaleDate


--Looking at data after cleaning
SELECT *
FROM PortfolioProject.dbo.nashville_housing