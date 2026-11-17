# Generate a synthetic item bank export (no real items involved).
#
# Usage:  Rscript examples/generate_item_bank.R

set.seed(2026)

framework <- list(
  "Internal Medicine" = c("Cardiology", "Endocrinology", "Infectious Diseases", "Nephrology", "Pulmonology"),
  "Surgery" = c("Trauma", "Acute Abdomen", "Perioperative Care", "Vascular Surgery"),
  "Pediatrics" = c("Neonatology", "Growth & Development", "Pediatric Infections", "Immunization"),
  "Obstetrics & Gynecology" = c("Prenatal Care", "Labor & Delivery", "Gynecologic Oncology", "Family Planning"),
  "Public Health" = c("Epidemiology", "Primary Care", "Health Policy", "Preventive Medicine")
)
competencies <- c("Diagnosis", "Management", "Prevention", "Clinical Reasoning")
bloom <- c("Remember", "Understand", "Apply", "Analyze", "Evaluate")
status <- c("Draft", "Under review", "Approved", "Returned", "Retired")
authors <- sprintf("Author %02d", 1:18)

n <- 1200
dom_w <- c(0.30, 0.18, 0.20, 0.17, 0.15)          # unbalanced on purpose
domain <- sample(names(framework), n, TRUE, dom_w)
topic <- vapply(domain, function(d) sample(framework[[d]], 1), character(1))
level <- sample(bloom, n, TRUE, c(0.30, 0.25, 0.28, 0.12, 0.05))   # too much recall
created <- as.Date("2025-01-15") + sort(sample(0:640, n, TRUE))

stem_words <- round(pmax(8, rnorm(n, ifelse(level %in% c("Remember", "Understand"), 35, 85), 25)))
flaws <- rpois(n, ifelse(level == "Remember", 0.9, 0.4))
st <- ifelse(created < as.Date("2026-03-01"),
             sample(status, n, TRUE, c(0.03, 0.07, 0.75, 0.10, 0.05)),
             sample(status, n, TRUE, c(0.25, 0.35, 0.30, 0.10, 0.00)))
used <- ifelse(st == "Approved", rpois(n, 1.4), 0)
p_value <- ifelse(used > 0, round(plogis(rnorm(n, 0.4, 1.0)), 2), NA)
r_pbis <- ifelse(used > 0, round(rnorm(n, 0.28, 0.12), 2), NA)

bank <- data.frame(
  item_id = sprintf("IT%05d", seq_len(n)),
  domain = domain,
  topic = unname(topic),
  competency = sample(competencies, n, TRUE),
  bloom = level,
  author = sample(authors, n, TRUE),
  created = created,
  status = st,
  stem_words = stem_words,
  n_options = sample(c(4, 5), n, TRUE, c(0.2, 0.8)),
  has_image = runif(n) < 0.12,
  flaws_detected = flaws,
  times_used = used,
  p_value = p_value,
  r_pbis = r_pbis
)
dir.create("examples", showWarnings = FALSE)
write.csv(bank, "examples/item_bank.csv", row.names = FALSE)
cat(n, "synthetic items written to examples/item_bank.csv\n")
