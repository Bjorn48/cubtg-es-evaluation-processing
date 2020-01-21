# Set configuration names
conf_names <- vector(mode = "character")
conf_names[1] <- "fit_def_sec_def"
conf_names[2] <- "fit_def_sec_max"
conf_names[3] <- "fit_def_sec_min"
conf_names[4] <- "fit_max_min_sec_def"
conf_names[5] <- "fit_max_sec_max"
conf_names[6] <- "fit_min_sec_min"
conf_names[7] <- "nsgaii_max"
conf_names[8] <- "nsgaii_min"

# Read test suite files
suite_counts <- c()
for (i in 1:length(conf_names)) {
  suite_counts[[ conf_names[i] ]] <- read.csv(paste("r-input/coverage_suite_", conf_names[i], ".csv", sep = ""), header = FALSE)
  suite_counts[[ conf_names[i] ]]$conf <- conf_names[i]
}

# Combine counts for different configurations
suite_counts_combined <- do.call('rbind', suite_counts)

# Plot suite counts
library(ggplot2)
suite_counts_plot <- ggplot(suite_counts_combined, aes(conf, V1))
suite_counts_plot + geom_boxplot()

# Read test case files
case_counts <- c()
for (i in 1:length(conf_names)) {
  case_counts[[ conf_names[i] ]] <- read.csv(paste("r-input/coverage_testcase_", conf_names[i], ".csv", sep = ""), header = FALSE)
  case_counts[[ conf_names[i] ]]$conf <- conf_names[i]
}

# Combine counts for different configurations
case_counts_combined <- do.call('rbind', case_counts)

# Plot test case counts
library(ggplot2)
case_counts_plot <- ggplot(case_counts_combined, aes(conf, V1))
case_counts_plot + geom_boxplot()
