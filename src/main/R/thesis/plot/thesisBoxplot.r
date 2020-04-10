library(tidyverse)

thesisBoxplot <- function(stats, colName, plotTitle, ylabel = "Coverage value", yLogScale = FALSE, ymax = NULL, outlierShape = 19) {
  plot <- ggplot(stats, aes_string("conf", colName)) +
  geom_boxplot(outlier.shape = outlierShape) + stat_summary(fun.y = mean, pch=22, size=3, geom="point") +
    labs(title = plotTitle) + xlab("Configuration") + ylab(ylabel)
  if (yLogScale) {
    plot <- plot + scale_y_log10()
  }
  if (!is.null(ymax)) {
    plot <- plot + ylim(NA, ymax)
  }
  print(plot)
}
