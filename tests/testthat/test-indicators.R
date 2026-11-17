root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
source(file.path(root, "R", "indicators.R"))

make_bank <- function() {
  data.frame(
    item_id = sprintf("IT%03d", 1:6),
    domain = c("A", "A", "A", "B", "B", "B"),
    topic = "t", competency = "c",
    bloom = factor(c("Remember", "Apply", "Analyze", "Apply", "Remember", "Evaluate"),
                   levels = c("Remember", "Understand", "Apply", "Analyze", "Evaluate")),
    author = "x", created = as.Date("2026-01-01") + 0:5,
    status = factor(c("Approved", "Approved", "Draft", "Approved", "Retired", "Approved"),
                    levels = c("Draft", "Under review", "Approved", "Returned", "Retired")),
    stem_words = 50, n_options = 5, has_image = FALSE,
    flaws_detected = c(0, 1, 0, 0, 2, 0),
    times_used = c(1, 0, 0, 2, 0, 1),
    p_value = c(0.5, NA, NA, 0.95, NA, 0.4),
    r_pbis = c(0.3, NA, NA, 0.25, NA, 0.05),
    higher_order = NA
  ) |> transform(higher_order = bloom %in% c("Apply", "Analyze", "Evaluate"))
}

test_that("kpis count approved and higher-order items", {
  k <- kpis(make_bank())
  expect_equal(k$total, 6)
  expect_equal(k$approved, 4)
  expect_equal(k$higher_order_pct, 75)
  expect_equal(k$flawed_pct, 25)
  expect_equal(k$never_used, 1)
})

test_that("coverage compares approved items with what the blueprint needs", {
  cov <- coverage(make_bank(), c(A = 1, B = 1), exam_items = 2, forms = 1)
  expect_equal(cov$needed, c(1, 1))
  expect_equal(cov$approved, c(2, 2))
  expect_equal(cov$gap, c(0, 0))
})

test_that("psychometric flags follow thresholds", {
  u <- psychometric_flags(make_bank())
  expect_equal(u$flag[u$item_id == "IT001"], "ok")
  expect_equal(u$flag[u$item_id == "IT004"], "review")     # too easy
  expect_equal(u$flag[u$item_id == "IT006"], "discard?")   # r < 0.1
})
