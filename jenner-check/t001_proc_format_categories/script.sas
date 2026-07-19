/* Derived from "ATE - Code SAS 9 with table promotion to CAS.sas":
   the two PROC FORMAT VALUE definitions (CAT_AGE and $Genre), kept
   verbatim, followed by a small demonstration that applies them so the
   captured run shows the formatted categories. */

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

/* Petit jeu de demonstration pour appliquer les deux formats */
data work.demo_clients;
   infile datalines dsd truncover;
   input age Customer_Gender :$1.;
   datalines;
25,F
34,M
61,F
58,M
72,F
19,M
45,F
;
run;

proc print data=work.demo_clients label;
   format age CAT_AGE. Customer_Gender $Genre.;
   var age Customer_Gender;
run;
