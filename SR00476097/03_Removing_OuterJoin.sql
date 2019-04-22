SELECT 
	I.WarehouseLocationID
	,WL.Location
	,WL.Zone
	,WL.Warehouse
	,WL.Facility
	,P.ProductNo AS KMCode
	,P.ID AS ProductID
	,TTP.Medium AS Description
	,I.LotNo
	,I.SerialNo
	,TTIS.Short AS InventoryStatusDescription
	,I.InventoryStatus
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
	,C.Container
	,C.InContainer
	,CASE 
		WHEN I.QuantityAllocated > 0
			THEN 'Select'
		ELSE NULL
		END AS QuantityAllocatedCSS
	
	,IVB.OrderNo AS SalesOrderNumber
	,IVB.OrderLineNo AS SalesOrderLineNo
	,CC.NAME AS ContainerClass
	,C.PermanentFlag AS ReusableFlag
	
FROM INVENTORY2 I

LEFT JOIN UNIT_CHARACTERISTIC UCI
	ON I.UnitID = UCI.UnitID
	AND 'K1X_ContainerPosition' = UCI.Characteristic
	
LEFT JOIN PARTNER Pa
	ON I.PartnerID= PA.ID
	
LEFT JOIN AT_INVENTORY2_BONDING IVB
	ON IVB.Inventory2ID = I.ID
	
JOIN PRODUCT P
	ON P.ID = I.ProductID
	
LEFT JOIN TEXT_TRANSLATION TTP
	ON P.TextID = TTP.TextID
		AND '1033' = TTP.LanguageID
		
JOIN WAREHOUSE_LOCATION WL
	ON I.WarehouseLocationID = WL.ID
	
JOIN WAREHOUSE W
	ON WL.Warehouse = W.Warehouse
JOIN CONTAINER C
	ON C.Container = I.Container
	
JOIN CONTAINER_CLASS CC
	ON C.ContainerClassID = CC.ID
	
JOIN INVENTORY_STATUS ISt
	ON I.InventoryStatus = ISt.InventoryStatus
	
LEFT JOIN TEXT_TRANSLATION TTIS
	ON ISt.TextID = TTIS.TextID
		AND '1033' = TTIS.LanguageID
