/* cap input rows for the captured run */
options obs=100;

/* Source reads ETUDE.ORDERS from an external BASE library
   ("/greenmonthly-export/...Customer-etude/"). That path is not portable,
   so we stand up a small in-memory ETUDE.ORDERS with the same columns and
   types the PROC SQL below reads. Logic in script.sas is unchanged. */
libname ETUDE (work);

data ETUDE.ORDERS;
   infile datalines dsd truncover;
   input Customer_ID Employee_ID Street_ID Order_Date :date9. Delivery_Date :date9.
         Order_ID Order_Type Product_ID Quantity Total_Retail_Price
         CostPrice_Per_Unit Discount Shipping Profit;
   format Order_Date Delivery_Date date9.;
   datalines;
11001,120103,80,15JAN2022,18JAN2022,90001,1,210200,2,109.9,55.2,0,7.5,42.0
11001,120103,80,03APR2022,06APR2022,90002,1,210200,1,54.9,27.6,0,7.5,19.8
11002,120104,81,22JUL2022,25JUL2022,90003,2,220100,3,330.0,180.0,0.10,12.0,90.0
11002,120104,81,09OCT2022,12OCT2022,90004,1,220100,1,110.0,60.0,0,12.0,38.0
11003,120105,82,11FEB2023,14FEB2023,90005,1,230500,5,750.0,400.0,0.05,15.0,300.0
11003,120105,82,28MAY2023,31MAY2023,90006,2,230500,2,300.0,160.0,0,15.0,125.0
11004,120106,83,17AUG2023,20AUG2023,90007,1,240900,4,480.0,240.0,0,10.0,220.0
11004,120106,83,30NOV2023,03DEC2023,90008,1,240900,1,120.0,60.0,0,10.0,50.0
;
run;
