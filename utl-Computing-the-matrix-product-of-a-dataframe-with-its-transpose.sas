%let pgm=utl-computing-the-matrix-product-of-a-sas-dataset-and-its-transpose;

Computing the matrix product of a dataframe with its transpose (dot product)

Github
https://tinyurl.com/wcywfbn
https://github.com/rogerjdeangelis/utl-Computing-the-matrix-product-of-a-dataframe-with-its-transpose

This type of ptoblem is best done with a matrix language like IML or R

Here is the code for R 'have %*% t(have)'

SAS Forum:
https://tinyurl.com/wkggjf8
https://communities.sas.com/t5/SAS-Programming/Multiple-Frequency-Table/m-p/632461

I think this can be done inside DS2 or inside FCMP.
Perhaps you are better off learning IML or R?

other repos

https://github.com/rogerjdeangelis?tab=repositories&q=matrix&type=&language=&sort=

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

options validvarname=upcase;
libname sd1 "d:/sd1";

data sd1.have(compress=no);
    input v1-v4 ;
cards4 ;
1 0 0 1
1 0 1 1
0 1 1 1
0 0 0 0
1 1 1 1
;;;;
run;quit;

SD1.HAVE total obs=5

  V1    V2    V3    V4

   1     0     0     1
   1     0     1     1
   0     1     1     1
   0     0     0     0
   1     1     1     1

*           _
 _ __ _   _| | ___  ___
| '__| | | | |/ _ \/ __|
| |  | |_| | |  __/\__ \
|_|   \__,_|_|\___||___/

;

Mutiply and sum the have datasets times transpose of have

proc transpose data=sd1.have out=havXpo;
var _all_;
run;quit;
                         |                Transpose
                         |
 R  V1    V2    V3    V4 |   R   line1  line2  line2    line3   line4
                         |
 1   1     0     0     1 |   1     1      1       0       0       1
 2   1     0     1     1 |   2     0      0       1       0       1
 3   0     1     1     1 |   3     0      1       1       0       1
 4   0     0     0     0 |   4     1      1       1       0       1
 5   1     1     1     1 |

To get [1,1] below

   R1V1 * R1Line1 + R1V2 * R2Line1  + R1V3 * R3Line1  +  R1V4 * R4Line1

     1  *   1     +  0    *   0     +  0   +   0      +    1   *    1   = 2

Toget Row1Col1 in final matrix

     [,1] [,2] [,3] [,4] [,5]
[1,]    2**  2    1    0    2
[2,]    2    3    2    0    3
[3,]    1    2    3    0    3
[4,]    0    0    0    0    0
[5,]    2    3    3    0    4

** see above

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=5

Obs    V1    V2    V3    V4    V5

 1      2     2     1     0     2
 2      2     3     2     0     3
 3      1     2     3     0     3
 4      0     0     0     0     0
 5      2     3     3     0     4


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_rbegin;
parcards4;
library(haven);
library(SASxport);
library(dplyr);
have<-as.matrix(read_sas("d:/sd1/have.sas7bdat"));
have;
want<-as.data.frame(have %*% t(have));
want;
write.xport(want,file="d:/xpt/want.xpt");
;;;;
%utl_rend;

libname xpt xport "d:/xpt/want.xpt";
data want;
  set xpt.want;
run;quit;
libname xpt clear;

/*
 _ __ ___   __ _  ___ _ __ ___  ___
| `_ ` _ \ / _` |/ __| `__/ _ \/ __|
| | | | | | (_| | (__| | | (_) \__ \
|_| |_| |_|\__,_|\___|_|  \___/|___/

*/
%macro utl_rbegin;
%utlfkil(c:/temp/r_pgm.r);
%utlfkil(c:/temp/r_pgm.log);
filename ft15f001 "c:/temp/r_pgm.r";
%mend utl_rbegin;

%macro utl_rend(returnvar=N);
* EXECUTE THE R PROGRAM;
options noxwait noxsync;
filename rut pipe "D:\r412\R\R-4.1.2\bin\R.exe --vanilla --quiet --no-save < c:/temp/r_pgm.r 2> c:/temp/r_pgm.log";
run;quit;
  data _null_;
    file print;
    infile rut recfm=v lrecl=32756;
    input;
    put _infile_;
    putlog _infile_;
  run;
  filename ft15f001 clear;
  * use the clipboard to create macro variable;
  %if %upcase(%substr(&returnVar.,1,1)) ne N %then %do;
    filename clp clipbrd ;
    data _null_;
     length txt $200;
     infile clp;
     input;
     putlog "macro variable &returnVar = " _infile_;
     call symputx("&returnVar.",_infile_,"G");
    run;quit;
  %end;
data _null_;
  file print;
  infile rut;
  input;
  put _infile_;
  putlog _infile_;
run;quit;
data _null_;
  infile "c:/temp/r_pgm.log";
  input;
  putlog _infile_;
run;quit;
%mend utl_rend;
