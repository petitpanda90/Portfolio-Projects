

-- Getting to know the DATA
SELECT*
FROM NashvilleHouses

-- Standardise the Sales date
	
ALTER TABLE NashvilleHouses
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM NashvilleHouses

-- Populate the Property address with "NULL"

SELECT a.[UniqueID ] ,a.ParcelID, a.PropertyAddress,b.[UniqueID ] ,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHouses a
JOIN NashvilleHouses b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHouses a
JOIN NashvilleHouses b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

SELECT *
FROM NashvilleHouses
WHERE PropertyAddress IS NULL

-- Breaking out the Property address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHouses

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS NewAddress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
ADD NewAddress VARCHAR(255)

UPDATE NashvilleHouses
SET NewAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHouses
ADD City VARCHAR(255)

UPDATE NashvilleHouses
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM NashvilleHouses

-- Breaking out the owner address into individual columns (Address, City, State)

SELECT OwnerAddress
FROM NashvilleHouses

SELECT
OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),2) --PARCE WIll look for '.' and split the string it's more flexible than the above method
FROM NashvilleHouses
ORDER BY 1 DESC

ALTER TABLE NashvilleHouses
ADD OwnerState VARCHAR(50)

UPDATE NashvilleHouses
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHouses
ADD OwnerCity VARCHAR(100)

UPDATE NashvilleHouses
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHouses
ADD OwnerAddress2 VARCHAR(255)

UPDATE NashvilleHouses
SET OwnerAddress2 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


SELECT *
FROM NashvilleHouses

-- Standardiez SoldAsVacant Column

SELECT DISTINCT(SoldAsVacant), LEN(SoldAsVacant) -- I wanted to the check the nbr of characters because sometimes you can find spaces
FROM NashvilleHouses
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant='Y' THEN  'YES'
	WHEN SoldAsVacant='N' THEN  'NO'
	ELSE SoldAsVacant
END 
FROM NashvilleHouses

UPDATE NashvilleHouses
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant='Y' THEN  'YES'
	WHEN SoldAsVacant='N' THEN  'NO'
	ELSE SoldAsVacant
END 


-- REMOVE DUPLICATE ---

SELECT *
FROM NashvilleHouses


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
					PARTITION BY 
					ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY ParcelID
					) RowNbr
FROM NashvilleHouses)

DELETE FROM RowNumCTE
WHERE RowNbr > 1


-- DELETING Columns ---

SELECT *
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
DROP COLUMN SaleDate