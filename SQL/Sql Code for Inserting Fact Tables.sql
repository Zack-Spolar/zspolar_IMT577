USE IMT577_DB_ZACK_SPOLAR

CREATE OR REPLACE TABLE Fact_ProductSalesTarget(
DimProductID INT FOREIGN KEY REFERENCES Dim_Product(DimProductID),
DimTargetDateID Number(9,0) FOREIGN KEY REFERENCES Dim_Date(Date_PKey),
ProductTargetSalesQuantity Number(38,0)
);

CREATE OR REPLACE TABLE Fact_SRCSalesTarget(
DimStoreID Number(38,0) FOREIGN KEY REFERENCES Dim_Store(DimStoreID),
DimResellerID Number(38,0) FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID),
DimChannelID Number(38,0) FOREIGN KEY REFERENCES Dim_Channel(DimChannelID),
DimTargetDateID Number(9,0) FOREIGN KEY REFERENCES Dim_Date(Date_PKey),
SalesTargetAmount Number (38,0)
);



CREATE OR REPLACE TABLE Fact_SalesActual(
DimProductID INT FOREIGN KEY REFERENCES Dim_Product(DimProductID),
DimStoreID Number(38,0) FOREIGN KEY REFERENCES Dim_Store(DimStoreID),
DimResellerID Number(38,0) FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID),
DimCustomerID Number(38,0) FOREIGN KEY REFERENCES Dim_Customer(DimCustomerID),
DimChannelID Number(38,0) FOREIGN KEY REFERENCES Dim_Channel(DimChannelID),
DimSalesDateID Number(9,0) FOREIGN KEY REFERENCES Dim_Date(Date_PKey),
DimLocationID Number(38,0) FOREIGN KEY REFERENCES Dim_Location(DimLocationID),
SalesHeaderID INT,
SalesDetailID INT,
SaleAmount Decimal(10,2),
SaleQuantity INT,
SaleUnitPrice Decimal(8,2),
SaleExtendedCost Decimal(8,2),
SaleTotalProfit Decimal(8,2)




--INSERT STATEMENTS Fact_ProductSalesTarget

INSERT INTO Fact_ProductSalesTarget(
DimProductID,
DimTargetDateID,
ProductTargetSalesQuantity)


SELECT DISTINCT DimProductID, Date_PKey, SalesQuantityTarget
FROM TargetDataProduct DP
    INNER JOIN Dim_Product AS P ON DP.ProductID = P.ProductID
    LEFT OUTER JOIN Dim_Date AS D ON DP.Year = D.Year


--INSERT STATEMENT Fact_SRCSalesTarget

INSERT INTO Fact_SRCSalesTarget(
DimStoreID,
DimResellerID,
DimChannelID,
DimTargetDateID,
SalesTargetAmount
)


SELECT DISTINCT IFNULL(S.DimStoreID, '-1'),
IFNULL(R.DimResellerID, '-1'), 
IFNULL(C.DimChannelID, '-1'),
IFNULL(D.Date_PKey, '-1'), 
IFNULL(DC.TargetSalesAmount, '-1')
FROM TargetDataChannel DC
LEFT JOIN Dim_Store AS S 
ON CASE
WHEN DC.TargetName = 'Store Number 5' THEN CAST('5' AS INT)
WHEN DC.TargetName = 'Store Number 8' THEN CAST('8' AS INT)
WHEN DC.TargetName = 'Store Number 10' THEN CAST('10' AS INT)
WHEN DC.TargetName = 'Store Number 10' THEN CAST('21' AS INT)
WHEN DC.TargetName = 'Store Number 10' THEN CAST('34' AS INT)
WHEN DC.TargetName = 'Store Number 10' THEN CAST('39' AS INT)
END = S.StoreNumber
LEFT JOIN Dim_Channel AS C 
ON CASE
WHEN DC.ChannelName = 'Online' THEN CAST('On-line'AS VARCHAR(255))
ELSE DC.ChannelName
END = C.ChannelName
LEFT JOIN Dim_Reseller AS R ON DC.TargetName = R.ResellerName
INNER JOIN Dim_Date AS D ON DC.Year = D.Year



--Insert Statement Fact_SalesActual

INSERT INTO Fact_SalesActual(
DimProductID,
DimStoreID,
DimResellerID,
DimCustomerID,
DimChannelID,
DimSalesDateID,
DimLocationID,
SalesHeaderID,
SalesDetailID,
SaleAmount,
SaleQuantity,
SaleUnitPrice,
SaleExtendedCost,
SaleTotalProfit
)

SELECT IFNULL(P.DimProductID, '-1'),
IFNULL(S.DimStoreID, '-1'),
IFNULL(R.DimResellerID, '-1'),
IFNULL(C.DimCustomerID, '-1'),
IFNULL(Ch.DimChannelID, '-1'),
IFNULL(D.Date_PKey, '-1'),
IFNULL(L.DimLocationID, '-1'),
SH.SalesHeaderID,--SalesHeader,SalesDetail
SD.SalesDetailID,--SalesDetail
SD.SalesAmount, -- SalesDetail
SD.SalesQuantity, --SalesDetail
P.ProductWholeSalePrice,-- Dim_Product
P.ProductCost, --Dim_Product
(SD.SalesAmount - P.ProductCost * SD.SalesQuantity) AS SaleTotalProfit -- SalesDetail, Dim_Product
FROM SalesHeader SH
LEFT JOIN Dim_Store AS S ON SH.StoreID = S.SourceStoreID
INNER JOIN SalesDetail AS SD ON SH.SalesHeaderID = SD.SalesHeaderID
LEFT JOIN Dim_Product AS P ON SD.ProductID = P.ProductID
Left JOIN Dim_Reseller AS R ON SH.ResellerID = R.ResellerID
LEFT JOIN Dim_Customer AS C ON SH.CustomerID = C.CustomerID
LEFT OUTER JOIN Dim_Channel AS Ch ON SH.ChannelID = Ch.ChannelID
LEFT JOIN Dim_Date AS D ON SH.Date = D.Date
JOIN Dim_Location AS L ON C.DimLocationID = L.DimLocationID OR R.DimLocationID = L.DimLocationID OR S.DimLocationID = L.DimLocationID