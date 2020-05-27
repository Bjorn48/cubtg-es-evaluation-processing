# EvoSuite (un)common behavior test generation evaluation data processing
This repository contains the code that has been used for plotting the data collected for the evaluation of CUBTG, of
which the experiment of which the code for executing the experiment can be found in
[this GitHub repository](https://github.com/Bjorn48/cubtg-es-evaluation). The behavior of the code in this
repository is not strictly specified, and has to be inferred from the code itself. It is provided as is, in the hope
that it can be useful to someone trying to plot this data.

The code in this repository is divided into two parts. The first part parses and transforms the data
outputted by EvoSuite and PIT, and puts it into CSV formats that can be used easily for plotting. This first part 
is written in the Kotlin programming language. The second part saves plots of the data in PDF format. It is written in
the R programming language.

The parsing and transforming code can be found in the folder `/src/main/kotlin/`. The R scripts for plotting the
experiment data can be found in `/src/main/R/`. These scripts require the output files from the previous stage as input.
