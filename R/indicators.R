# Item bank indicators -----------------------------------------------------------

#' Read an item-bank export and normalise column types.
read_bank <- function(path) {
  b <- utils::read.csv(path, stringsAsFactors = FALSE)
  b$created <- as.Date(b$created)
  b$bloom <- factor(b$bloom, levels = c("Remember", "Understand", "Apply", "Analyze", "Evaluate"))
  b$status <- factor(b$status, levels = c("Draft", "Under review", "Approved", "Returned", "Retired"))
  b$higher_order <- b$bloom %in% c("Apply", "Analyze", "Evaluate")
  b
}

#' Headline numbers for the value boxes.
kpis <- function(b) {
  appr <- b[b$status == "Approved", ]
  list(
    total = nrow(b),
    approved = nrow(appr),
    approved_pct = 100 * nrow(appr) / max(1, nrow(b)),
    in_review = sum(b$status %in% c("Draft", "Under review")),
    higher_order_pct = 100 * mean(appr$higher_order),
    flawed_pct = 100 * mean(appr$flaws_detected > 0),
    never_used = sum(appr$times_used == 0)
  )
}

#' Coverage of approved items against target weights per domain.
#'
#' `target` is a named numeric vector of weights (normalised internally).
#' `exam_items` is the size of the exam the bank must support; `forms` is how
#' many non-overlapping forms we want to be able to assemble.
coverage <- function(b, target, exam_items = 100, forms = 8) {
  target <- target / sum(target)
  appr <- b[b$status == "Approved", ]
  have <- table(factor(appr$domain, levels = names(target)))
  need <- ceiling(target * exam_items * forms)
  data.frame(
    domain = names(target),
    target_pct = round(100 * target, 1),
    approved = as.integer(have),
    needed = as.integer(need),
    coverage_pct = round(100 * as.integer(have) / need, 1),
    gap = pmax(0L, as.integer(need) - as.integer(have))
  )
}

#' Cross-table of approved items: domain x Bloom level.
bloom_table <- function(b) {
  appr <- b[b$status == "Approved", ]
  as.data.frame.matrix(table(appr$domain, appr$bloom))
}

#' Pipeline throughput: items created and approved per month.
monthly_flow <- function(b) {
  b$month <- format(b$created, "%Y-%m")
  created <- stats::aggregate(item_id ~ month, b, length)
  approved <- stats::aggregate(item_id ~ month, b[b$status == "Approved", ], length)
  names(created)[2] <- "created"
  names(approved)[2] <- "approved"
  out <- merge(created, approved, all.x = TRUE)
  out$approved[is.na(out$approved)] <- 0
  out
}

#' Quality flags for approved items that have been used in exams.
psychometric_flags <- function(b, p_low = 0.2, p_high = 0.9, r_min = 0.2) {
  u <- b[b$status == "Approved" & b$times_used > 0 & !is.na(b$p_value), ]
  u$flag <- ifelse(u$r_pbis < 0.1, "discard?",
            ifelse(u$r_pbis < r_min | u$p_value < p_low | u$p_value > p_high, "review", "ok"))
  u
}
