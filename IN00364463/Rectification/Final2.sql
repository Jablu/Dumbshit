
WITH RawData AS (

SELECT 
	CT.WipOrderNo as Order_No,
	CT.OprSequenceNo as Operation_Sequence,
	lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo) as Previous_End_Time,
	CT.StartTime as Start_Time,
	CT.EndTime as End_Time,
	CASE 
		when CT.WipOrderNo  = lag(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo) 
		and CT.OprSequenceNo  = lag(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo) 
		and CT.StartTime = lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo)
		then 
			--'Yes'
		cast(CT.WipOrderNo as varchar) + cast(CT.OprSequenceNo as varchar) 
		
		when
			CT.EndTime = lead(CT.StartTime) over (ORDER BY WipOrderNo, OprSequenceNo)
			and CT.WipOrderNo  = lead(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo) 
			and CT.OprSequenceNo  = lead(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo) 
		then 
			--'Yes'
		cast(CT.WipOrderNo as varchar) + cast(CT.OprSequenceNo as varchar) 
		else 'No' 
		END True_Split,
	CASE 
		when
			CT.StartTime = lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo)
		then 
			'Continuous'
		else 'Discontinuous' 
		END Gap
FROM
	AM_RowCummulation_Test CT
)
select Order_No, Operation_Sequence, MIN(Start_Time) as Start_Time, MAX (End_Time) as End_Time  
	from RawData
	group by True_Split, Order_No, Operation_Sequence