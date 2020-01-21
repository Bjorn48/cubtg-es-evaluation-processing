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

# Read statistics files
statistics <- c()
for (i in 1:length(conf_names)) {
  statistics[[ conf_names[i] ]] <- read.csv(paste("r-input/statistics_", conf_names[i], ".csv", sep = ""), header = TRUE)
}

# Combine sizes from statistics files
sizes <- c()
for (i in 1:length(conf_names)) {
  sizes[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['suite_size']
  sizes[[ conf_names[i] ]]$conf <- conf_names[i]
}
sizes_combined <- do.call('rbind', sizes)

# Plot sizes
library(ggplot2)
sizes_plot <- ggplot(sizes_combined, aes(conf, suite_size))
sizes_plot + geom_boxplot()

# Plot generations (same as for size plot)
generations <- c()
for (i in 1:length(conf_names)) {
  generations[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['num_generations']
  generations[[ conf_names[i] ]]$conf <- conf_names[i]
}
generations_combined <- do.call('rbind', generations)

library(ggplot2)
generations_plot <- ggplot(generations_combined, aes(conf, num_generations))
generations_plot + geom_boxplot()

# Plot branch coverage (same as for size plot)
branch <- c()
for (i in 1:length(conf_names)) {
  branch[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['branch_coverage']
  branch[[ conf_names[i] ]]$conf <- conf_names[i]
}
branch_combined <- do.call('rbind', branch)

library(ggplot2)
branch_plot <- ggplot(branch_combined, aes(conf, branch_coverage))
branch_plot + geom_boxplot()

# Plot exception coverage (same as for size plot)
exception <- c()
for (i in 1:length(conf_names)) {
  exception[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['exception_coverage']
  exception[[ conf_names[i] ]]$conf <- conf_names[i]
}
exception_combined <- do.call('rbind', exception)

library(ggplot2)
exception_plot <- ggplot(exception_combined, aes(conf, exception_coverage))
exception_plot + geom_boxplot()

# Plot weak mutation coverage (same as for size plot)
wmutation <- c()
for (i in 1:length(conf_names)) {
  wmutation[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['weak_mutation_coverage']
  wmutation[[ conf_names[i] ]]$conf <- conf_names[i]
}
wmutation_combined <- do.call('rbind', wmutation)

library(ggplot2)
wmutation_plot <- ggplot(wmutation_combined, aes(conf, weak_mutation_coverage))
wmutation_plot + geom_boxplot()

# Plot output coverage (same as for size plot)
output <- c()
for (i in 1:length(conf_names)) {
  output[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['output_coverage']
  output[[ conf_names[i] ]]$conf <- conf_names[i]
}
output_combined <- do.call('rbind', output)

library(ggplot2)
output_plot <- ggplot(output_combined, aes(conf, output_coverage))
output_plot + geom_boxplot()

# Plot method coverage (same as for size plot)
method <- c()
for (i in 1:length(conf_names)) {
  method[[ conf_names[i] ]] <- statistics[[ conf_names[i] ]]['method_coverage']
  method[[ conf_names[i] ]]$conf <- conf_names[i]
}
method_combined <- do.call('rbind', method)

library(ggplot2)
method_plot <- ggplot(method_combined, aes(conf, method_coverage))
method_plot + geom_boxplot()
