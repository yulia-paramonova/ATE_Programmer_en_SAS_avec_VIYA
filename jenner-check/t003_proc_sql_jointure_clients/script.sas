/* Derived from "ATE - Code SAS 9 with table promotion to CAS.sas":
   the FULL JOIN that unions the two customer sources (join_clients) and the
   INNER JOIN that attaches the quarterly order aggregates and derives client
   age with intck() (JOINTURE_CLIENTS). Kept as written; the three inputs
   (customers1, customers2, commandes_trim) are supplied by autoexec. */

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

proc print data=WORK.JOINTURE_CLIENTS label;
   var Customer_ID Customer_Name age_group age annee_commande trimestre_commande
       nb_commandes SUM_Total_Retail_Price;
run;
