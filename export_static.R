# Export a static, self-contained HTML snapshot of the dashboard
# (useful to share with people who do not run R).
#
# Usage: Rscript export_static.R  ->  docs/item_bank_snapshot.html

dir.create("docs", showWarnings = FALSE)
rmarkdown::render("report/snapshot.Rmd", output_dir = "docs",
                  output_file = "item_bank_snapshot.html", knit_root_dir = getwd(), quiet = TRUE)

source("R/indicators.R")
source("R/plots.R")
b <- read_bank("examples/item_bank.csv")
target <- c("Internal Medicine" = 25, "Surgery" = 20, "Pediatrics" = 20,
            "Obstetrics & Gynecology" = 20, "Public Health" = 15)
ggplot2::ggsave("docs/coverage.png", plot_coverage(coverage(b, target)), width = 7.5, height = 3.6, dpi = 130, bg = "white")
ggplot2::ggsave("docs/bloom.png", plot_bloom(b), width = 7.5, height = 3.6, dpi = 130, bg = "white")
ggplot2::ggsave("docs/psychometrics.png", plot_psychometrics(psychometric_flags(b)), width = 6.5, height = 4, dpi = 130, bg = "white")
cat("Snapshot and figures written to docs/\n")
