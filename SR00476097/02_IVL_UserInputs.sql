SELECT 
	CAST(I.ID AS NVARCHAR(40)) + isnull(IVB.OrderNo, '0') AS Inventory2ID
	,ISNULL(IVB.ID, 0) AS BondingID
	,I.WarehouseLocationID
	,WL.Location
	,WL.Zone
	,WL.Warehouse
	,WL.Facility
	,P.ProductNo AS KMCode
	,P.ID AS ProductID
	,TTP.Medium AS Description
	,I.LotNo
	,I.SerialNo
	,PFD.ProductInventoryType
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
	,ParnterInformation.PartnerProductNo AS SupplierMaterialCode
	,OPa.PartnerNo AS SupplierNumber
	,TTOP.Medium AS SupplierName
	,IVB.OrderNo AS SalesOrderNumber
	,IVB.OrderType AS SalesOrderType
	,IVB.OrderLineNo AS SalesOrderLineNo
	,WC.WipOrderNo AS ProductionOrder
	,UCI.Attribute_ AS Position
	,CASE 
		WHEN Pa.PartnerNo <> 'KONE'
			THEN 1
		ELSE 0
		END AS Consignment 
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
OUTER APPLY (
	SELECT TOP 1 PartnerProductNo
	FROM ORDER_DETAIL PurchaseOrder
	WHERE OrderNo = IVB.ChildOrderNo
		AND OrderType = IVB.ChildOrderType
		AND OrderLineNo = IVB.ChildOrderLineNo
	) ParnterInformation
OUTER APPLY (
	SELECT TOP 1 ATWB.OrderNo
		,ATWB.OrderType
		,ATWB.OrderLineNo
		,ATWB.WipComponentID
		,WC.WipOrderNo
	FROM AT_WIPCOMP_BONDING ATWB
	JOIN WIP_COMPONENT WC
		ON ATWB.WipComponentID = WC.ID
	WHERE IVB.OrderNo = ATWB.OrderNo
		AND IVB.OrderType = ATWB.OrderType
		AND IVB.OrderLineNo = ATWB.OrderLineNo
		AND ISNULL(IVB.InternalObjectNumber, '') = ISNULL(ATWB.InternalObjectNumber, '')
	) WC
OUTER APPLY (
	SELECT TOP 1 P.PartnerNo
		,P.ID
		,P.TextID
	FROM ORDER_PARTNER OP
	LEFT JOIN PARTNER P
		ON OP.PartnerID = P.ID
	WHERE IVB.ChildOrderNo = OP.OrderNo
		AND IVB.ChildOrderType = OP.OrderType
		AND OP.PartnerRole = '3'
	) OPa
LEFT JOIN TEXT_TRANSLATION TTOP
	ON OPa.TextID = TTOP.TextID
		AND '1033' = TTOP.LanguageID
LEFT JOIN AT_PRODUCT_FACILITY_DETAILS PFD
	ON PFD.ProductID = I.ProductID
	AND PFD.Facility = WL.Facility
WHERE W.Facility IN ('KNEE','KNEX')
UNION ALL
SELECT '0' AS Inventory2ID
	,0 AS BondingID
	,CO.WarehouseLocationID
	,WLCO.Location
	,WLCO.Zone
	,WLCO.Warehouse
	,WLCO.Facility
	,'' AS KMCode
	,0 AS ProductID
	,'' AS Description
	,'' LotNo
	,'' SerialNo
	,NULL as ProductInventoryType 
	,TTCO.Medium AS InventoryStatusDescription
	,NULL as InventoryStatus
	,0 AS QuantityAvailable
	,0 AS QuantityInProcess
	,0 AS QuantityAllocated
	,'' AS UomCode
	,CO.Container
	,CO.InContainer
	,'' QuantityAllocatedCSS
	,'' AS SupplierMaterialCode
	,'' AS SupplierNumber
	,'' AS SupplierName
	,'' AS SalesOrderNumber
	,'' AS SalesOrderType
	,NULL AS SalesOrderLineNo
	,COALESCE(INV2ALL.WipOrderNo,'') AS ProductionOrder
	,'' AS Position
	,'' AS Consignment
	,CCO.NAME AS ContainerClass
	,CO.PermanentFlag AS ReusableFlag
FROM CONTAINER CO
JOIN WAREHOUSE_LOCATION WLCO
	ON CO.WarehouseLocationID = WLCO.ID
JOIN CONTAINER_CLASS CCO
	ON CO.ContainerClassID = CCO.ID
JOIN CONTAINER_STATUS CS
	ON CO.ContainerStatus = CS.ContainerStatus
JOIN TEXT_TRANSLATION TTCO
	ON CS.TextID = TTCO.TextID
		AND '1033' = TTCO.LanguageID
LEFT JOIN INVENTORY2_ALLOCATION INV2ALL
	ON CO.Container = INV2ALL.AllocationTag
WHERE NOT EXISTS (
		SELECT INV2.Container
		FROM INVENTORY2 INV2
		WHERE INV2.Container = CO.Container
		)
AND CO.Facility IN ('KNEE','KNEX')
