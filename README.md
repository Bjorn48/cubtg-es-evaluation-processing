**Note: this README is outdated**

# EvoSuite (un)common behavior test generation evaluation data processing
This repository contains scripts for processing the output data from the EvoSuite (un)common behavior test generation
evaluation experiment. The code for executing the experiment can be found in
[this GitHub repository](https://github.com/Bjorn48/cubtg-es-evaluation).

The code in this repository can be divided into two parts. The first part parses and transforms the data
outputted by EvoSuite and PIT, and puts it into CSV formats that can be used easily for plotting. This first part 
is written in the Kotlin programming language. The second part saves plots of the data in SVG format. It is written in
the R programming language.

## Parsing and transforming
The parsing and transforming code can be found in the folder `/src/main/kotlin/`. It contains three files that perform
different operations on the data. Each of them contains a `main` function, and they should be executed in a certain
order. They are described below, in the order in which they should be executed.

### Combining test case branch coverage files
The EvoSuite version that is used outputs the branch coverage of each test case in a separate file for each test case.
This results in a massive amount of files, which is slow to work with, especially for home devices. The
`ProcessTCBranchCov.kts` script combines those files into one large file. It takes the following arguments in the
following order:

1. Folder containing the test case branch coverage files outputted by EvoSuite.
2. Folder in which the combined file will be outputted.

It outputs a single CSV file `combined.csv` in the specified folder. The columns in that file contain the following in
the following order:

1. Test case id
2. First and last line of the branch, separated by a dash, both inclusive
3. `true` when the branch is covered by the test case, `false` when it is not.

### Processing data
The `ProcessExperimentData.kt` file contains code doing the largest part of parsing and transforming experiment data.
It takes the following arguments. Only a short description is given here. See the output files in the experiment
execution code repository for more details about the input files expected here.

1. EvoSuite statistics file
2. EvoSuite test suite branch coverage file
3. EvoSuite test case lengths file
4. Test case branch coverage file outputted from the previous step
5. PIT result report folder
6. EvoSuite log folder
7. Test suite data output file
8. Test case data output file
9. Fitness function coverage value evolution output file
10. Test suite commonality coverage ratio output file prefix

Data is outputted in the files specified in the arguments.

### Filtering data
One can finally, optionally, use `FilterProcessedData.kt` to filter the data files resulting from the previous step
to only keep data for certain specified classes. It can be used with the following arguments.

1. The input data file
2. A file containing a fully qualified class name on each line. Only data for classes contained in this file will be
kept.
3. The file in which the filtered data should be outputted.

## Plotting
The R scripts for plotting the experiment data can be found in `/src/main/R/`. These scripts require the output files
from the previous stage as input. They should be present in the `/r-input/` folder. Executing them will output plots
to `/r-output/`. The plots are named as follows.

- `inter-<configuration>-<fitness function>.svg`: these plots show the change in distribution of the specified fitness
function in EvoSuite runs using the specified configuration.
- `ratios-def-to-<comparison configuration>.svg`: these plots show a histogram of the ratio of commonality coverage per
suite, from the fit_def_sec_def configuration to the specified configuration.
- `suite-<fitness function>.svg`: these plots show the distribution of the specified fitness function coverage value per
configuration, per suite.
- `tc-commonality.svg`: shows the distribution of commonality coverage for each configuration, per test case.
- `tc-length.svg`: shows the distribution of test case length, per configuration.
