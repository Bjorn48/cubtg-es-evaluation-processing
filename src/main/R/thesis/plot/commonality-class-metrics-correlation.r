library(tidyverse)

infileTcData <- "r-input/data/tc-data.csv"
infileMaxCounts <- "r-input/table-input/class-max-counts.csv"

tcData <- read_csv(infileTcData) %>% rename_all(make.names) %>% filter(exec.weight.cov >= 0.0)
maxCounts <- read_csv(infileMaxCounts) %>% rename_all(make.names) %>% filter(max.count < 200000)

combined <- tcData %>% left_join(maxCounts, by = c("class" = "class.name"))
plot <- ggplot(combined, aes(max.count, exec.weight.cov))
plot + geom_point() + geom_smooth()
