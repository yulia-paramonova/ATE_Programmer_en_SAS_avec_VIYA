cas CASAUTO terminate ; 

/*Création d'une session pour se connecter à CAS*/
cas MySession sessopts=(caslib=casuser timeout=3600 metrics=true);

/*Visualiser l'ensemble des caslibs disponibles*/
caslib _all_ list ; 

/*Assigner une librairie CAS*/
libname casuser cas caslib=casuser;

/*Assigner l'ensemble des librairies CAS*/
caslib _all_ assign ; 

/*Lister les tables en mémoire*/ 
proc casutil incaslib="CASUSER";
   list tables;
run;

/*Lister les tables disponibles*/ 
proc casutil incaslib="CASUSER";
   list files;
run;

/*Chargement d'une table SAS en mémoire et promotion*/ 
proc casutil;
	load data=sqldatabase.HMEQ_XY 
	outcaslib="CASUSER" casout="HMEQ_XY" promote;
run;

/*Chargement d'une table CAS*/ 
proc casutil;
	load casdata="HMEQ_XY.sashdat" incaslib="CASUSER" 
	outcaslib="CASUSER" casout="HMEQ_XY";
run;

/*Promotion d'une table CAS*/ 
proc casutil;
	promote casdata="HMEQ_XY" incaslib="CASUSER" 
	outcaslib="CASUSER" casout="HMEQ_XY";
run;

/*Fin de session*/ 
cas mySession terminate ; 
