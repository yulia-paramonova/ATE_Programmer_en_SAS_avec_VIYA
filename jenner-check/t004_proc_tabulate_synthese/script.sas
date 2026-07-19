/* Derived from "ATE - Code SAS 9 with table promotion to CAS.sas":
   the PROC TABULATE step that cross-tabulates total retail price and order
   count by client age (rows) and gender (columns), with row and column
   totals. Kept as written; JOINTURE_CLIENTS is supplied by autoexec. */

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
