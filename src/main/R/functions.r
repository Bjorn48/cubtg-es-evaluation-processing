boxplotColumn <- function(frame, colName, plotTitle, ylabel = "Coverage value") {
  filtered <- filter(frame, !! sym(colName) > 0)
  colPlot <- ggplot(filtered, aes_string("conf", colName))
  colPlot + geom_boxplot() + stat_summary(fun.y = mean, pch=22, size=3, geom="point") +
    labs(title = plotTitle) + xlab("Configuration") + ylab(ylabel)
}

saveSvgPlot <- function(outFile, plot = last_plot()) {
  ggsave(plot = plot, filename = outFile, width = 260, height = 148, units = "mm")
}
