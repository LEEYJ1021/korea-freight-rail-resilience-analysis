# =============================================================================
# fig6_nonlinear_fitting_v5.R
#
# Figure 6.  Correlation between Node Centrality and Cascading Failure Impact
# Three regression models compared: Linear, Power-Law, Logit
# AIC formula: n*log(RSS/n) + 2k   (applied consistently across all models)
#
# Inputs :  revision_ress/data/cascade_*.csv   (from step1_cascade_simulation.py)
# Output :  revision_ress/figures/Fig6_nonlinear_fitting_v5.png
#
# Dependencies: ggplot2, patchwork, nls2, dplyr, scales
# =============================================================================

library(dplyr)
library(ggplot2)
library(patchwork)
library(scales)
library(nls2)   # install.packages("nls2") if missing

# -----------------------------------------------------------------------------
# 0.  Paths  — edit DATA_DIR if running from a different working directory
# -----------------------------------------------------------------------------
DATA_DIR <- "revision_ress/data"
OUT_FILE <- "revision_ress/figures/Fig6_nonlinear_fitting_v5.png"

# -----------------------------------------------------------------------------
# 1.  Load CSVs
# -----------------------------------------------------------------------------
read_csv_safe <- function(measure) {
  path <- file.path(DATA_DIR, paste0("cascade_", tolower(measure), ".csv"))
  if (!file.exists(path))
    stop("File not found: ", path,
         "\nRun step1_cascade_simulation.py first.")
  df <- read.csv(path)
  df[is.finite(df$centrality) & is.finite(df$cascade_impact) &
       df$centrality > 0, ]
}

cascade_data <- list(
  Betweenness = read_csv_safe("Betweenness"),
  Degree      = read_csv_safe("Degree"),
  Closeness   = read_csv_safe("Closeness"),
  Eigenvector = read_csv_safe("Eigenvector")
)

# Print quick summary
for (nm in names(cascade_data)) {
  d <- cascade_data[[nm]]
  cat(sprintf("%-12s  n=%d  centrality [%.3f, %.3f]  impact [%.3f, %.3f]\n",
              nm, nrow(d),
              min(d$centrality), max(d$centrality),
              min(d$cascade_impact), max(d$cascade_impact)))
}

# -----------------------------------------------------------------------------
# 2.  Helper: unified AIC  n*log(RSS/n) + 2k
# -----------------------------------------------------------------------------
aic_unified <- function(resid, n_params) {
  n   <- length(resid)
  rss <- sum(resid^2)
  n * log(rss / n) + 2 * n_params
}

# -----------------------------------------------------------------------------
# 3.  Panel builder
# -----------------------------------------------------------------------------
make_panel <- function(df, xlab) {

  x <- df$centrality
  y <- df$cascade_impact

  # --- Linear ---
  lm_fit <- lm(y ~ x, data = df)
  r2_lin <- round(summary(lm_fit)$r.squared, 3)
  aic_lin <- aic_unified(residuals(lm_fit), n_params = 3)   # intercept + slope + sigma

  # --- Power-law:  y = a * x^b + c ---
  pw_fit <- tryCatch(
    suppressWarnings(
      nls(y ~ a * x^b + c, data = df,
          start     = list(a = diff(range(y)) * 0.8, b = 0.35,
                           c = max(min(y) * 0.9, 0.01)),
          lower     = list(a = 0.001, b = 0.01, c = 0),
          upper     = list(a = 10,    b = 5,     c = 0.5),
          algorithm = "port",
          control   = nls.control(maxiter = 800, warnOnly = TRUE))
    ),
    error = function(e) NULL
  )

  # --- Logit:  y = L / (1 + exp(-k*(x - x0)))  with L <= 0.999 ---
  logit_fit <- tryCatch(
    suppressWarnings(
      nls(y ~ L / (1 + exp(-k * (x - x0))), data = df,
          start     = list(L  = min(max(y) * 1.02, 0.999),
                           k  = 5,
                           x0 = median(x)),
          lower     = list(L = 0.10, k = 0.10, x0 = min(x)),
          upper     = list(L = 0.999, k = 50,  x0 = max(x)),
          algorithm = "port",
          control   = nls.control(maxiter = 800, warnOnly = TRUE))
    ),
    error = function(e) NULL
  )

  # --- R² and ΔAIC ---
  r2_pw    <- if (!is.null(pw_fit))    round(cor(y, predict(pw_fit))^2,    3) else NA
  r2_logit <- if (!is.null(logit_fit)) round(cor(y, predict(logit_fit))^2, 3) else NA

  aic_pw <- if (!is.null(pw_fit))
    aic_unified(residuals(pw_fit), length(coef(pw_fit)) + 1) else NA
  aic_lg <- if (!is.null(logit_fit))
    aic_unified(residuals(logit_fit), length(coef(logit_fit)) + 1) else NA

  d_aic_pw <- if (!is.na(aic_pw)) round(aic_pw - aic_lin, 1) else NA
  d_aic_lg <- if (!is.na(aic_lg)) round(aic_lg - aic_lin, 1) else NA

  spear_rho <- round(cor(x, y, method = "spearman"), 3)
  spear_p   <- suppressWarnings(cor.test(x, y, method = "spearman")$p.value)

  # --- Prediction curves (clipped to [0, 1]) ---
  x_seq <- seq(min(x), max(x), length.out = 300)

  clip01 <- function(v) pmin(pmax(v, 0), 1)

  pred_df <- data.frame(
    x        = x_seq,
    Linear   = clip01(predict(lm_fit, newdata = data.frame(x = x_seq))),
    PowerLaw = if (!is.null(pw_fit))
      clip01(predict(pw_fit,    newdata = data.frame(x = x_seq))) else rep(NA, 300),
    Logit    = if (!is.null(logit_fit))
      clip01(predict(logit_fit, newdata = data.frame(x = x_seq))) else rep(NA, 300)
  )

  # --- Annotation strings ---
  fmt  <- function(v) ifelse(is.na(v), "\u2013", sprintf("%.3f", v))
  fmtd <- function(v) ifelse(is.na(v), "\u2013", sprintf("%+.1f", v))

  ann_r2  <- sprintf("R\u00b2: lin=%.3f | pw=%s | logit=%s",
                     r2_lin, fmt(r2_pw), fmt(r2_logit))
  ann_aic <- sprintf("\u0394AIC(vs lin): pw=%s | logit=%s",
                     fmtd(d_aic_pw), fmtd(d_aic_lg))
  ann_rho <- sprintf("Spearman \u03c1 = %.3f%s", spear_rho,
                     if (spear_p < 0.001) " (p<0.001)" else
                       sprintf(" (p=%.3f)", spear_p))

  y_min <- min(y); y_max <- max(y); y_pad <- (y_max - y_min) * 0.06

  # --- Plot ---
  ggplot(df, aes(centrality, cascade_impact)) +
    geom_point(alpha = 0.40, color = "#C1666B", size = 1.7) +
    geom_line(data = pred_df,
              aes(x, Linear, color = "Linear"),
              linewidth = 0.85, linetype = "dashed") +
    geom_line(data = pred_df[!is.na(pred_df$PowerLaw), ],
              aes(x, PowerLaw, color = "Power-Law"),
              linewidth = 1.20) +
    geom_line(data = pred_df[!is.na(pred_df$Logit), ],
              aes(x, Logit, color = "Logit"),
              linewidth = 1.15, linetype = "dotdash") +
    scale_color_manual(
      values = c(Linear = "#E76F51", "Power-Law" = "#2A9D8F", Logit = "#264653"),
      name   = "Model"
    ) +
    annotate("text", x = min(x), y = y_max + y_pad * 0.8,
             label = ann_r2,  hjust = 0, vjust = 1, size = 2.5, color = "grey30") +
    annotate("text", x = min(x), y = y_max - y_pad * 0.5,
             label = ann_aic, hjust = 0, vjust = 1, size = 2.5,
             color = "#264653", fontface = "italic") +
    annotate("text", x = max(x), y = y_min + y_pad * 0.3,
             label = ann_rho, hjust = 1, vjust = 0, size = 2.5,
             color = "#2A9D8F", fontface = "bold") +
    labs(x = xlab, y = "Cascade Impact",
         title = paste0(xlab, " vs Impact")) +
    coord_cartesian(ylim = c(max(0, y_min - y_pad),
                             min(1.05, y_max + y_pad * 2.5))) +
    theme_bw(base_size = 10) +
    theme(legend.position  = "bottom",
          legend.text      = element_text(size = 7),
          legend.key.size  = unit(0.4, "cm"),
          plot.title       = element_text(face = "bold", size = 10),
          panel.grid.minor = element_blank())
}

# -----------------------------------------------------------------------------
# 4.  Build four panels
# -----------------------------------------------------------------------------
xlab_map <- c(
  Betweenness = "Betweenness Centrality",
  Degree      = "Degree Centrality",
  Closeness   = "Closeness Centrality",
  Eigenvector = "Eigenvector Centrality"
)

panels <- mapply(
  function(df, nm) make_panel(df, xlab_map[[nm]]),
  cascade_data, names(cascade_data),
  SIMPLIFY = FALSE
)

# -----------------------------------------------------------------------------
# 5.  Assemble and save
# -----------------------------------------------------------------------------
caption_txt <- paste0(
  "Data: Motter-Lai cascade simulation (\u03b1=0.50) on 8 configuration-model ",
  "network realizations preserving the Korean freight rail degree sequence ",
  "(N=53, E\u224886). Betweenness panel: n=200 (zero-betweenness peripheral ",
  "stations excluded; their cascade impact reflects structural isolation, not ",
  "load-redistribution dynamics). Other panels: n=424. ",
  "AIC: n\u00b7log(RSS/n)+2k. Logit upper asymptote \u2264 0.999; ",
  "all predictions clipped to [0, 1]."
)

fig6 <- (panels[[1]] | panels[[2]]) / (panels[[3]] | panels[[4]]) +
  plot_annotation(
    title    = "Figure 6.  Correlation between Node Centrality and Cascading Failure Impact",
    subtitle = paste0(
      "Three regression models: Linear (dashed), Power-Law, Logit.  ",
      "\u0394AIC < 0 = improvement over linear baseline.  ",
      "\u0394AIC < \u221210 = strong nonlinear evidence."
    ),
    caption  = caption_txt,
    theme    = theme(
      plot.title    = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size  = 9,  color = "grey40"),
      plot.caption  = element_text(size  = 7.5, color = "grey50",
                                   hjust = 0, margin = margin(t = 6))
    )
  )

dir.create(dirname(OUT_FILE), showWarnings = FALSE, recursive = TRUE)
ggsave(OUT_FILE, fig6, width = 11, height = 8.5, dpi = 300)
message("\u2705  Saved: ", OUT_FILE)

# -----------------------------------------------------------------------------
# 6.  Print model comparison table (for rebuttal)
# -----------------------------------------------------------------------------
cat("\n===== MODEL COMPARISON TABLE =====\n")
cat(sprintf("%-22s | %5s | %6s | %6s | %7s | %8s | %9s | %9s\n",
            "Measure", "n", "R2_lin", "R2_pw", "R2_logit",
            "AIC_lin", "dAIC_pw", "dAIC_lg"))
cat(strrep("-", 92), "\n")

for (nm in names(cascade_data)) {
  df  <- cascade_data[[nm]]
  x   <- df$centrality; y <- df$cascade_impact
  lmf <- lm(y ~ x)
  r2l <- round(summary(lmf)$r.squared, 4)
  al  <- aic_unified(residuals(lmf), 3)

  pw <- tryCatch(
    suppressWarnings(nls(y ~ a * x^b + c, data = df,
                         start = list(a = 0.6, b = 0.35, c = 0.30),
                         lower = list(a = 0.001, b = 0.01, c = 0),
                         upper = list(a = 10, b = 5, c = 0.5),
                         algorithm = "port",
                         control = nls.control(maxiter = 800, warnOnly = TRUE))),
    error = function(e) NULL)

  lg <- tryCatch(
    suppressWarnings(nls(y ~ L / (1 + exp(-k * (x - x0))), data = df,
                         start = list(L = min(max(y) * 1.02, 0.999),
                                      k = 5, x0 = median(x)),
                         lower = list(L = 0.10, k = 0.10, x0 = min(x)),
                         upper = list(L = 0.999, k = 50, x0 = max(x)),
                         algorithm = "port",
                         control = nls.control(maxiter = 800, warnOnly = TRUE))),
    error = function(e) NULL)

  r2pw <- if (!is.null(pw)) round(cor(y, predict(pw))^2, 4) else NA
  r2lg <- if (!is.null(lg)) round(cor(y, predict(lg))^2, 4) else NA
  apw  <- if (!is.null(pw)) aic_unified(residuals(pw), length(coef(pw)) + 1) else NA
  alg  <- if (!is.null(lg)) aic_unified(residuals(lg), length(coef(lg)) + 1) else NA

  fna <- function(v, fmt) ifelse(is.na(v), "       NA", sprintf(fmt, v))

  cat(sprintf("%-22s | %5d | %6.4f | %6s | %7s | %8.2f | %9s | %9s\n",
              xlab_map[[nm]], nrow(df), r2l,
              fna(r2pw, "%.4f"), fna(r2lg, "%.4f"), al,
              fna(apw - al, "%+.2f"), fna(alg - al, "%+.2f")))
}
cat(strrep("=", 92), "\n")
cat("Note: dAIC < -2 = meaningful improvement over linear baseline\n")
cat("      dAIC < -10 = strong nonlinear evidence\n")
