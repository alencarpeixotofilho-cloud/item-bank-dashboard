# Plots (ggplot2) -----------------------------------------------------------------

PALETTE <- c("#1f6feb", "#8250df", "#2da44e", "#d29922", "#cf222e", "#57606a")

theme_bank <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(plot.title.position = "plot",
                   plot.title = ggplot2::element_text(face = "bold"),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.position = "top")
}

plot_coverage <- function(cov) {
  cov$domain <- stats::reorder(cov$domain, cov$coverage_pct)
  ggplot2::ggplot(cov, ggplot2::aes(coverage_pct, domain)) +
    ggplot2::geom_col(ggplot2::aes(fill = coverage_pct >= 100), width = 0.6) +
    ggplot2::geom_vline(xintercept = 100, linetype = 2) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%d / %d", approved, needed)),
                       hjust = -0.1, size = 3.3) +
    ggplot2::scale_fill_manual(values = c(`TRUE` = "#2da44e", `FALSE` = "#d29922"), guide = "none") +
    ggplot2::scale_x_continuous(limits = c(0, max(130, max(cov$coverage_pct) + 25))) +
    ggplot2::labs(x = "Coverage of the target (%)", y = NULL,
                  title = "Approved items vs what the blueprint needs") +
    theme_bank()
}

plot_bloom <- function(b) {
  appr <- b[b$status == "Approved", ]
  ggplot2::ggplot(appr, ggplot2::aes(y = domain, fill = bloom)) +
    ggplot2::geom_bar(position = "fill", width = 0.65) +
    ggplot2::scale_x_continuous(labels = function(x) paste0(100 * x, "%")) +
    ggplot2::scale_fill_manual(values = c("#d0d7de", "#a5b4c8", "#1f6feb", "#8250df", "#3b2a6b"), name = NULL) +
    ggplot2::labs(x = NULL, y = NULL, title = "Cognitive level of approved items (Bloom)") +
    theme_bank()
}

plot_status <- function(b) {
  ggplot2::ggplot(b, ggplot2::aes(y = domain, fill = status)) +
    ggplot2::geom_bar(width = 0.65) +
    ggplot2::scale_fill_manual(values = PALETTE, name = NULL) +
    ggplot2::labs(x = "Items", y = NULL, title = "Review pipeline by domain") +
    theme_bank()
}

plot_flow <- function(flow) {
  long <- rbind(data.frame(month = flow$month, n = flow$created, what = "created"),
                data.frame(month = flow$month, n = flow$approved, what = "approved"))
  ggplot2::ggplot(long, ggplot2::aes(month, n, colour = what, group = what)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_point(size = 1.5) +
    ggplot2::scale_colour_manual(values = c(created = "#1f6feb", approved = "#2da44e"), name = NULL) +
    ggplot2::labs(x = NULL, y = "Items", title = "Monthly throughput") +
    theme_bank() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 60, hjust = 1, size = 7))
}

plot_psychometrics <- function(u) {
  ggplot2::ggplot(u, ggplot2::aes(p_value, r_pbis, colour = flag)) +
    ggplot2::annotate("rect", xmin = 0.2, xmax = 0.9, ymin = 0.2, ymax = Inf, alpha = 0.06, fill = "#2da44e") +
    ggplot2::geom_point(alpha = 0.7, size = 1.8) +
    ggplot2::scale_colour_manual(values = c(ok = "#2da44e", review = "#d29922", `discard?` = "#cf222e"), name = NULL) +
    ggplot2::labs(x = "Difficulty (p)", y = "Discrimination (r)", title = "Items used in exams") +
    theme_bank()
}
