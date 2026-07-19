/* cap input rows for the captured run */
options obs=100;

/* The source runs PROC TABULATE over WORK.JOINTURE_CLIENTS (built by the
   earlier join chain). Here we supply a small JOINTURE_CLIENTS with the
   columns TABULATE reads (age, Customer_Gender, nb_commandes,
   SUM_Total_Retail_Price), so the table logic in script.sas runs unchanged. */

data WORK.JOINTURE_CLIENTS;
   infile datalines dsd truncover;
   input age Customer_Gender :$1. nb_commandes SUM_Total_Retail_Price;
   format SUM_Total_Retail_Price dollar13.2;
   datalines;
21,F,3,164.80
36,M,3,330.00
13,F,5,750.00
53,M,4,480.00
28,F,2,210.00
64,M,1,120.00
45,F,6,540.00
33,M,2,275.00
;
run;
