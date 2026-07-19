/* Derived from "ATE - Code SAS 9 with table promotion to CAS.sas":
   the two PROC SQL steps that derive order year/quarter (annee_trimestre)
   and aggregate quantity and retail price by customer and quarter
   (commandes_trim). Kept as written; ETUDE.ORDERS is supplied by autoexec. */

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

proc print data=WORK.commandes_trim label;
run;
