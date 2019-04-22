SELECT 
	WL.Facility
	,WL.Warehouse
	,P.ProductNo AS KMCode
	,CASE 
		WHEN I.QuantityOnHand IS NULL
			THEN NULL
		ELSE COALESCE(IVB.Quantity,I.QuantityOnHand)
		END AS QuantityAvailable
	,CASE 
		WHEN IVB.ID IS NULL
			THEN I.QuantityAllocated
		ELSE IVB.Quantity
		END AS QuantityInProcess
	,I.QuantityAllocated
	,P.DefaultUOMCode AS UomCode
	
FROM INVENTORY2 I
LEFT JOIN AT_INVENTORY2_BONDING IVB
	ON IVB.Inventory2ID = I.ID
	
JOIN PRODUCT P
	ON P.ID = I.ProductID
	
JOIN WAREHOUSE_LOCATION WL
	ON I.WarehouseLocationID = WL.ID