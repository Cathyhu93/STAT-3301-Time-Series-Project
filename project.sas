/*Import an external data set*/
data tsnew;
infile "D:\data.xlsx";
input t z;
run;

/* Draw the time plot */ 
symbol i=join v=none; 
proc gplot data=tsnew; 
plot z*t; 
run; 
quit;
	
/* Identify arima models on raw data */ 
proc arima data=tsnew;
 identify alpha=0.05 var=z nlag=25;
run;

/*check log transformation*/
data tslog;
set tsnew;
lz=log(z);
run;

symbol i=join v=none; 
proc gplot data=tslog; 
plot lz*t; 
run; 
quit;
proc arima data=tslog;
 identify alpha=0.05 var=lz nlag=25;
run;

/* Identify arima models on d=1 data */
proc arima data=tsnew;
 identify alpha=0.05 var=z(1) nlag=25;
run;

/* Take seasonal differencing since the sample ACF decays slowly especially after periods */
identify alpha=0.05 var=z(1,12) stationarity=(dickey=4);
run;

/* Estimate the ARIMA(0,1,1)X(0,1,1)12 model to the data */
estimate method=ml q=(1)(12) plot;
run;
 forecast out=fore0 lead=0 id=t;
run;

/* Draw the time plot of residual*/
symbol i=join v=none;
proc gplot data=fore0;
 plot residual*t;
run;
quit;
/* Perform the normality test on residuals*/
proc univariate data=fore0 normal plot;
var residual;
run;

/*overfitting*/
proc arima data=tsnew;
 identify var=z(1,12) nlag=25;
run;
/*ARIMA(1,1,1)X(0,1,1)12 model */
 estimate method=ml p=(1) q=(1)(12) plot;
run;
/*ARIMA(0,1,2)X(0,1,1)12 model */
 estimate method=ml q=(1)(2)(12) plot;
run;
/*ARIMA(0,1,1)X(1,1,1)12 model */
 estimate method=ml p=(12) q=(1)(12) plot;
run;
/*ARIMA(0,1,1)X(0,1,2)12 model */
 estimate method=ml q=(1)(12)(24) plot;
run;


/*overfitting to new model: ARIMA(1,1,1)X(0,1,1)12 model */
proc arima data=tsnew;
 identify var=z(1,12) nlag=25;
run;

/*ARIMA(1,1,2)X(0,1,1)12 model */
 estimate method=ml p=(1) q=(1)(2)(12) plot;
run;

 estimate method=ml p=(1) q=(1)(2)(3)(12) plot;
run;

 estimate method=ml p=(1)(2) q=(1)(2)(12) plot;
run;

/*ARIMA(2,1,1)X(0,1,1)12 model */
 estimate method=ml p=(1)(2) q=(1)(12) plot;
run;

 estimate method=ml p=(1)(2) q=(1)(2)(12) plot;
run;

 estimate method=ml p=(1)(2)(3) q=(1)(12) plot;
run;

/* Do forecasting by using the fitted ARIMA(2,1,1)x (0,1,1)12 model */
proc arima data=tsnew;
 identify var=z(1,12) nlag=25;
run;
 estimate method=ml p=(1)(2) q=(1)(12) plot;
run;
 forecast out=fore5 lead=5 id=t interval=month;
run;
quit;
/* Draw the forecasting time plot */
symbol i=join v=none;
proc gplot data=fore5;
 plot z*t=1 forecast*t=2 l95*t=3 u95*t=3/overlay;
run; 
quit;
