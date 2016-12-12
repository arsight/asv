
--- BANK.TXT 
--  В BANK.TXT должны попадать только подразделения на самостоятельном балансе. 
-- В вашем случае – это ГО и Московский ф-л (пусть даже и закрыт). 
-- Он понадобится, когда потребуется выгрузка за 3х летний период (FIN-период), предшествующий отзыву лицензии. ККО, ДО, ОО и прочие в файл не включаются.
select  
       idsmr FIL, -- выводим только филиалы, которые со своим балансом 
       cotdname$ NAME 
  from "otd" otd
  where dotdclose is null
        and iotdnum = 0 -- выводим только филиалы, которые со своим балансом
  and 
  (
  exists (select null from "acc" where iaccotd=otd.iotdnum ) 
   or exists (select null from "cus" where icusotd=otd.iotdnum)
  )
order by idsmr,iotdnum   
  
   
   
--- SYSTEM.TXT 
select 'АБС' KOD_PS, 'ЦАБС "БАНК 21 ВЕК"' NAME_PS from dual


--- CLIENT.TXT
 
select 
  'АБС'                     "KOD_PS" 
  ,idsmr "FIL"                       
  ,icusnum                  "ID"
  ,TRANSLATE(CCUSNAME,'^''','-`')  "NAME" 
  ,dcusopen                 "D_OPEN" 
  ,decode (ccusflag,1,'2',4,'2', 1) "TYPE"
  ,decode (ccusrez,'1','0','2','1','1') "REZ"
  ,ccusnumnal               "INN"
  ,ccuskpp                  "KPP"
  ,ccussnils                "SNILS"
  ,dcusbirthday             "BIRTH"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select PUD.CPUDDOCNAME  from cus_docum,pud where cus_docum.id_doc_tp=PUD.IPUDID and pref='Y' and cus_docum.icusnum=cus.icusnum),(select 'Паспорт'  from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1))
 else
  case 
   when cus.CCUSKSIVA is not null then 'ОГРН'
   when cus.CCUSGOV_CERT is not null then 'Свидетельство о регистрации' 
  end   
end "DOCUM"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select CUS_DOCUM.DOC_SER from cus_docum where pref='Y' and cus_docum.icusnum=cus.icusnum),(select CUS_DOCUM.DOC_SER from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1)) 
 else null 
end "SERIA"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select CUS_DOCUM.DOC_NUM from cus_docum where pref='Y' and cus_docum.icusnum=cus.icusnum),(select CUS_DOCUM.DOC_NUM from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1)) 
 else NVL(cus.CCUSKSIVA,cus.CCUSGOV_CERT)
end "NOM_DOC"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select CUS_DOCUM.DOC_DATE from cus_docum where pref='Y' and cus_docum.icusnum=cus.icusnum),(select CUS_DOCUM.DOC_DATE from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1)) 
 else dcusregdate
end "D_VID"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select CUS_DOCUM.DOC_AGENCY from cus_docum where pref='Y' and cus_docum.icusnum=cus.icusnum),(select CUS_DOCUM.DOC_AGENCY from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1)) 
 else CCUSREGAGENCY
end "KEM_V"
-----------------------------------
,case 
 when ccusflag in ('1','4')
 then nvl((select CUS_DOCUM.DOC_SUBDIV from cus_docum where pref='Y' and cus_docum.icusnum=cus.icusnum),(select CUS_DOCUM.DOC_SUBDIV from cus_docum where ID_DOC_TP=1 and cus_docum.icusnum=cus.icusnum and rownum=1)) 
 else NULL 
end "DEPCODE"
-----------------------------------
,TRANSLATE(cus_util.get_cus_address(icusnum,1) ,'^''','-`')  "ADDR_UR"
,TRANSLATE(nvl(cus_util.get_cus_address(icusnum,2), cus_util.get_cus_address(icusnum,3)) ,'^''','-`') "ADDR_FIZ"
, ICUSOKPO "OKPO"
, cus.CCUSKSIVA "OGRN"
,null "RTS"
,null "FSFR"
,CCUSCUPREGNUM "PF"
,CCUSCUMREGNUM "FSS"
,null "FOMS"
,nvl(CCUSNAL_SERT,ccusregn_old) "NOM_REG"
,CCUSGOV_CERT "NOM_NALOG"
,CCUSKOPF "OKOPF"
,CCUSKFC "OKFS"
,CUS_UTIL.GET_CUS_PHONES_FAX(icusnum,'all',1,',') "TEL"
,CUS_UTIL.GET_CUS_email (icusnum,',') "EMAIL"
,(select ccusname from "cus" c1
         where c1.icusnum = (select id_cus_child from cus_lnk where 
                                                                id_lnk_type = 1 
                                                                and id_cus_parent = cus.icusnum
                                                                and (to_date( date_begin, 'DD.MM.RRRR' ) < sysdate  OR  date_begin is null) 
                                                                and (date_end is null or date_end = (select max(date_end) from cus_lnk where id_lnk_type = 1 and id_cus_parent = cus.icusnum)) 
                                                                and rownum = 1)
         ) as "FIO_ORG"
,(select CUS_UTIL.get_cus_identity_doc(id_cus_child,'line') from cus_lnk where 
                                                                id_lnk_type = 1 
                                                                and id_cus_parent = cus.icusnum
                                                                and (to_date( date_begin, 'DD.MM.RRRR' ) < sysdate  OR  date_begin is null) 
                                                                and (date_end is null or date_end = (select max(date_end) from cus_lnk where id_lnk_type = 1 and id_cus_parent = cus.icusnum)) 
                                                                and rownum = 1
         ) as "PASP_FIO"
from "cus" cus 
where 
  icusnum not in (20000000,80001890,80000765,80001089,80000861)
order by icusnum
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--- «Справочник счетов» (ACCOUNT_ddmmyy.TXT)
select 
'АБС' "KOD_PS"
,idsmr "FIL"                               
,iacccus "ID"
,caccacc "KOD_SCHET"
,caccacc "SCHET"
,null "SCHET_A"
,translate(nvl(caccname,caccname_sh),'^''','-`') "NAME"
,to_char(daccopen,'dd.mm.yyyy') "D_OPEN"
,decode(caccprizn,'З',to_char(daccclose,'dd.mm.yyyy'),null) "D_CLOS"
,caccsio "NOM_DOC" /* дополнить? */ 
,to_char(dacclastoper,'DD.MM.YYYY') "D_DOG"
,ACC_UTIL.GET_ACC_BALANCE(caccacc,cacccur,idsmr,to_date('07.09.2016','dd.mm.yyyy'),'v') * 100 "OST_VAL"
,ACC_UTIL.GET_ACC_BALANCE(caccacc,cacccur,idsmr,to_date('07.09.2016','dd.mm.yyyy'),'r') * 100 "OST_RUR"
--  только действующие блокировки 
,decode((select count(*) from acc_over_sum where caosacc=caccacc and caoscur=cacccur and  caossumtype in ('A','B') and DAOSDELETE is null ) , 0,0,1 )"AREST"
,'Количество  ограничений (арестов) - '||(select count(*) from acc_over_sum where caosacc=caccacc and caoscur=cacccur and  caossumtype in ('A','B') AND DAOSDELETE is null ) "COUNT_OP"
from "acc" acc 
where
(IACCREZERV in (0,2) or IACCREZERV is null) 
/*RS*/    and  (not ( caccprizn='З' and daccclose<to_date('07.09.2016','dd.mm.yyyy') ))  and daccopen<to_date('15.11.2016','dd.mm.yyyy')
/*FIN*/ --  and daccopen<to_date('07.09.2016','dd.mm.yyyy') and (not ( caccprizn='З' and daccclose<to_date('07.09.2013','dd.mm.yyyy') )) /* :date1 -  дата начала периода */      
order by caccacc


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OPER_07.09.13_07.09.16.TXT   -+-  OPER_07.09.16_dd.mm.16.TXT
-------------  С  TRANSLATE-ами
select
'АБС' "KOD_PS"
,idsmr "FIL"  
,to_char(dtrntran,'dd.mm.yyyy') "D_OPER"
,itrndocnum "NOM_DOC"
,to_char(dtrndoc,'dd.mm.yyyy') "D_DOC" 
,to_char(dtrntran,'dd.mm.yyyy hh24:mi:ss') "ASTR_DATE"
,ctrnaccd "KOD_DEBET"
,ctrnaccc "KOD_KRED"
,mtrnsum * 100  "DEBET"
,mtrnsumc * 100 "KREDIT"
,mtrnrsum * 100 "S_RUR"
---
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccc,1,1),'3',ctrnmfoa,null))   "BIK_POL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccc,1,1),'3',ctrncoracca,null))"KS_POL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccc,1,1),'3',ctrnacca,null))   "RS_POL"
,TRANSLATE(decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccc,1,1),'3',ctrnowna,null)) ,'^''','-`')  "NAME_POL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccc,1,1),'3',ctrninna,null))   "INN_POL"
---
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccd,1,1),'3',ctrnmfoa,null))   "BIK_PL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccd,1,1),'3',ctrncoracca,null))"KS_PL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccd,1,1),'3',ctrnacca,null))   "RS_PL"
,TRANSLATE(decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccd,1,1),'3',ctrnowna,null)) ,'^''','-`')  "NAME_PL"
,decode(ctrnmfoa,'044109722',null,decode(substr(ctrnaccd,1,1),'3',ctrninna,null))   "INN_PL"
,TRANSLATE(CTRNPURP,'^''','-`') "NAME"
from "trn" trn
where 
/*FIN*/ --trunc(dtrntran)>=to_date('07.09.2013','dd.mm.yyyy') and trunc(dtrntran)<to_date('07.09.2016','dd.mm.yyyy') 
/*RS*/ -- trunc(dtrntran)>=to_date('07.09.2016','dd.mm.yyyy') and trunc(dtrntran)<to_date('15.11.2016','dd.mm.yyyy') 
/*TEST  */  trunc(dtrntran)>=to_date('15.11.2016','dd.mm.yyyy') 
order by dtrntran
--------------------------------------------------------------------------------------------------------------------------------------

-- arest.txt
select 
iacccus "KOD_CL",
caosacc "SCHET",
translate ( nvl(caccname,CACCNAME_SH) ,'^''','-`') "SCHET_name",
translate ( nvl(ccusname,ccusname_sh) ,'^''','-`') "NAME_CL",
translate ( CAOSCOMMENT ,'^''','-`') "REASON",
to_char(DAOSCREATE,'dd.mm.yyyy') "D_OPEN",
to_char(DAOSDELETE,'dd.mm.yyyy') "D_CLOSE",
decode(MAOSSUMMA,0,1,0) "MODE",
nvl((select replace(prop_value,'.','') from NI_VALUES where prop_name='СумВзыск' and NI_VALUES.PARENT_ID=aos.IAOSID_BASE + 1), decode(CAOSCUR,'RUR',MAOSSUMMA*100, 0)) "Sumrur",
MAOSSUMMA*100 "Sumval"
from "acc_over_sum" aos,"acc" acc ,"cus"  cus
where AOS.CAOSACC=acc.caccacc and cus.icusnum=ACC.IACCCUS  
  and CAOSSUMTYPE in ('A','B') /*--???--*/
  and  DAOSDELETE is null
order by iacccus,DAOSCREATE


