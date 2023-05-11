select * from "lookupSchema".tblpatdesStage;
drop table "lookupSchema".tblpatdesstage;

CREATE TABLE "lookupSchema".tblpatdesstage (
	row_number numeric(15) not null,
	pdescid serial NOT NULL,
	summary varchar(50) NOT NULL,
	heightinft numeric(15,2) NOT NULL,
	weightinkg numeric(15,2) NOT NULL,
	bloodpressure int4 NOT NULL,
	patientid int4 NOT NULL,
	avgweightinkg numeric(10,2) NOT NULL,
	avgheightinft numeric(10,2) NOT NULL,
	weightclass varchar(50) NOT NULL,
	heightclass varchar(50) NOT NULL,
	dense_summary numeric(15) not null,
	ntilebphighlevel varchar(20) not null,
	ntilebplowlevel varchar(20) not null,
	CONSTRAINT tblpatdesstage_pkey PRIMARY KEY (pdescid)
);

CREATE OR REPLACE PROCEDURE "lookupSchema".patdesproc()
 LANGUAGE plpgsql
AS $procedure$
	declare result varchar;
begin
	insert into "lookupSchema".tblpatdesStage
select x.row_number ,x.pdescid , x.summary , x.heightInFt, x.weightinkg, x.bloodpressure, x.patientId ,
ROUND (avg(x.weightinkg) over (), 2) as AVG_weightInKG,
ROUND (avg(x.heightinft) over (), 2) as AVG_heightinFT,
case
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) > 0 THEN 'Overweight'
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) < 0 THEN 'Underweight'
ELSE 'normal'
END as weightClass,
case
WHEN (heightinft - AVG(heightinft) OVER () ) > 0 THEN 'Over'
WHEN (heightinft - AVG(heightinft) OVER () ) < 0 THEN 'Under'
ELSE 'normal'
END as heightClass,  x.dense_summary ,
case
when x.ntile_bpsystolic = 3 then 'Critical'
when x.ntile_bpsystolic = 2 then 'High'
else 'Normal'
end as ntileBpHighLevel,
case
when x.ntile_bpdystolic = 3 then 'Critical'
when x.ntile_bpdystolic = 2 then 'Low'
else 'Normal'
end as ntileBpLowLevel
from (
	select pdescid, summary, 
case
WHEN heightIn = 'in' THEN round(height/12,2)
WHEN heightIn = 'cm' then round(height/30.48,2)
ELSE height 
END as heightInFt, 
case
WHEN weightIn = 'pd' THEN round(weight * 0.45,2)
ELSE weight 
END as weightInKg, 
case
WHEN bpSystolic > 110 AND bpDystolic > 90 then 1
WHEN bpSystolic < 90 AND bpDystolic < 60 then  -1
ELSE 0
END as bloodpressure, patientid,
 row_number() over() as row_number,
 dense_rank() over(order by summary) as dense_summary,
 NTILE(3) over(order by bpsystolic) as ntile_bpsystolic,
 NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
from "medicalHealthCare".tblpatdes) x;
end;
$procedure$
;
call "lookupSchema".patdesproc();

select x.pdescid , x.summary , x.weightinkg, x.heightInFt, x.bloodpressure, x.patientId ,
ROUND (avg(x.weightinkg) over (), 2) as AVG_weightInKG,
ROUND (avg(x.heightinft) over (), 2) as AVG_heightinFT,
case
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) > 0 THEN 'Overweight'
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) < 0 THEN 'Underweight'
ELSE 'normal'
END as weightClass,
case
WHEN (heightinft - AVG(heightinft) OVER () ) > 0 THEN 'Over'
WHEN (heightinft - AVG(heightinft) OVER () ) < 0 THEN 'Under'
ELSE 'normal'
END as heightClass, x.row_number , x.dense_summary ,
case
when x.ntile_bpsystolic = 3 then 'Critical'
when x.ntile_bpsystolic = 2 then 'High'
else 'Normal'
end as ntileBpHighLevel,
case
when x.ntile_bpdystolic = 3 then 'Critical'
when x.ntile_bpdystolic = 2 then 'Low'
else 'Normal'
end as ntileBpLowLevel
from (
	select pdescid, summary, 
case
WHEN heightIn = 'in' THEN round(height/12,2)
WHEN heightIn = 'cm' then round(height/30.48,2)
ELSE height 
END as heightInFt, 
case
WHEN weightIn = 'pd' THEN round(weight * 0.45,2)
ELSE weight 
END as weightInKg, 
case
WHEN bpSystolic > 110 AND bpDystolic > 90 then 1
WHEN bpSystolic < 90 AND bpDystolic < 60 then  -1
ELSE 0
END as bloodpressure, patientid,
 row_number() over() as row_number,
 dense_rank() over(order by summary) as dense_summary,
 NTILE(3) over(order by bpsystolic) as ntile_bpsystolic,
 NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
from "medicalHealthCare".tblpatdes) x;
end;

select 
	--row_number() over(partition by summary) as row_number,
    row_number() over() as row_number,
	pdescid , summary , 
	dense_rank() over(order by summary) as dense_summary, height ,heightin , weight , weightin ,patientid ,
	dense_rank() over(order by summary) as dense_summary, bpsystolic ,
	NTILE(3) over(order by bpsystolic) as ntile_bpsystolic, bpdystolic ,
	NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
	from "medicalHealthCare".tblpatdes;

-------------------------------------------TBLDOCSPECIALIZATION-----------------------------------------------------
select * from "medicalHealthCare".tbldocspec;
select 
	specialization,
	degree,
	yearsofexp,
	row_number() over() as row_number ,
	row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
	dense_rank() over(order by specialization) as dense_rank_speicialization,
	dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec;

CREATE TABLE "lookupSchema".tbldocspecStage (
	rowNumber numeric(15) not null,
	specid int4 NOT NULL,
	specialization varchar(50) NOT NULL,
	degree varchar(50) NOT NULL,
	doctorid int4 NOT NULL,
	yearsofexp numeric(15) NULL,
	CountExpByDegree numeric(15) not null,
	dense_rank_specialization numeric(15) not null,
	dense_rank_degree numeric(15) not null,
	CONSTRAINT tbldocspec_pkey PRIMARY KEY (specid)
);


CREATE OR REPLACE PROCEDURE "lookupSchema".patdocspecproc()
 LANGUAGE plpgsql
AS $procedure$
begin
	insert into "lookupSchema".tbldocspecstage
select x.row_number ,x.specid , x.specialization , x.degree, x.doctorid, x.yearsofexp, x.CountEXPbyDegree,
x.dense_rank_speicialization, x.dense_rank_degree
from (
	select specid ,specialization, doctorid,
	degree,
	yearsofexp,
row_number() over() as row_number ,
row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
dense_rank() over(order by specialization) as dense_rank_speicialization,
dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec) x;
end;
$procedure$
;
call "lookupSchema".patdocspecproc();
truncate table "medicalHealthCare".tbldocspec;

select * from "lookupSchema".tbldocspecStage;
select * from 
CREATE TABLE "medicalHealthCare".tbldocspec (
	specid int4,
	specialization varchar(50) ,
	degree varchar(50),
	doctorid int4 
	--CONSTRAINT tbldocspec_pkey PRIMARY KEY (specid)
);


drop table tbldocspecStage;
select * from "medicalHealthCare".tbldocspec;
select * from "lookupSchema".tbldocspecstage;

delete from "medicalHealthCare".tbldocspec where specid > 1000;


select x.row_number ,x.specid , x.specialization , x.degree, x.doctorid, x.yearsofexp, x.CountEXPbyDegree,
x.dense_rank_speicialization, x.dense_rank_degree
from (
	select specid ,specialization, doctorid,
	degree,
	yearsofexp,
row_number() over() as row_number ,
row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
dense_rank() over(order by specialization) as dense_rank_speicialization,
dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec) x;


select * from "medicalHealthCare".tbltest;


------------------------------------------------------------tblBILLING--------------------------------------------------------------
select * from "medicalHealthCare".tblbilling;

CREATE TABLE "lookupSchema".tblbillingstage2 (
	billid int8 NOT NULL,
	row_number numeric(15) not null,
	patientid int8 NOT NULL,
	doctorid int8 NOT NULL,
	dateofadmission date NOT NULL,
	dateofdischarge date NULL,
	stayduration numeric(50) NULL,
	dateofbill date NOT NULL,
	dateofpayment date NOT NULL,
	ntileDateOfPayment numeric(15) not null,
	ntileTotalAmount numeric(15) not null,
	amountdollar numeric NOT NULL,
	CONSTRAINT tblbillingstage2_pkey PRIMARY KEY (billid)
);
select 
    row_number() over() as row_number,
	dateofadmission , dateofdischarge , dateofbill, dateofpayment ,
	NTILE(4) over(partition by EXTRACT(YEAR FROM dateofpayment) order by totalamount) as ntile_dateOfPayment , totalamount ,
	NTILE(6) over(order by totalamount) as ntile_totalamount
	from "medicalHealthCare".tblbilling;

CREATE OR REPLACE PROCEDURE "lookupSchema".billingproc()
 LANGUAGE plpgsql
AS $procedure$dbeaver
begin
	insert into "lookupSchema".tblbillingstage
select x.billid , x.patientid ,x.doctorid, x.dateofadmission , x.dateofdischarge,x.stayduration, x.dateofbill, x.dateofpayment,
"lookupSchema".calculateVatTax(x.totalamount, x.tax, x.vat)
from (
	select billid, patientid, doctorid, dateofadmission ,dateofdischarge,
case 
WHEN dateofdischarge is null then null
when ( dateofdischarge - dateofadmission) >= 0 then dateofdischarge - dateofadmission
when ( dateofdischarge - dateofadmission) < 0 then 0
END as stayduration ,dateofbill , dateofpayment , tax , vat,
case 
when currency = 'Rs' then totalamount / 130
when currency = 'Pound' then totalamount * 0.8
else totalamount 
end as totalamount
from "medicalHealthCare".tblbilling
) x;	
end;
$procedure$
;














select * from "lookupSchema".tblpatdesStage;
drop table "lookupSchema".tblpatdesstage;

CREATE TABLE "lookupSchema".tblpatdesstage (
	row_number numeric(15) not null,
	pdescid serial NOT NULL,
	summary varchar(50) NOT NULL,
	heightinft numeric(15,2) NOT NULL,
	weightinkg numeric(15,2) NOT NULL,
	bloodpressure int4 NOT NULL,
	patientid int4 NOT NULL,
	avgweightinkg numeric(10,2) NOT NULL,
	avgheightinft numeric(10,2) NOT NULL,
	weightclass varchar(50) NOT NULL,
	heightclass varchar(50) NOT NULL,
	dense_summary numeric(15) not null,
	ntilebphighlevel varchar(20) not null,
	ntilebplowlevel varchar(20) not null,
	CONSTRAINT tblpatdesstage_pkey PRIMARY KEY (pdescid)
);

CREATE OR REPLACE PROCEDURE "lookupSchema".patdesproc()
 LANGUAGE plpgsql
AS $procedure$
	declare result varchar;
begin
	insert into "lookupSchema".tblpatdesStage
select x.row_number ,x.pdescid , x.summary , x.heightInFt, x.weightinkg, x.bloodpressure, x.patientId ,
ROUND (avg(x.weightinkg) over (), 2) as AVG_weightInKG,
ROUND (avg(x.heightinft) over (), 2) as AVG_heightinFT,
case
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) > 0 THEN 'Overweight'
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) < 0 THEN 'Underweight'
ELSE 'normal'
END as weightClass,
case
WHEN (heightinft - AVG(heightinft) OVER () ) > 0 THEN 'Over'
WHEN (heightinft - AVG(heightinft) OVER () ) < 0 THEN 'Under'
ELSE 'normal'
END as heightClass,  x.dense_summary ,
case
when x.ntile_bpsystolic = 3 then 'Critical'
when x.ntile_bpsystolic = 2 then 'High'
else 'Normal'
end as ntileBpHighLevel,
case
when x.ntile_bpdystolic = 3 then 'Critical'
when x.ntile_bpdystolic = 2 then 'Low'
else 'Normal'
end as ntileBpLowLevel
from (
	select pdescid, summary, 
case
WHEN heightIn = 'in' THEN round(height/12,2)
WHEN heightIn = 'cm' then round(height/30.48,2)
ELSE height 
END as heightInFt, 
case
WHEN weightIn = 'pd' THEN round(weight * 0.45,2)
ELSE weight 
END as weightInKg, 
case
WHEN bpSystolic > 110 AND bpDystolic > 90 then 1
WHEN bpSystolic < 90 AND bpDystolic < 60 then  -1
ELSE 0
END as bloodpressure, patientid,
 row_number() over() as row_number,
 dense_rank() over(order by summary) as dense_summary,
 NTILE(3) over(order by bpsystolic) as ntile_bpsystolic,
 NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
from "medicalHealthCare".tblpatdes) x;
end;
$procedure$
;
call "lookupSchema".patdesproc();

select x.pdescid , x.summary , x.weightinkg, x.heightInFt, x.bloodpressure, x.patientId ,
ROUND (avg(x.weightinkg) over (), 2) as AVG_weightInKG,
ROUND (avg(x.heightinft) over (), 2) as AVG_heightinFT,
case
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) > 0 THEN 'Overweight'
WHEN (x.weightinkg - AVG(x.weightinkg) OVER () ) < 0 THEN 'Underweight'
ELSE 'normal'
END as weightClass,
case
WHEN (heightinft - AVG(heightinft) OVER () ) > 0 THEN 'Over'
WHEN (heightinft - AVG(heightinft) OVER () ) < 0 THEN 'Under'
ELSE 'normal'
END as heightClass, x.row_number , x.dense_summary ,
case
when x.ntile_bpsystolic = 3 then 'Critical'
when x.ntile_bpsystolic = 2 then 'High'
else 'Normal'
end as ntileBpHighLevel,
case
when x.ntile_bpdystolic = 3 then 'Critical'
when x.ntile_bpdystolic = 2 then 'Low'
else 'Normal'
end as ntileBpLowLevel
from (
	select pdescid, summary, 
case
WHEN heightIn = 'in' THEN round(height/12,2)
WHEN heightIn = 'cm' then round(height/30.48,2)
ELSE height 
END as heightInFt, 
case
WHEN weightIn = 'pd' THEN round(weight * 0.45,2)
ELSE weight 
END as weightInKg, 
case
WHEN bpSystolic > 110 AND bpDystolic > 90 then 1
WHEN bpSystolic < 90 AND bpDystolic < 60 then  -1
ELSE 0
END as bloodpressure, patientid,
 row_number() over() as row_number,
 dense_rank() over(order by summary) as dense_summary,
 NTILE(3) over(order by bpsystolic) as ntile_bpsystolic,
 NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
from "medicalHealthCare".tblpatdes) x;
end;

select 
	--row_number() over(partition by summary) as row_number,
    row_number() over() as row_number,
	pdescid , summary , 
	dense_rank() over(order by summary) as dense_summary, height ,heightin , weight , weightin ,patientid ,
	dense_rank() over(order by summary) as dense_summary, bpsystolic ,
	NTILE(3) over(order by bpsystolic) as ntile_bpsystolic, bpdystolic ,
	NTILE(3) over(order by bpdystolic) as ntile_bpdystolic
	from "medicalHealthCare".tblpatdes;

-------------------------------------------TBLDOCSPECIALIZATION-----------------------------------------------------
select * from "medicalHealthCare".tbldocspec;
select 
	specialization,
	degree,
	yearsofexp,
	row_number() over() as row_number ,
	row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
	dense_rank() over(order by specialization) as dense_rank_speicialization,
	dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec;

CREATE TABLE "lookupSchema".tbldocspecStage (
	rowNumber numeric(15) not null,
	specid int4 NOT NULL,
	specialization varchar(50) NOT NULL,
	degree varchar(50) NOT NULL,
	doctorid int4 NOT NULL,
	yearsofexp numeric(15) NULL,
	CountExpByDegree numeric(15) not null,
	dense_rank_specialization numeric(15) not null,
	dense_rank_degree numeric(15) not null,
	CONSTRAINT tbldocspec_pkey PRIMARY KEY (specid)
);


CREATE OR REPLACE PROCEDURE "lookupSchema".patdocspecproc()
 LANGUAGE plpgsql
AS $procedure$
begin
	insert into "lookupSchema".tbldocspecstage
select x.row_number ,x.specid , x.specialization , x.degree, x.doctorid, x.yearsofexp, x.CountEXPbyDegree,
x.dense_rank_speicialization, x.dense_rank_degree
from (
	select specid ,specialization, doctorid,
	degree,
	yearsofexp,
row_number() over() as row_number ,
row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
dense_rank() over(order by specialization) as dense_rank_speicialization,
dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec) x;
end;
$procedure$
;
call "lookupSchema".patdocspecproc();
truncate table "medicalHealthCare".tbldocspec;

select * from "lookupSchema".tbldocspecStage;
select * from 
CREATE TABLE "medicalHealthCare".tbldocspec (
	specid int4,
	specialization varchar(50) ,
	degree varchar(50),
	doctorid int4 
	--CONSTRAINT tbldocspec_pkey PRIMARY KEY (specid)
);


drop table tbldocspecStage;
select * from "medicalHealthCare".tbldocspec;
select * from "lookupSchema".tbldocspecstage;

delete from "medicalHealthCare".tbldocspec where specid > 1000;


select x.row_number ,x.specid , x.specialization , x.degree, x.doctorid, x.yearsofexp, x.CountEXPbyDegree,
x.dense_rank_speicialization, x.dense_rank_degree
from (
	select specid ,specialization, doctorid,
	degree,
	yearsofexp,
row_number() over() as row_number ,
row_number() over(partition by degree, yearsofexp order by yearsofexp) as CountEXPbyDegree,
dense_rank() over(order by specialization) as dense_rank_speicialization,
dense_rank() over(order by degree) as dense_rank_degree
from "medicalHealthCare".tbldocspec) x;


select * from "medicalHealthCare".tbltest;


------------------------------------------------------------tblBILLING--------------------------------------------------------------
select * from "medicalHealthCare".tblbilling;

CREATE TABLE "lookupSchema".tblbillingstage2 (
	billid int8 NOT NULL,
	row_number numeric(15) not null,
	patientid int8 NOT NULL,
	doctorid int8 NOT NULL,
	dateofadmission date NOT NULL,
	dateofdischarge date NULL,
	stayduration numeric(50) NULL,
	dateofbill date NOT NULL,
	dateofpayment date NOT NULL,
	ntileDateOfPayment numeric(15) not null,
	ntileTotalAmount numeric(15) not null,
	amountdollar numeric NOT NULL,
	CONSTRAINT tblbillingstage2_pkey PRIMARY KEY (billid)
);
select 
    row_number() over() as row_number,
	dateofadmission , dateofdischarge , dateofbill, dateofpayment ,
	NTILE(4) over(partition by EXTRACT(YEAR FROM dateofpayment) order by totalamount) as ntile_dateOfPayment , totalamount ,
	NTILE(6) over(order by totalamount) as ntile_totalamount
	from "medicalHealthCare".tblbilling;

CREATE OR REPLACE PROCEDURE "lookupSchema".billingproc()
 LANGUAGE plpgsql
AS $procedure$dbeaver
begin
	insert into "lookupSchema".tblbillingstage
select x.billid , x.patientid ,x.doctorid, x.dateofadmission , x.dateofdischarge,x.stayduration, x.dateofbill, x.dateofpayment,
"lookupSchema".calculateVatTax(x.totalamount, x.tax, x.vat)
from (
	select billid, patientid, doctorid, dateofadmission ,dateofdischarge,
case 
WHEN dateofdischarge is null then null
when ( dateofdischarge - dateofadmission) >= 0 then dateofdischarge - dateofadmission
when ( dateofdischarge - dateofadmission) < 0 then 0
END as stayduration ,dateofbill , dateofpayment , tax , vat,
case 
when currency = 'Rs' then totalamount / 130
when currency = 'Pound' then totalamount * 0.8
else totalamount 
end as totalamount
from "medicalHealthCare".tblbilling
) x;	
end;
$procedure$
;






































