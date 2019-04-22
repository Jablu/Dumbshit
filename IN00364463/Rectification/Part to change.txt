
SELECT DISTINCT
	WO.OrderNo AS OrderNo,	
	WOP.OprSequenceNo AS OprSequenceNo,
	WO.ProductionLineNo AS ProductionLine, 
	R.Name AS WorkStation,
	WO.ProductID AS ProductId,
	T.Medium,
	ISNULL(WO.ProjectCode,'N/A') AS Project,
	dbo.AF_GetUTCToLocal(RL.StartTime) AS StartTime,
	dbo.AF_GetUTCToLocal(RL.EndTime) AS FinishTime,
	CONVERT(decimal(10,2),ROUND(DATEDIFF(ss,RL.StartTime,RL.EndTime)/60.0,2)) AS Duration,
	--DATEDIFF(MINUTE,RL.StartTime,RL.EndTime) AS DurationMM,
	C.RecordNo DT_Template,
	C.RootCauseReasonCode AS ReasonCode,
	TRC.Medium AS ReasonCodeTR,
	TT.Extended ProblemDescription,
	TT2.Extended Solution,
	RL.LastUpdatedBy AS Responsibility,
	--TTMP.Medium AS DownTimeTemplateName,
	CASE RL.OprSequenceNo when '0005' then 'A'
	when '0010' then 'B'
	when '0020' then 'C'
	when '0030' then 'D'
	when '0040' then 'E'
	when '0050' then 'F'
	when '0060' then 'G'
	when '0070' then 'H'
	when '0080' then 'I'
	when '0090' then 'J'
	when '0100' then 'K'
	when '0110' then 'L'
	when '0120' then 'M'
	when '0130' then 'N'
	when '0140' then 'O'
	when '0150' then 'P'
	when '0160' then 'R'
	when '0170' then 'S'
	else 'Z'END SeqOrder,
	RWSD.Shift AS Shift,
	dbo.AF_GetUTCToLocal(Planned3Y.ExpectedCompletionDate) AS Planned3Y,
  --dbo.AF_GetUTCToLocal(Actual3Z.ActualCompletionDate) AS Actual3Z,
  --dbo.AF_GetUTCToLocal(Actual3Y.ActualStartDate) AS Actual3Y,

 
	dbo.AF_GetUTCToLocalForTimeZone(1224,Actual3Z.ActualCompletionDate) AS Actual3Z,   /*CHANGE fOR TIMEZONE CR */
	dbo.AF_GetUTCToLocalForTimeZone(1224,Actual3Y.ActualStartDate) AS Actual3Y,    /*CHANGE fOR TIMEZONE CR */

	DATEPART(yy,dbo.AF_GetUTCToLocal(Actual3Z.ActualCompletionDate)) AS YearActual3Z,
	DATEPART(mm,dbo.AF_GetUTCToLocal(Actual3Z.ActualCompletionDate)) AS MonthActual3Z,
	DATEPART(wk,dbo.AF_GetUTCToLocal(Actual3Z.ActualCompletionDate)) AS WeekActual3Z,
	DATEPART(dd,dbo.AF_GetUTCToLocal(Actual3Z.ActualCompletionDate)) AS DayActual3Z

FROM 

	CAPA_PROPERTY_VALUE CPV 
	JOIN CAPA C ON C.ID=CPV.CAPAID
	JOIN AT_RESOURCE_LABOR_RESOURCE_LABOR ARL ON ARL.ParentResourceLaborId=CPV.ValueInt AND CPV.Property='ResourceLaborID'
	JOIN RESOURCE_LABOR RL ON RL.ID=ARL.ChildResourceLaborId AND RL.LaborType=9
	JOIN REASON_CODE RC ON C.RootCauseReasonCode=RC.ReasonCode
	JOIN TEXT_TRANSLATION TRC ON RC.TextID=TRC.TextID AND TRC.LanguageID=1033
	JOIN WIP_ORDER WO ON WO.WipOrderNo=RL.WipOrderNo AND WO.WipOrderType=RL.WipOrderType
	JOIN WIP_OPERATION WOP ON WOP.WipOrderNo=WO.WipOrderNo AND RL.OprSequenceNo=WOP.OprSequenceNo
	JOIN RESOURCE_ R ON R.ResourceName=RL.ResourceName AND R.ResourceType=RL.ResourceType
	JOIN PRODUCT P ON P.ID=WO.ProductID
	JOIN TEXT_TRANSLATION T ON T.TextID=P.TextID
	
	--JOIN TEXT_TRANSLATION TTMP ON C.TextID=TTMP.TextID
	JOIN TEXT_TRANSLATION TT ON TT.TextID=C.RootCauseTextID
	JOIN TEXT_TRANSLATION TT2 ON TT2.TextID=C.CorrectiveActionTextID
	JOIN EQUIPMENT E ON E.ResourceID=R.ID
	CROSS APPLY(SELECT TOP 1 * FROM AT_SHIFT ATS WHERE ATS.WorkCenter=WOP.WorkCenter AND WOP.ActualCompletionDate BETWEEN ATS.StartDateTime AND ATS.EndDateTime) ATSH
	JOIN ROTATING_WORK_SCHEDULE_DETAIL RWSD ON ATSH.RotatingScheduleID=RWSD.RotatingScheduleID AND ATSH.DaySequenceNo=RWSD.DaySequenceNo AND ATSH.SequenceNo=RWSD.SequenceNo
	CROSS APPLY(SELECT MAX(WOP1.ActualCompletionDate) AS ActualCompletionDate FROM AT_WIP_OPERATION_DETAIL WOP1 WHERE WOP1.WipOrderNo=WOP.WipOrderNo AND WOP1.WipOrderType=WOP.WipOrderType) Actual3Z
	CROSS APPLY(SELECT MIN(WOP1.ExpectedCompletionDate) AS ExpectedCompletionDate FROM AT_WIP_OPERATION_DETAIL WOP1 WHERE WOP1.WipOrderNo=WOP.WipOrderNo AND WOP1.WipOrderType=WOP.WipOrderType) Planned3Y
	CROSS APPLY(SELECT MIN(WOP1.ActualStartDate) AS ActualStartDate FROM AT_WIP_OPERATION_DETAIL WOP1 WHERE WOP1.WipOrderNo=WOP.WipOrderNo AND WOP1.WipOrderType=WOP.WipOrderType) Actual3Y

