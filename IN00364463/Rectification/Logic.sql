select * from AM_RowCummulation_Test

SELECT 
	CT.WipOrderNo as Order_No,
	CT.OprSequenceNo as Operation_Sequence,
	lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) as Previous_End_Time,
	CT.StartTime as Start_Time,
	CT.EndTime as End_Time,
	--CASE 
	--	when CT.WipOrderNo  = lag(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
	--	and CT.OprSequenceNo  = lag(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
	--	and CT.StartTime = lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
	--	then 
	--		--'Yes'
	--	cast(CT.WipOrderNo as varchar) + cast(CT.OprSequenceNo as varchar) 
		
	--	when
	--		CT.EndTime = lead(CT.StartTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
	--		and CT.WipOrderNo  = lead(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
	--		and CT.OprSequenceNo  = lead(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
	--	then 
	--		--'Yes'
	--	cast(CT.WipOrderNo as varchar) + cast(CT.OprSequenceNo as varchar) 
	--	else 'No' 
	--	END True_Split
	--	,

		
		CASE 
		when CT.WipOrderNo  = lag(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
		and CT.OprSequenceNo  = lag(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
		and CT.WipOrderNo  = lead(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
		and CT.OprSequenceNo  = lead(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
		and CT.StartTime = lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
		and CT.EndTime = lead(CT.StartTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
		then 
			'Continue'
		
		when
			CT.EndTime = lead(CT.StartTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
			and CT.WipOrderNo  = lead(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
			and CT.OprSequenceNo  = lead(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
		then 
			'Start'
		when
			CT.StartTime = lag(CT.EndTime) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime)
			and CT.WipOrderNo  = lag(CT.WipOrderNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
			and CT.OprSequenceNo  = lag(CT.OprSequenceNo) over (ORDER BY WipOrderNo, OprSequenceNo, StartTime) 
		then 
			'End'

		else 'Isolate' 
		END Series
FROM
	AM_RowCummulation_Test CT


--END

--condition 1:
--where True_Split = 'No' and Gap = 'Discontinuous'
--where True_Split <> 'No' or Gap <> 'Discontinuous'