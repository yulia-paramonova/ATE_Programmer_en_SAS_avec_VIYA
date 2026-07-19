/* cap input rows for the captured run */
options obs=100;

/* The source builds these inputs from external files:
     - WORK.customers1 via PROC IMPORT of customers1.xls
     - WORK.customers2 via a DATA step reading customers2.txt (BASE library)
     - WORK.commandes_trim from ETUDE.ORDERS (earlier PROC SQL steps)
   None of those files/paths are portable, so we stand up the three inputs
   in memory with the same columns and types the joins in script.sas read.
   The join logic in script.sas is unchanged. */

data WORK.customers1;
   infile datalines dsd truncover;
   input Customer_ID Customer_Gender :$1. Customer_Name :$20.
         Customer_First_Name :$12. Customer_Last_Name :$12. Customer_Country :$12.;
   datalines;
11001,F,Dubois Marie,Marie,Dubois,France
11002,M,Martin Paul,Paul,Martin,France
11003,F,Bernard Claire,Claire,Bernard,Belgique
11004,M,Petit Jean,Jean,Petit,Suisse
11005,F,Roux Alice,Alice,Roux,France
;
run;

data WORK.customers2;
   infile datalines dsd truncover;
   input id birthdate :date9. age_group :$12. type :$48. group :$29.;
   format birthdate date9.;
   datalines;
11001,14MAR1990,30-60 ans,Particulier,Groupe A
11002,02JUL1975,30-60 ans,Professionnel,Groupe B
11003,28MAY1998,Moins de 30 ans,Particulier,Groupe A
11004,17AUG1958,Plus de 60 ans,Professionnel,Groupe C
11006,09NOV1965,30-60 ans,Particulier,Groupe B
;
run;

data WORK.commandes_trim;
   infile datalines dsd truncover;
   input Customer_ID annee_commande trimestre_commande nb_commandes SUM_Total_Retail_Price;
   format SUM_Total_Retail_Price dollar13.2;
   datalines;
11001,2022,1,2,109.90
11001,2022,2,1,54.90
11002,2022,3,3,330.00
11003,2023,1,5,750.00
11004,2023,3,4,480.00
;
run;
