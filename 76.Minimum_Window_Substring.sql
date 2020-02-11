--https://leetcode.com/problems/minimum-window-substring/
declare @s varchar(100) = 'ADOBECODEBANC' 
declare @t varchar(100) = 'ABC'

select top 1 s from
(
	select substring(x.s,1,n2.number + 1) s 
	from
	(
		select substring(@s,n1.number + 1,len(@s) - n1.number) s 
		from master.dbo.spt_values n1
		where n1.type = 'p' and n1.number < len(@s)
	) x
	inner join master.dbo.spt_values n2
		on n2.type = 'p' and n2.number < len(x.s)
) y
outer apply
(
	select 1 f 
	from master.dbo.spt_values 
	where type = 'p' 
		and number < len(@t) 
		and y.s not like '%' + substring(@t,number + 1,1) + '%'
) tt
where tt.f is null
order by len(y.s)
