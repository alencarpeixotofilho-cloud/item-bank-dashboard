# Install the packages used by the dashboard.
pkgs <- c("shiny", "bslib", "DT", "ggplot2", "rmarkdown", "knitr", "testthat")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing)
cat("All dependencies installed.\n")
