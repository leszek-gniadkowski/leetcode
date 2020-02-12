declare @n int = 4

drop table if exists #array
create table #array(x int,y int)

drop table if exists #map
create table #map(src_x int,src_y int,dst_x int,dst_y int)

drop table if exists #out
create table #out(step int, src_x int,src_y int,dst_x int,dst_y int, o varchar(max))

insert into #array(x,y)
select p1.number,p2.number
from master.dbo.spt_values p1 
cross join master.dbo.spt_values p2 
where p1.type ='p' and p1.number < @n
	and p2.type ='p' and p2.number < @n

insert into #map(src_x, src_y, dst_x, dst_y)
select
	 a1.x as src_x
	,a1.y as src_y
	,a2.x as dst_x
	,a2.y as dst_y
from #array a1
cross join #array a2
where case
		when a1.y = a2.y then 1 --h
		when a1.x = a2.x then 1 --v
		when a1.y - a1.x = a2.y - a2.x then 1  --dr
		when a1.y + a1.x = a2.y + a2.x then 1  --dl
		else 0
		end = 0
		and a2.y > a1.y --perf

insert into #out(step,o, src_x, src_y, dst_x, dst_y)
select
	1 step
	,'"' + stuff(replicate('.',@n),a1.x+1,1,'Q') + '",' o
	,src_x
	,src_y
	,dst_x
	,dst_y
from #array a1
inner join #map m
	on a1.x = m.src_x and a1.y = m.src_y
where a1.y = 0

declare @i int = 1

while @i < @n
begin

insert into #out(step,o, src_x, src_y, dst_x, dst_y)
select
	 @i + 1 step
	,o1.o + '"' + stuff(replicate('.',@n),o1.dst_x+1,1,'Q') + '",' o
	,o1.dst_x as src_x
	,o1.dst_y as src_y
	,m.dst_x
	,m.dst_y
from #out o1
inner join #map m
	on o1.dst_x = m.src_x and o1.dst_y = m.src_y
inner join #out o2
	on o2.step = @i and o2.dst_x = m.dst_x and o2.dst_y = m.dst_y and o1.o = o2.o
where o1.step = @i and o1.dst_y = @i

set @i = @i + 1
end

select
	'[' + o.o + '"' + stuff(replicate('.',@n),o.dst_x+1,1,'Q') + '"]' o
from #out o
where step = @n - 1
