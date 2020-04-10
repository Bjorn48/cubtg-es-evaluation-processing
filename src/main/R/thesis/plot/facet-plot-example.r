library(tidyverse)

confNames <- c()
confNames[1] <- "f_def_s_def"
confNames[2] <- "f_def_s_max"
confNames[3] <- "f_def_s_min"
confNames[4] <- "f_max_max_s_def"
confNames[5] <- "f_max_s_max"
confNames[6] <- "f_min_s_min"
confNames[7] <- "nsgaii_max"
confNames[8] <- "nsgaii_min"

testData <- tribble(~numbers, ~firstConf, ~secondConf)

for (i in 1:length(confNames)) {
  for (j in 1:length(confNames)) {
    if (i == j) {
      next
    }
    sampleSize <- sample(10:60, 1)
    comparisonData <- tibble(numbers=runif(sampleSize), firstConf=confNames[i], secondConf=confNames[j])
    
    testData <- testData %>% bind_rows(comparisonData)
  }
}



ggplot(testData, aes(factor(0),numbers)) + geom_violin(fill = "#30688e") +
  geom_boxplot(color = "grey", width = 0.1, alpha = 0.2, varwidth = TRUE) + 
  facet_grid(rows = vars(firstConf), cols = vars(secondConf)) +
  scale_y_continuous(limits = c(-0.05,1.05), expand = expand_scale(), minor_breaks = c(0.5), breaks = c(0,1)) +
  scale_x_discrete(expand = expand_scale(add=0.5), breaks = NULL) +
  labs(x = "", y = "Effect size")
  # annotate("rect", xmin=1.225, xmax = 1.45, ymin = 0.825, ymax = 1.025, fill = "white") +
  # annotate("text", x=1.35, y=0.95, label="n = 88", size=2)


