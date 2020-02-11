--https://leetcode.com/problems/n-queens/

-- @n < 8  (bigint limit)
declare @n int = 4

;with cover as
(
select
	 p1.number as src_field
	,p2.number as dest_field
	,case
		when p1.number / @n = p2.number / @n then 1 --h
		when p1.number % @n = p2.number % @n then 1 --v
		when p1.number / @n - p1.number % @n = p2.number / @n - p2.number % @n  then 1  --dr
		when p1.number / @n + p1.number % @n = p2.number / @n + p2.number % @n  then 1  --dl
		else 0
		end cover
from master.dbo.spt_values p1 
cross join master.dbo.spt_values p2 
where p1.type ='p' and p1.number < power(@n,2)
	and p2.type ='p' and p2.number < power(@n,2)
)
,cover_bitwise as
(
select
	 src_field
	,sum(power(cast(2 as bigint),dest_field) * cover) mask
from cover
group by src_field
)
,main as
(
select
	 p3.number as src_field
	,cb.mask as bitboard
	,1 as step
	,',' + cast(p3.number as varchar(8000)) + ',' as hist
from master.dbo.spt_values p3
inner join cover_bitwise cb
	on p3.number = cb.src_field
where p3.type ='p' and p3.number < power(@n,2)

union all

select
	 cb.src_field
	,m.bitboard | cb.mask as bitboard
	,m.step + 1 as step
	,m.hist + cast(cb.src_field as varchar(8000)) + ',' as hist
from main m
inner join cover_bitwise cb
	on m.bitboard & power(cast(2 as bigint),cb.src_field) = 0
		and m.hist not like '%,' + cast(cb.src_field as varchar(8000)) + ',%'
		and cb.src_field > m.src_field
)
,result as
(
select
	 dense_rank() over (order by hist) solution
	,p4.number
	,case when m.hist like '%,' + cast(p4.number as varchar(8000)) + ',%' then 1 else 0 end cover
	from main m
cross join master.dbo.spt_values p4
where p4.type ='p' and p4.number < power(@n,2)
	and len(hist)-len(replace(hist,',','')) = @n + 1
)

select 
	solution
	,(
		select iif(cover = 1,'Q','.')
		from result r1
		where r1.solution = r2.solution
			and r1.number / @n = r2.number / @n
		for xml path ('')
		) output
from result r2
group by r2.solution, r2.number / @n
order by r2.solution, r2.number / @n
option(maxrecursion 0)
