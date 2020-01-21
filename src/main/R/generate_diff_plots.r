count_def_to_max <- read.csv("r-input/diff_count_testcase_fit_def_sec_def_to_fit_max_sec_max.csv", header = FALSE)

library(ggplot2)
count_def_to_max_plot <- ggplot(count_def_to_max, aes(V1))
count_def_to_max_plot + stat_bin(boundary = 0.9999, binwidth = 0.5) +
  scale_x_continuous(breaks = seq(0, 10, by=1))
