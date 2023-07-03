LIBNAME ETUDE BASE "/greenmonthly-export/ssemonthly/homes/Yulia.Paramonova@sas.com/Customer-etude/" ;

PROC FORMAT 
	LIB=WORK
; 
		VALUE CAT_AGE
			0 -< 30 = "Moins de 30 ans"
			30 - 60 = "30-60 ans"
			60 <-< 100 = "Plus de 60 ans";
RUN; 

PROC FORMAT 
	LIB=WORK
; 
		VALUE $Genre
			"F" = "Femmes"
			"M" = "Hommes";
RUN; 

FILENAME _flw_fr "/greenmonthly-export/ssemonthly/homes/Yulia.Paramonova@sas.com/Customer-etude/customers2.txt" encoding="UTF-8";

data WORK.customers2;
   
   attrib
   id length = 8 format = BEST9. label = "id"
   birthdate length = 8 format = DATE9. informat = DATE9. label = "birthdate"
   age_group length = $12 label = "age_group"
   type length = $48 label = "type"
   group length = $29 label = "group";
   infile _flw_fr
   lrecl = 108
   encoding ="UTF-8"
   firstobs = 3
   pad
   truncover;
   
   input
   id 1-9
   @10 birthdate DATE9.
   age_group $ 20-31
   type $ 32-79
   group $ 80-108;
RUN;

FILENAME _flw_fr CLEAR;

FILENAME _flw_fr "/greenmonthly-export/ssemonthly/homes/Yulia.Paramonova@sas.com/Customer-etude/customers1.xls" encoding="UTF-8";
options validvarname=V7;
proc IMPORT datafile = _flw_fr OUT = WORK.customers1 dbms = XLS;
getNames = YES;
range = "CUSTOMERS$0:0";
RUN;


PROC SQL;
   CREATE TABLE WORK.annee_trimestre AS
   SELECT 
      (year(order_date)) AS annee_commande,
      (qtr(order_date)) AS trimestre_commande,
      t1.Customer_ID LABEL='Customer ID' FORMAT=12.,
      t1.Employee_ID LABEL='Employee ID' FORMAT=12.,
      t1.Street_ID LABEL='Street ID' FORMAT=12.,
      t1.Order_Date LABEL='Date Order was placed by Customer' FORMAT=DATE9.,
      t1.Delivery_Date LABEL='Date Order was Delivered' FORMAT=DATE9.,
      t1.Order_ID LABEL='Order ID' FORMAT=12.,
      t1.Order_Type LABEL='Order Type',
      t1.Product_ID LABEL='Product ID' FORMAT=12.,
      t1.Quantity LABEL='Quantity Ordered',
      t1.Total_Retail_Price LABEL='Total Retail Price for This Product' FORMAT=DOLLAR13.2,
      t1.CostPrice_Per_Unit LABEL='Cost Price Per Unit' FORMAT=DOLLAR13.2,
      t1.Discount LABEL='Discount in percent of Normal Total Retail Price' FORMAT=PERCENT6.,
      t1.Shipping FORMAT=DOLLAR8.2,
      t1.Profit FORMAT=DOLLAR10.2
   FROM
      ETUDE.ORDERS t1
   ;
QUIT;
RUN;


PROC SQL;
   CREATE TABLE WORK.commandes_trim AS
   SELECT DISTINCT
      t1.Customer_ID LABEL='Customer ID',
      t1.annee_commande,
      t1.trimestre_commande,
      (SUM(t1.Quantity)) AS nb_commandes,
      (SUM(t1.Total_Retail_Price)) FORMAT=DOLLAR13.2 AS SUM_Total_Retail_Price
   FROM
      WORK.ANNEE_TRIMESTRE t1

   GROUP BY
      t1.Customer_ID,
      t1.annee_commande,
      t1.trimestre_commande
   ;
QUIT;
RUN;


PROC SQL;
   CREATE TABLE WORK.join_clients AS
   SELECT 
      t1.Customer_ID LABEL='Customer ID' FORMAT=BEST12.,
      t1.Customer_Gender LABEL='Customer Gender' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Name LABEL='Customer Name' FORMAT=$20. INFORMAT=$20.,
      t1.Customer_First_Name LABEL='Customer First Name' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Last_Name LABEL='Customer Last Name' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Country LABEL='Customer Country' FORMAT=$12. INFORMAT=$12.,
      t2.birthdate FORMAT=DATE9. INFORMAT=DATE9.,
      t2.age_group,
      t2.'type'n,
      t2.'group'n
   FROM
      WORK.customers1 t1
         FULL JOIN WORK.customers2 t2 ON (t1.Customer_ID= t2.id)
   ;
QUIT;
RUN;


PROC SQL;
   CREATE TABLE WORK.JOINTURE_CLIENTS AS
   SELECT 
      t1.Customer_ID LABEL='Customer ID' FORMAT=BEST12.,
      t1.Customer_Gender LABEL='Customer Gender' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Name LABEL='Customer Name' FORMAT=$20. INFORMAT=$20.,
      t1.Customer_First_Name LABEL='Customer First Name' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Last_Name LABEL='Customer Last Name' FORMAT=$12. INFORMAT=$12.,
      t1.Customer_Country LABEL='Customer Country' FORMAT=$12. INFORMAT=$12.,
      t1.birthdate FORMAT=DATE9. INFORMAT=DATE9.,
      t1.age_group,
      ((intck('year', t1.birthdate, today(), 'c') - 15)) AS age,
      t1.'type'n,
      t1.'group'n,
      t2.annee_commande,
      t2.trimestre_commande,
      t2.nb_commandes,
      t2.SUM_Total_Retail_Price FORMAT=DOLLAR13.2
   FROM
      WORK.join_clients t1
         INNER JOIN WORK.commandes_trim t2 ON (t1.Customer_ID = t2.Customer_ID)
   ;
QUIT;
RUN;

PROC TABULATE
DATA=WORK.JOINTURE_CLIENTS
	
	;
	
	VAR SUM_Total_Retail_Price nb_commandes;
	CLASS age /	ORDER=UNFORMATTED MISSING;
	CLASS Customer_Gender /	ORDER=UNFORMATTED MISSING;
	TABLE 
		/* ROW Statement */
		age 
		all = 'Total'  ,
		/* COLUMN Statement */
		Customer_Gender=' ' *(SUM_total_retail_price * Sum=' ' nb_commandes * Sum=' ' )
		all = 'Total'  *(SUM_total_retail_price * Sum=' ' nb_commandes * Sum=' ' ) 		;
	;

RUN;


PROC TABULATE
DATA=WORK.JOINTURE_CLIENTS
	
	;
	
	VAR SUM_Total_Retail_Price nb_commandes;
	CLASS age /	ORDER=UNFORMATTED MISSING MLF;
	CLASS Customer_Gender /	ORDER=UNFORMATTED MISSING;

	FORMAT
		age 	CAT_AGE.
		Customer_Gender 	$GENRE.;

	TABLE /* Dimension de ligne */
age*
  Sum 
ALL={LABEL="Total (ALL)"}*
  Sum,
/* Dimension de colonne */
Customer_Gender*(
  nb_commandes 
  SUM_total_retail_price) 		;
	;

RUN;

proc casutil;
   droptable casdata="FRAYUP_ETUDECLIENTSJOINTURE" incaslib="SWEE" quiet;
run;

data SWEE.FRAYUP_ETUDECLIENTSJOINTURE(promote=YES);
set WORK.JOINTURE_CLIENTS;
run; 

