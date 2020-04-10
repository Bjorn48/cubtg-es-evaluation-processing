infile <- "r-input/data/commonality/per-conf-summary.csv"
stats <- read_csv(infile)

outputTable <- xtable(stats,
                      digits = c(20, 20, 3, 3, 3, 3, 3, 3),
                      display = c("s", "s", "g", "g", "g", "g", "g", "g"))
print.xtable(outputTable, file = "r-output/latex-tables/summaries/commonality.tex")

createConfSummaryTable <- function(infile, outfile) {
  stats <- read_csv(infile)
  
  outputTable <- xtable(stats,
                        digits = c(20, 20, 3, 3, 3, 3, 3, 3),
                        display = c("s", "s", "g", "g", "g", "g", "g", "g"))
  print.xtable(outputTable, file = str_c("r-output/latex-tables/summaries/",outfile))
}

createConfSummaryTable("r-input/data/commonality/per-conf-summary.csv", "commonality.tex")
createConfSummaryTable("r-input/data/pit/all/per-conf-summary.csv", "pit.tex")
createConfSummaryTable("r-input/data/standard-metrics/branch-coverage/per-conf-summary.csv","branch.tex")
createConfSummaryTable("r-input/data/standard-metrics/exception-coverage/per-conf-summary.csv","exception.tex")
createConfSummaryTable("r-input/data/standard-metrics/input-coverage/per-conf-summary.csv","input.tex")
createConfSummaryTable("r-input/data/standard-metrics/method-coverage/per-conf-summary.csv","method.tex")
createConfSummaryTable("r-input/data/standard-metrics/num-generations/per-conf-summary.csv","generations.tex")
createConfSummaryTable("r-input/data/standard-metrics/output-coverage/per-conf-summary.csv","output.tex")
createConfSummaryTable("r-input/data/standard-metrics/suite-size/per-conf-summary.csv","suite-size.tex")
createConfSummaryTable("r-input/data/standard-metrics/tc-length/per-conf-summary.csv","tc-length.tex")
createConfSummaryTable("r-input/data/standard-metrics/weak-mutation-score/per-conf-summary.csv","weak-mutation.tex")
