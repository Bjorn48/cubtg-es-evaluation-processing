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
suite_cov <- c()
suite_cov_1 <- c()
suite_cov_2 <- c()
suite_cov_3 <- c()
suite_cov_4 <- c()
for (i in 1:length(conf_names)) {
  suite_cov[[ conf_names[i] ]] <- read.csv(paste("r-input/categorized_suite_", conf_names[i], ".csv", sep = ""), header = FALSE)
  suite_cov[[ conf_names[i] ]]$conf <- conf_names[i]
  suite_cov_1[[ conf_names[i] ]] <- suite_cov[[ conf_names[i] ]][suite_cov[[ conf_names[i] ]]$V1 == 1,]
  suite_cov_2[[ conf_names[i] ]] <- suite_cov[[ conf_names[i] ]][suite_cov[[ conf_names[i] ]]$V1 == 2,]
  suite_cov_3[[ conf_names[i] ]] <- suite_cov[[ conf_names[i] ]][suite_cov[[ conf_names[i] ]]$V1 == 3,]
  suite_cov_4[[ conf_names[i] ]] <- suite_cov[[ conf_names[i] ]][suite_cov[[ conf_names[i] ]]$V1 == 4,]
}

# Combine counts for different configurations
suite_cov_1_comb <- do.call('rbind', suite_cov_1)
suite_cov_2_comb <- do.call('rbind', suite_cov_2)
suite_cov_3_comb <- do.call('rbind', suite_cov_3)
suite_cov_4_comb <- do.call('rbind', suite_cov_4)

# Plot suite counts
library(ggplot2)
suite_cov_1_plot <- ggplot(suite_cov_1_comb, aes(conf, V2))
suite_cov_1_plot + geom_boxplot()

library(ggplot2)
suite_cov_2_plot <- ggplot(suite_cov_2_comb, aes(conf, V2))
suite_cov_2_plot + geom_boxplot()

library(ggplot2)
suite_cov_3_plot <- ggplot(suite_cov_3_comb, aes(conf, V2))
suite_cov_3_plot + geom_boxplot()

library(ggplot2)
suite_cov_4_plot <- ggplot(suite_cov_4_comb, aes(conf, V2))
suite_cov_4_plot + geom_boxplot()

# Read test case files
case_cov <- c()
case_cov_1 <- c()
case_cov_2 <- c()
case_cov_3 <- c()
case_cov_4 <- c()
for (i in 1:length(conf_names)) {
  case_cov[[ conf_names[i] ]] <- read.csv(paste("r-input/categorized_testcase_", conf_names[i], ".csv", sep = ""), header = FALSE)
  case_cov[[ conf_names[i] ]]$conf <- conf_names[i]
  case_cov_1[[ conf_names[i] ]] <- case_cov[[ conf_names[i] ]][case_cov[[ conf_names[i] ]]$V1 == 1,]
  case_cov_2[[ conf_names[i] ]] <- case_cov[[ conf_names[i] ]][case_cov[[ conf_names[i] ]]$V1 == 2,]
  case_cov_3[[ conf_names[i] ]] <- case_cov[[ conf_names[i] ]][case_cov[[ conf_names[i] ]]$V1 == 3,]
  case_cov_4[[ conf_names[i] ]] <- case_cov[[ conf_names[i] ]][case_cov[[ conf_names[i] ]]$V1 == 4,]
}

# Combine counts for different configurations
case_cov_1_comb <- do.call('rbind', case_cov_1)
case_cov_2_comb <- do.call('rbind', case_cov_2)
case_cov_3_comb <- do.call('rbind', case_cov_3)
case_cov_4_comb <- do.call('rbind', case_cov_4)

# Plot test case counts
library(ggplot2)
case_cov_1_plot <- ggplot(case_cov_1_comb, aes(conf, V2))
case_cov_1_plot + geom_boxplot()

library(ggplot2)
case_cov_2_plot <- ggplot(case_cov_2_comb, aes(conf, V2))
case_cov_2_plot + geom_boxplot()

library(ggplot2)
case_cov_3_plot <- ggplot(case_cov_3_comb, aes(conf, V2))
case_cov_3_plot + geom_boxplot()

library(ggplot2)
case_cov_4_plot <- ggplot(case_cov_4_comb, aes(conf, V2))
case_cov_4_plot + geom_boxplot()

