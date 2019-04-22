SELECT 
	ROW_NUMBER() OVER (ORDER BY P.ProductNo asc) as RowNo
	,WL.Facility
	,P.ProductNo AS KMCode
	,TTIS.Short AS InventoryStatus
	,CASE 
		WHEN count(I.QuantityOnHand) IS NULL
			THEN NULL
		ELSE sum(COALESCE(IVB.Quantity,I.QuantityOnHand))
		END AS QuantityAvailable
	,CASE 
		WHEN count(IVB.ID) IS NULL
			THEN sum(I.QuantityAllocated)
		ELSE sum(IVB.Quantity)
		END AS QuantityInProcess
	,sum(I.QuantityAllocated) AS QuantityAllocated
		,	
			ISNULL((
				CASE	
				WHEN count(I.QuantityOnHand) IS NULL
					THEN NULL
				ELSE sum(COALESCE(IVB.Quantity,I.QuantityOnHand))
				END
				),0)
			+
			ISNULL((
				CASE 
				WHEN count(IVB.ID) IS NULL
					THEN sum(I.QuantityAllocated)
				ELSE sum(IVB.Quantity)
				END
				) ,0)
			+
			ISNULL(sum(I.QuantityAllocated),0)

		as 'TotalQuantity'
	,P.DefaultUOMCode AS UomCode
	
FROM INVENTORY2 I
LEFT JOIN AT_INVENTORY2_BONDING IVB
	ON IVB.Inventory2ID = I.ID
	
JOIN PRODUCT P
	ON P.ID = I.ProductID
	
JOIN WAREHOUSE_LOCATION WL
	ON I.WarehouseLocationID = WL.ID
JOIN INVENTORY_STATUS ISt
	ON I.InventoryStatus = ISt.InventoryStatus
	
LEFT JOIN TEXT_TRANSLATION TTIS
	ON ISt.TextID = TTIS.TextID
		AND '1033' = TTIS.LanguageID

WHERE P.ProductNo = '4J6K1007P001'
GROUP BY WL.Facility, P.ProductNo, TTIS.Short, P.DefaultUOMCode
