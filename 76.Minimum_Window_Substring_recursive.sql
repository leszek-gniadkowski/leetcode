--https://leetcode.com/problems/minimum-window-substring/

declare @s varchar(100) = 'ADOBECODEBANC' 
declare @t varchar(100) = 'ABC'


;with cte1 as
(
	select substring(@t,number + 1,1) as t
	from master.dbo.spt_values 
	where type = 'p' 
		and number < len(@t) 
)
,cte2 as
	(
	select
		 @s as s
		,cast('' as varchar(100)) as window
		,1 as pointer1
		,1 as pointer2
		,1 as active_pointer
	
	union all
	
	select
		 s
		,window
		,pointer1
		,pointer2
		,case
			when active_pointer = 1 and not exists (
						select 1 f 
						from cte1 t
						where window not like '%' + t.t + '%'
					) then 2	-- change
			when active_pointer = 2 and not exists (
						select 1 f 
						from cte1 t
						where window not like '%' + t.t + '%'
					) then 2	-- no change
			when active_pointer = 2 then 1	-- change
			else 1	-- no change
			end	active_pointer	
	from
	(
		select
			 s
			,substring(s, pointer2, pointer1 - pointer2) as window
			,pointer1
			,pointer2
			,active_pointer
		from
		(
			select
				 s
				,window
				,case when active_pointer = 1 then pointer1 + 1 else pointer1 end pointer1
				,case when active_pointer = 2 then pointer2 + 1 else pointer2 end pointer2
				,active_pointer
			from cte2
			where pointer1 <= len(@s) + 1
		) x
	) y
)


select top(1) window
from cte2
where active_pointer = 2
order by len(window)

