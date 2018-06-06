--************************
-- int inc
--************************

declare 
@p_dfrom date = '${P_DFROM}',
@p_dto   date = '${P_DTO}', 
@l_prefix varchar(3) = '${P_OLTP}', 
@acc_type varchar(1) = 'Ю',
@p_initial_date date = '${P_INITIAL_DATE}',
@p_dfrom_ods date = '${P_DFROM_ODS}',
@p_dto_ods date = '${P_DTO_ODS}';





declare @p_FizAcc varchar(max), @p_UrAcc varchar(max), @p_CessAcc varchar(max);
select
  @p_FizAcc = ?, -- 1-й параметр
  @p_UrAcc = ?, -- 2-й параметр
  @p_CessAcc = ?; -- 3-й параметр

declare @l_delimiter varchar(1) = ';';




------------------------------------------------------------------------------------------------------------------

-- Списки балансовых счетов для физиков и юриков

set @p_FizAcc += @l_delimiter;

with Splitter as
(
  select cast(1 as bigint) as f, CHARINDEX(@l_delimiter, @p_FizAcc) as t, 1 as seq
  union all
  select cast(t + 1 as bigint), CHARINDEX(@l_delimiter, @p_FizAcc, t + 1), seq + 1
    from Splitter
    where CHARINDEX(@l_delimiter, @p_FizAcc, t + 1) > 0
)

select SUBSTRING(@p_FizAcc, f, t - f) as AccNum
into #FizAcc
from Splitter
option (MAXRECURSION 0)
;

set @p_UrAcc += @l_delimiter;

with Splitter as
(
  select cast(1 as bigint) as f, CHARINDEX(@l_delimiter, @p_UrAcc) as t, 1 as seq
  union all
  select cast(t + 1 as bigint), CHARINDEX(@l_delimiter, @p_UrAcc, t + 1), seq + 1
    from Splitter
    where CHARINDEX(@l_delimiter, @p_UrAcc, t + 1) > 0
)

select SUBSTRING(@p_UrAcc, f, t - f) as AccNum
into #UrAcc
from Splitter
option (MAXRECURSION 0)
;

-- Цессии
set @p_CessAcc += @l_delimiter;

with Splitter as
(
  select cast(1 as bigint) as f, CHARINDEX(@l_delimiter, @p_CessAcc) as t, 1 as seq
  union all
  select cast(t + 1 as bigint), CHARINDEX(@l_delimiter, @p_CessAcc, t + 1), seq + 1
    from Splitter
    where CHARINDEX(@l_delimiter, @p_CessAcc, t + 1) > 0
)

select SUBSTRING(@p_CessAcc, f, t - f) as AccNum
into #CessAcc
from Splitter
option (MAXRECURSION 0)
;



------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------






with ProlongsHier(ID, 
					Parent, 
					LevelNum, 
					Root) as
(
select 
	cda.NCDAAGRID
	,cda.NCDAPARENT
	,0 as LevelNum
	,cda.NCDAAGRID as Root
from 
	ods.ODS_MIV_CDA cda
where
	cda.NCDAPARENT is null
	and cda.DWH_STATE = 'A'

union all

select
	cda.NCDAAGRID
	,cda.NCDAPARENT
	,me.LevelNum + 1
	,me.Root 
from
	ods.ODS_MIV_CDA cda
	inner join ProlongsHier me
	on me.ID = cda.NCDAPARENT
where 
	cda.NCDAPARENT is not null
	and cda.DWH_STATE = 'A'
)

---------------------------------------------------------------------------------------------------------------------

select * into #ProlongsHier from ProlongsHier

---------------------------------------------------------------------------------------------------------------------

/*
select sub.* into #Acc from
(
select '40101' as AccNumUr, null as AccNumFiz  union all select '40102' as AccNumUr, null as AccNumFiz union all select '40103' as AccNumUr, null as AccNumFiz union all select '40104' as AccNumUr, null as AccNumFiz union all select '40105' as AccNumUr, null as AccNumFiz union all select '40106' as AccNumUr, null as AccNumFiz union all select '40107' as AccNumUr, null as AccNumFiz union all select '40108' as AccNumUr, null as AccNumFiz union all select '40109' as AccNumUr, null as AccNumFiz union all select '44201' as AccNumUr, null as AccNumFiz union all select '44202' as AccNumUr, null as AccNumFiz union all select '44203' as AccNumUr, null as AccNumFiz union all
select '44204' as AccNumUr, null as AccNumFiz  union all select '44205' as AccNumUr, null as AccNumFiz union all select '44206' as AccNumUr, null as AccNumFiz union all select '44207' as AccNumUr, null as AccNumFiz union all select '44208' as AccNumUr, null as AccNumFiz union all select '44209' as AccNumUr, null as AccNumFiz union all select '44210' as AccNumUr, null as AccNumFiz union all select '44301' as AccNumUr, null as AccNumFiz union all select '44302' as AccNumUr, null as AccNumFiz union all
select '44303' as AccNumUr, null as AccNumFiz  union all select '44304' as AccNumUr, null as AccNumFiz union all select '44305' as AccNumUr, null as AccNumFiz union all select '44306' as AccNumUr, null as AccNumFiz union all select '44307' as AccNumUr, null as AccNumFiz union all select '44308' as AccNumUr, null as AccNumFiz union all select '44309' as AccNumUr, null as AccNumFiz union all select '44310' as AccNumUr, null as AccNumFiz union all select '44401' as AccNumUr, null as AccNumFiz union all select '44402' as AccNumUr, null as AccNumFiz union all select '44403' as AccNumUr, null as AccNumFiz union all select '44404' as AccNumUr, null as AccNumFiz union all select '44405' as AccNumUr, null as AccNumFiz union all select '44406' as AccNumUr, null as AccNumFiz union all select '44407' as AccNumUr, null as AccNumFiz union all
select '44408' as AccNumUr, null as AccNumFiz  union all select '44409' as AccNumUr, null as AccNumFiz union all select '44410' as AccNumUr, null as AccNumFiz union all select '44501' as AccNumUr, null as AccNumFiz union all select '44503' as AccNumUr, null as AccNumFiz union all select '44504' as AccNumUr, null as AccNumFiz union all select '44505' as AccNumUr, null as AccNumFiz union all select '44506' as AccNumUr, null as AccNumFiz union all select '44507' as AccNumUr, null as AccNumFiz union all select '44508' as AccNumUr, null as AccNumFiz union all select '44509' as AccNumUr, null as AccNumFiz union all select '44601' as AccNumUr, null as AccNumFiz union all select '44603' as AccNumUr, null as AccNumFiz union all select '44604' as AccNumUr, null as AccNumFiz union all select '44605' as AccNumUr, null as AccNumFiz union all
select '44606' as AccNumUr, null as AccNumFiz  union all select '44607' as AccNumUr, null as AccNumFiz union all select '44608' as AccNumUr, null as AccNumFiz union all select '44609' as AccNumUr, null as AccNumFiz union all select '44701' as AccNumUr, null as AccNumFiz union all select '44703' as AccNumUr, null as AccNumFiz union all select '44704' as AccNumUr, null as AccNumFiz union all select '44705' as AccNumUr, null as AccNumFiz union all select '44706' as AccNumUr, null as AccNumFiz union all select '44707' as AccNumUr, null as AccNumFiz union all select '44708' as AccNumUr, null as AccNumFiz union all select '44709' as AccNumUr, null as AccNumFiz union all select '44801' as AccNumUr, null as AccNumFiz union all select '44803' as AccNumUr, null as AccNumFiz union all select '44804' as AccNumUr, null as AccNumFiz union all
select '44805' as AccNumUr, null as AccNumFiz  union all select '44806' as AccNumUr, null as AccNumFiz union all select '44807' as AccNumUr, null as AccNumFiz union all select '44808' as AccNumUr, null as AccNumFiz union all select '44809' as AccNumUr, null as AccNumFiz union all select '44901' as AccNumUr, null as AccNumFiz union all select '44903' as AccNumUr, null as AccNumFiz union all select '44904' as AccNumUr, null as AccNumFiz union all select '44905' as AccNumUr, null as AccNumFiz union all select '44906' as AccNumUr, null as AccNumFiz union all select '44907' as AccNumUr, null as AccNumFiz union all select '44908' as AccNumUr, null as AccNumFiz union all select '44909' as AccNumUr, null as AccNumFiz union all select '45001' as AccNumUr, null as AccNumFiz union all select '45003' as AccNumUr, null as AccNumFiz union all
select '45004' as AccNumUr, null as AccNumFiz  union all select '45005' as AccNumUr, null as AccNumFiz union all select '45006' as AccNumUr, null as AccNumFiz union all select '45007' as AccNumUr, null as AccNumFiz union all select '45008' as AccNumUr, null as AccNumFiz union all select '45009' as AccNumUr, null as AccNumFiz union all select '45101' as AccNumUr, null as AccNumFiz union all select '45103' as AccNumUr, null as AccNumFiz union all select '45104' as AccNumUr, null as AccNumFiz union all select '45105' as AccNumUr, null as AccNumFiz union all select '45106' as AccNumUr, null as AccNumFiz union all select '45107' as AccNumUr, null as AccNumFiz union all select '45108' as AccNumUr, null as AccNumFiz union all select '45109' as AccNumUr, null as AccNumFiz union all select '45201' as AccNumUr, null as AccNumFiz union all
select '45203' as AccNumUr, null as AccNumFiz  union all select '45204' as AccNumUr, null as AccNumFiz union all select '45205' as AccNumUr, null as AccNumFiz union all select '45206' as AccNumUr, null as AccNumFiz union all select '45207' as AccNumUr, null as AccNumFiz union all select '45208' as AccNumUr, null as AccNumFiz union all select '45209' as AccNumUr, null as AccNumFiz union all select '45301' as AccNumUr, null as AccNumFiz union all select '45303' as AccNumUr, null as AccNumFiz union all select '45304' as AccNumUr, null as AccNumFiz union all select '45305' as AccNumUr, null as AccNumFiz union all select '45306' as AccNumUr, null as AccNumFiz union all select '45307' as AccNumUr, null as AccNumFiz union all select '45308' as AccNumUr, null as AccNumFiz union all select '45309' as AccNumUr, null as AccNumFiz union all
select '45401' as AccNumUr, null as AccNumFiz  union all select '45403' as AccNumUr, null as AccNumFiz union all select '45404' as AccNumUr, null as AccNumFiz union all select '45405' as AccNumUr, null as AccNumFiz union all select '45406' as AccNumUr, null as AccNumFiz union all select '45407' as AccNumUr, null as AccNumFiz union all select '45408' as AccNumUr, null as AccNumFiz union all select '45409' as AccNumUr, null as AccNumFiz union all select '45601' as AccNumUr, null as AccNumFiz union all select '45602' as AccNumUr, null as AccNumFiz union all select '45603' as AccNumUr, null as AccNumFiz union all select '45604' as AccNumUr, null as AccNumFiz union all select '45605' as AccNumUr, null as AccNumFiz union all select '45606' as AccNumUr, null as AccNumFiz union all select '45607' as AccNumUr, null as AccNumFiz union all select '45608' as AccNumUr, null as AccNumFiz union all
select '45801' as AccNumUr, null as AccNumFiz  union all select '45802' as AccNumUr, null as AccNumFiz union all select '45803' as AccNumUr, null as AccNumFiz union all select '45804' as AccNumUr, null as AccNumFiz union all select '45805' as AccNumUr, null as AccNumFiz union all select '45806' as AccNumUr, null as AccNumFiz union all select '45807' as AccNumUr, null as AccNumFiz union all select '45808' as AccNumUr, null as AccNumFiz union all select '45809' as AccNumUr, null as AccNumFiz union all select '45810' as AccNumUr, null as AccNumFiz union all select '45811' as AccNumUr, null as AccNumFiz union all select '45812' as AccNumUr, null as AccNumFiz union all select '45813' as AccNumUr, null as AccNumFiz union all select '45814' as AccNumUr, null as AccNumFiz union all select '45816' as AccNumUr, null as AccNumFiz
union all
select null as AccNumUr, '45502' as AccNumFiz union all select null as AccNumUr, '45503' as AccNumFiz union all select null as AccNumUr, '45504' as AccNumFiz union all select null as AccNumUr, '45505' as AccNumFiz union all
select null as AccNumUr, '45506' as AccNumFiz union all select null as AccNumUr, '45507' as AccNumFiz union all select null as AccNumUr, '45508' as AccNumFiz union all select null as AccNumUr, '45509' as AccNumFiz union all
select null as AccNumUr, '45701' as AccNumFiz union all select null as AccNumUr, '45702' as AccNumFiz union all select null as AccNumUr, '45703' as AccNumFiz union all select null as AccNumUr, '45704' as AccNumFiz union all
select null as AccNumUr, '45705' as AccNumFiz union all select null as AccNumUr, '45706' as AccNumFiz union all select null as AccNumUr, '45707' as AccNumFiz union all select null as AccNumUr, '45708' as AccNumFiz union all
select null as AccNumUr, '45815' as AccNumFiz union all select null as AccNumUr, '45817' as AccNumFiz   
) sub
*/
-------------------------------------------------------------------------------------
--#prolong

select 

cda.NCDAAGRID RootID
, ierarhy.ID ProlongID
, ierarhy.Parent    ParentRolongID
, FirstProlongEventDate = (select min(cde.dcdeDate) 
			from ods.ODS_MIV_CDE cde
			where cde.NCDEAGRID = prolongs.NCDAAGRID 
			and cde.icdetype in (1, 41, 701, 721)
			and cde.DWH_STATE = 'A') 
, ProlongCloseDate = case 
			when prolongs.ICDASTATUS = 3 then prolongs.DCDACLOSED 
			else null  
		 end
, prolongs.ICDALINETYPE ProlongLineType

,cast((case when cus.ccusFlag = 1 then 'Ф'
              when cus.ccusFlag is null then null
              else 'Ю'
         end) as varchar(1)) as ProlongClientType
into #prolong

from ods.ODS_MIV_CDA cda
	left join #ProlongsHier ierarhy
			on ierarhy.Root = cda.NCDAAGRID
	left join ods.ODS_MIV_CDA prolongs
			on prolongs.NCDAAGRID = ierarhy.ID
			and prolongs.ICDASTATUS in (1,2,3,5)
	left join ods.ODS_MIV_CUS cus -- Клиент
			on cus.icusNum = cda.icdaClient
where cda.DWH_STATE = 'A'
	
--------------------------------------------------------------------------------------
--#phiz_uric_accs -- физики и юрики

select 

p2.*

  , PRE_UR_FIZ_TYPE = 
		case when p2.HasFizAccEver = 1 and p2.HasUrAccEver = 0 then 'Ф' -- если были только счета физиков, то это физик
		 when p2.HasFizAccEver = 1 and p2.HasUrAccEver = 1 and p2.HasFizClient = 1 then 'Ф' -- если были счета и физиков, и юриков, то берем признак с клиента
		 when p2.HasFizAccEver = 0 and p2.HasUrAccEver = 0 and p2.HasFizClient = 1 then 'Ф' -- если не было счетов ни физиков, ни юриков, то берем признак с клиента
     when p2.HasUrAccEver = 1 and p2.HasFizAccEver = 0 then 'Ю' -- если были только счета юриков, то это юрик
		 when p2.HasUrAccEver = 1 and p2.HasFizAccEver = 1 and p2.HasUrClient = 1 then 'Ю' -- если были счета и физиков, и юриков, то берем признак с клиента
		 when p2.HasUrAccEver = 0 and p2.HasFizAccEver = 0 and p2.HasUrClient = 1 then 'Ю' -- если не было счетов ни физиков, ни юриков, то берем признак с клиента
    end

into #phiz_uric_accs

from
( --p2
select
p.*
,HasFizAccEver   = max(p.HasProlongFizAccEver) over (partition by p.RootID) 
,HasUrAccEver    = max(p.HasProlongUrAccEver) over (partition by p.RootID) 
,HasCessAccEver  = max(p.HasProlongCessAccEver) over (partition by p.RootID) 
,Close_Date    = isnull(first_value(p.ProlongCloseDate ) over (partition by p.RootID order by p.Rank desc), cast('99991231' as date))
  ,max(p.HasProlongFizClient) over (partition by p.RootID) as HasFizClient 
  ,max(p.HasProlongUrClient) over (partition by p.RootID) as HasUrClient 
from
( --p
	select
	prol.*
	,HasProlongFizAccEver = (case when exists(select 1 
												from ods.ODS_MIV_CDH cdh
												where cdh.DWH_STATE = 'A' 
												and cdh.ccdhTerm = 'LOANACC' 
												and cdh.ncdhAgrID = prol.ProlongID 
												and left(cdh.ccdhCVal, 5) in (select #FizAcc.AccNum from #FizAcc)
												and cdh.dcdhDate >= (select isnull(max(cdh2.dcdhDate), cast('19000101' as date))
																	from ods.ODS_MIV_CDH cdh2
																	where cdh2.ccdhTERM = 'LOANACC' 
																	and cdh2.ncdhAgrID = prol.ProlongID
																	and cdh2.dcdhDate <= prol.FirstProlongEventDate 
																	and cdh2.DWH_STATE = 'A'
                                           )
                    )
			then 1
			else 0
		end)

	,HasProlongUrAccEver = (case when exists(select 1 
											from ods.ODS_MIV_CDH cdh
											where cdh.DWH_STATE = 'A' 
											and cdh.ccdhTerm = 'LOANACC' 
											and cdh.ncdhAgrID = prol.ProlongID 
											and left(cdh.ccdhCVal, 5) in (select #UrAcc.AccNum from #UrAcc)
											and cdh.dcdhDate >= (select isnull(max(cdh2.dcdhDate), cast('19000101' as date))
																from ods.ODS_MIV_CDH cdh2
																where cdh2.ccdhTERM = 'LOANACC' 
																and cdh2.ncdhAgrID = prol.ProlongID
																and cdh2.dcdhDate <= prol.FirstProlongEventDate 
																and cdh2.DWH_STATE = 'A'
                                           )
                    )
			then 1
			else 0
		end)
			
	,HasProlongCessAccEver = (case when exists(select 1 
											from ods.ODS_MIV_CDH cdh
											where cdh.DWH_STATE = 'A' 
											and cdh.ccdhTerm = 'LOANACC' 
											and cdh.ncdhAgrID = prol.ProlongID 
											and left(cdh.ccdhCVal, 5) in (select #CessAcc.AccNum from #CessAcc)
											and cdh.dcdhDate >= (select isnull(max(cdh2.dcdhDate), cast('19000101' as date))
																from ods.ODS_MIV_CDH cdh2
																where cdh2.ccdhTERM = 'LOANACC' 
																and cdh2.ncdhAgrID = prol.ProlongID
																and cdh2.dcdhDate <= prol.FirstProlongEventDate 
																and cdh2.DWH_STATE = 'A'
                                           )
                    )
			then 1
			else 0
		end)
			
	, DFROM = prol.FirstProlongEventDate
	, DTO   = lead(prol.FirstProlongEventDate, 1, cast('99991231'as date)) over(partition by prol.RootID order by prol.FirstProlongEventDate, prol.ProlongID asc )
	, Rank = row_number() over( partition by prol.RootID order by prol.FirstProlongEventDate , prol.ProlongID asc)
  ,case when prol.ProlongClientType = 'Ф' then 1 else 0 end as HasProlongFizClient 
  ,case when prol.ProlongClientType = 'Ю' then 1 else 0 end as HasProlongUrClient  


	from 
	#prolong prol
) p
) p2

-------------------------------------------------------------------------------------------------------
--select * from #phiz_uric_accs
-----------------------------------------------------

select 
ur_phiz_accs.RootID
, sub_full_with_transhes.ICDQPART
into #full_from_cda_with_transches
from 
(--договора с траншами
select 
icdqpart,
cda.*

from ods.ODS_MIV_CDA cda, 
	 ods.ODS_MIV_CDQ cdq

where 1=1
and (cda.ICDASTATUS in (1,2,3,5))
and exists(select * 
			from ods.ODS_MIV_CDE cde 
			where cde.ICDETYPE in (1, 41, 701, 721)  
			and cde.NCDEAGRID = cdq.ncdqagrid 
			and cde.ICDEPART = icdqpart)
and NCDAAGRID = ncdqagrid
and ICDAISLINE = 1 and ICDALINETYPE in (3,4)
and cda.DWH_STATE = 'A'
and cdq.DWH_STATE = 'A'
) sub_full_with_transhes
inner join #phiz_uric_accs ur_phiz_accs
on sub_full_with_transhes.NCDAAGRID = ur_phiz_accs.ProlongID
group by 
ur_phiz_accs.RootID
, sub_full_with_transhes.ICDQPART
----------------------------------------
--select * from #full_from_cda_with_transches ff where ff.NCDAAGRID like '13308%'
--------------------------------------------------------


select 
ur_phiz_accs.RootID
, sub_full_without_transhes.ICDQPART
into #full_from_cda_without_transches
from 
(--договора без траншей
select 
icdqpart,
cda.*

from ods.ODS_MIV_CDA cda, 
	 ods.ODS_MIV_CDQ cdq
where 1=1
and (cda.ICDASTATUS in (1,2,3,5))
and exists(select * 
			from ods.ODS_MIV_CDE cde 
			where cde.ICDETYPE in (1, 41, 701, 721) 
			and cde.NCDEAGRID = cdq.ncdqagrid 
			and cde.ICDEPART = icdqpart)
and cda.NCDAAGRID = cdq.ncdqagrid
and ICDAISLINE in (0,1) 
and 
/*ICDALINETYPE  not in (3,4) or */
(ICDALINETYPE in (0,1,2) or ICDALINETYPE is null)
and cda.DWH_STATE = 'A'
and cdq.DWH_STATE = 'A'
) sub_full_without_transhes

inner join #phiz_uric_accs ur_phiz_accs
on sub_full_without_transhes.NCDAAGRID = ur_phiz_accs.ProlongID
group by 
ur_phiz_accs.RootID
, sub_full_without_transhes.ICDQPART
-------------------------------------------------------------
--поиск даты первой выдачи каждого транша
select 
sub.*
, FirstPartEventDate = min(sub.FirstProlongPartEventDate) over(partition by sub.RootID, sub.PartNum) 
						
into #firstTranshDate
from
(--sub
	select 
	puaccs.*
	, PartNum = cdq.ICDQPART
	, PartNo  = cdq.CCDQTRANCHE
	, FirstProlongPartEventDate = (select min(cde.dcdeDate)
									from ods.ODS_MIV_CDE cde
									where cde.NCDEAGRID = puaccs.ProlongID
									and cde.ICDEPART = cdq.icdqPart
									and cde.ICDETYPE in (1, 41, 701, 721)
									and cde.DWH_STATE = 'A')

	from #phiz_uric_accs puaccs
		inner join ods.ODS_MIV_CDQ cdq
		on
		cdq.NCDQAGRID = puaccs.ProlongID
	where 1=1 
--	and puaccs.ProlongLineType in (3,4)
	and cdq.icdqPart is not null
	and cdq.DWH_STATE = 'A'
) sub
-------------------------------
--select * from #firstTranshDate ftd where ftd.RootID like '13308%'
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
select --increment
distinct
	ftd.RootID
into #increment
from ods.ODS_MIV_CDH cdh
inner join #phiz_uric_accs ftd
	on cdh.NCDHAGRID = ftd.ProlongID
where 
1=1
and cdh.DWH_ETL_DT between @p_dfrom_ods and @p_dto_ods
and cdh.CCDHTERM in (
					'INTRATE'
					,'LOANFINE'
					,'OVDRATE'
					,'INTFINE'
					)

-----
--select * from #increment
--------------------------------------------------------------------------------------------------------


select --main_1 для договоров с траншами
sub3.*
into #full_select_1
from
( --sub3
select
ACTUAL_DATE     = case when sub2.ACT_DATE <= @p_dfrom and cast(LEAD(cast(sub2.ACT_DATE as date), 1, cast('99991231' as date)) over(partition by sub2.RootID, sub2.CONTRACT_ID, sub2.INTEREST_TYPE order by  sub2.ACT_DATE asc) as date) > @p_dfrom then @p_dfrom
				  else sub2.ACT_DATE
				  end
,next_actual_date = dateadd(day,-1,cast(LEAD(cast(sub2.ACT_DATE as date), 1, cast(sub2.DTO as date)) over(partition by sub2.RootID, sub2.CONTRACT_ID, sub2.INTEREST_TYPE  order by sub2.ACT_DATE asc) as date))

,sub2.DFROM
,sub2.DTO
,sub2.RootID
,sub2.CONTRACT_ID
,sub2.INTEREST_TYPE
,sub2.INTEREST_VALUE
,sub2.UR_FIZ_TYPE

from
( --sub2
select 
sub.*,

ACT_DATE =	
					case 
					when sub.FirstPartEventDate >= sub.AC_DATE 
					and cast(LEAD(cast(sub.AC_DATE as date), 1, cast('99991231' as date)) over(partition by sub.RootID, sub.CONTRACT_ID, sub.INTEREST_TYPE order by  sub.AC_DATE asc) as date) > sub.FirstPartEventDate  
					then sub.FirstPartEventDate
					else sub.AC_DATE  
					end
			

from( -- sub
select
AC_DATE = cdh.dcdhdate
,INTEREST_VALUE = round(cast(isnull(cdh.PCDHPVAL,0) as float), 5 )
,CONTRACT_ID    =
							case 
							when PATINDEX('%.000',replace(convert(varchar(50),accs.RootID),',','.')) = 0  -- в дробной части есть значения
								then  
								@l_prefix 
								+  '_' 
								+ replace(cast(convert(numeric(20,3),accs.RootID) as varchar(50)),',','.') 
								+ '_' + cast(cdh.ICDHPART as varchar(50))
							when PATINDEX('%.000',replace(convert(varchar(50),accs.RootID),',','.')) != 0 
								then 
								@l_prefix 
								+  '_' 
								+ cast(convert(int, accs.RootID) as varchar(50)) 
								+ '_' + cast(cdh.ICDHPART as varchar(50))
							end
	
,INTEREST_TYPE       = cdh.CCDHTERM
,UR_FIZ_TYPE         = case when (select pua.PRE_UR_FIZ_TYPE from #phiz_uric_accs pua where cdh.NCDHAGRID = pua.ProlongID) = 'Ф'
						then 'Ф'
					   when (select pua.PRE_UR_FIZ_TYPE from #phiz_uric_accs pua where cdh.NCDHAGRID = pua.ProlongID) = 'Ю'
						then 'Ю'
						 end
,DOCNUM             = cdh.NCDHAGRID
,DTO                = accs.DTO
,DFROM              = accs.DFROM
,RootID             = accs.RootID
,FirstPartEventDate = ftd.FirstPartEventDate
,Close_Date         = accs.Close_Date

from ods.ODS_MIV_CDH cdh
inner join #ProlongsHier ph  -- append to every id his root
	on cdh.NCDHAGRID = ph.ID 
inner join #full_from_cda_with_transches full_w_t
	on 
	--full_w_t.NCDAAGRID = cdh.NCDHAGRID
	full_w_t.RootID = ph.Root
	and full_w_t.ICDQPART = cdh.ICDHPART
inner join #phiz_uric_accs accs
	on accs.ProlongID = cdh.NCDHAGRID
inner join #firstTranshDate ftd
	on ftd.ProlongID = cdh.NCDHAGRID
	and ftd.PartNum = cdh.ICDHPART

where 
cdh.DWH_STATE = 'A'
and cdh.CCDHTERM in (
					'INTRATE'
					,'LOANFINE'
					,'OVDRATE'
					,'INTFINE'
					)
and accs.Close_Date >= @p_initial_date

) sub
where sub.FirstPartEventDate is not null
) sub2
) sub3
where 1=1
and sub3.ACTUAL_DATE >= sub3.DFROM and sub3.ACTUAL_DATE <= sub3.DTO
and sub3.ACTUAL_DATE >= @p_dfrom and sub3.ACTUAL_DATE <= @p_dto


-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
--select * from #full_select_1 f1 where f1.CONTRACT_ID like 'MIV_17380%'
-------------------------------------------------------------------------




select --main_2 для договоров без траншей
sub3.*
into #full_select_2
from
( --sub3
select
ACTUAL_DATE     = case when sub2.ACT_DATE <= @p_dfrom and cast(LEAD(cast(sub2.ACT_DATE as date), 1, cast('99991231' as date)) over(partition by sub2.RootID, sub2.CONTRACT_ID, sub2.INTEREST_TYPE order by  sub2.ACT_DATE asc) as date) > @p_dfrom then @p_dfrom
				  else sub2.ACT_DATE
				  end
,next_actual_date = dateadd(day,-1,cast(LEAD(cast(sub2.ACT_DATE as date), 1, cast(sub2.DTO as date)) over(partition by sub2.RootID, sub2.CONTRACT_ID, sub2.INTEREST_TYPE  order by sub2.ACT_DATE asc) as date))

,sub2.DFROM
,sub2.DTO
,sub2.RootID
,sub2.CONTRACT_ID
,sub2.INTEREST_TYPE
,sub2.INTEREST_VALUE
,sub2.UR_FIZ_TYPE

from
( --sub2
select 
sub.*,

ACT_DATE =	
					case 
					when sub.DFROM >= sub.AC_DATE 
					and cast(LEAD(cast(sub.AC_DATE as date), 1, cast('99991231' as date)) over(partition by sub.RootID, sub.CONTRACT_ID, sub.INTEREST_TYPE order by  sub.AC_DATE asc) as date) > sub.DFROM  
					then sub.DFROM
					else sub.AC_DATE  
					end
			

from( -- sub
select
AC_DATE = cdh.dcdhdate
,INTEREST_VALUE = round(cast(isnull(cdh.PCDHPVAL,0) as float), 5 )
,CONTRACT_ID    =
							case 
							when PATINDEX('%.000',replace(convert(varchar(50),accs.RootID),',','.')) = 0  -- в дробной части есть значения
								then  
								@l_prefix 
								+  '_' 
								+ replace(cast(convert(numeric(20,3),accs.RootID) as varchar(50)),',','.') 
					
							when PATINDEX('%.000',replace(convert(varchar(50),accs.RootID),',','.')) != 0 
								then 
								@l_prefix 
								+  '_' 
								+ cast(convert(int, accs.RootID) as varchar(50)) 
					
							end

,INTEREST_TYPE       = cdh.CCDHTERM
,UR_FIZ_TYPE         = case when (select pua.PRE_UR_FIZ_TYPE from #phiz_uric_accs pua where cdh.NCDHAGRID = pua.ProlongID) = 'Ф'
						then 'Ф'
					   when (select pua.PRE_UR_FIZ_TYPE from #phiz_uric_accs pua where cdh.NCDHAGRID = pua.ProlongID) = 'Ю'
						then 'Ю'
						 end
,DOCNUM             = cdh.NCDHAGRID
,DTO                = accs.DTO
,DFROM              = accs.DFROM
,RootID             = accs.RootID
,Close_Date         = accs.Close_Date

from ods.ODS_MIV_CDH cdh
inner join #ProlongsHier ph  -- append to every id his root
	on cdh.NCDHAGRID = ph.ID 
inner join #full_from_cda_without_transches full_w_t
	on 
	--full_w_t.NCDAAGRID = cdh.NCDHAGRID
	full_w_t.RootID = ph.Root
	and full_w_t.ICDQPART = cdh.ICDHPART
inner join #phiz_uric_accs accs
	on accs.ProlongID = cdh.NCDHAGRID
inner join #firstTranshDate ftd
	on ftd.ProlongID = cdh.NCDHAGRID
	and ftd.PartNum = cdh.ICDHPART
where 
cdh.DWH_STATE = 'A'
and cdh.CCDHTERM in (
					'INTRATE'
					,'LOANFINE'
					,'OVDRATE'
					,'INTFINE'
					)
and accs.Close_Date >= @p_initial_date
and cdh.ICDHPART = 1 
) sub
where sub.DFROM is not null
) sub2
) sub3
where 1=1
and sub3.ACTUAL_DATE >= sub3.DFROM and sub3.ACTUAL_DATE <= sub3.DTO
and sub3.ACTUAL_DATE >= @p_dfrom and sub3.ACTUAL_DATE <= @p_dto

-------------------------------------------------------------------------
--select * from #full_select_2 f2 where f2.CONTRACT_ID like 'MIV_17380%'
-------------------------------------------------------------------------

select * 
into #full_select 
from 
(
select * from #full_select_1
union all
select * from #full_select_2
) sub_main
----------------------------------
--select * from #full_select fs where fs.CONTRACT_ID like 'MIV_17380%'
----------------------------------------------------------------------------------------------------------------
-----------------------------------------
-- filter full select with increment
select 
	fs.ACTUAL_DATE,
	fs.CONTRACT_ID,
	fs.DFROM,
	fs.DTO,
	fs.INTEREST_TYPE,
	fs.INTEREST_VALUE,
	fs.next_actual_date,
	inc.RootID,
	fs.UR_FIZ_TYPE,
	CLOSED = case when fs.CONTRACT_ID is null then 'Y' else 'N' end
into #main_with_inc
from #increment inc 
left join #full_select fs
on inc.RootID = fs.RootID
where fs.UR_FIZ_TYPE = @acc_type


-----------------------------------------
select 
ACTUAL_DATE = calendar.Date
,fs.CONTRACT_ID
,fs.INTEREST_TYPE
,fs.INTEREST_VALUE
,fs.UR_FIZ_TYPE 
,CLOSED = 'N'


from 
ods.ODS_Calendar(@p_dfrom, @p_dto) calendar 
inner join 
#main_with_inc fs 
on fs.ACTUAL_DATE <= calendar.Date and fs.next_actual_date >= calendar.Date 
where 1=1 
and cast(fs.UR_FIZ_TYPE as varchar(1)) = @acc_type 



order by  INTEREST_TYPE asc;





