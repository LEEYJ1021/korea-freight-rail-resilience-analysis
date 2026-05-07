# =============================================================================
# revision_figures_v2.R
#
# Produces three figures for the RESS revision:
#   Fig2_merged_regional_map_v2.png        (replaces original Figs. 2 & 3)
#   Fig8_richclub_v2.png                   (replaces original Fig. 8)
#   Fig_centrality_distribution_v2.png     (new Appendix A2)
#   Fig2_merged_regional_map_v2.html       (interactive leaflet version of Fig. 2)
#
# Output directory: revision_ress/figures/
#
# Dependencies:
#   ggplot2, ggrepel, patchwork, dplyr, scales, maps,
#   leaflet, leaflet.extras, htmlwidgets
# =============================================================================

library(dplyr)
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)
library(maps)
library(leaflet)
library(leaflet.extras)
library(htmlwidgets)

OUT_DIR <- "revision_ress/figures"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

set.seed(2025)   # global seed for reproducibility

# =============================================================================
# 0.  Shared data
# =============================================================================

coords <- data.frame(
  station = c(
    "Gaya","Uiwang","Gacheon","JecheonYard","Ganchi","Gwangyang","Sillyewon",
    "Cheonan","Gwangwoondae","Dodam","Ipseokri","Goedong","Suncheon","Obong",
    "Jecheon","Gunsan","Taegum","Naju","Heungguksa","DaejeonYard","Donghae",
    "Deokso","Mureung","Susaek","Doan","Dongsan","ShingwangyangPort",
    "BusanNewPort","Busanjin","Seokpo","Eumseong","Masan","Yeongju","Mokpo",
    "Hwangdeung","Munsu","BugangCargo","Sapgyo","Yakmok","Seokhang","Shindong",
    "Ssangryong","Cheongju","Paldang","Okgye","Taehwagang","Onsan","Cheoram",
    "Iksan","Jeokryang","Incheon","Heukseokri","Gyeongju"
  ),
  lat = c(
    35.156,37.321,35.854,37.128,36.210,34.956,36.727,36.810,37.624,37.024,
    37.197,35.997,34.946,37.336,37.127,35.998,34.931,35.014,34.817,36.371,
    37.498,37.586,36.519,37.582,36.813,35.875,34.898,35.114,35.129,37.046,
    36.926,35.236,36.811,34.800,35.999,36.769,36.544,36.670,36.037,37.197,
    35.956,37.174,36.647,37.533,37.617,35.539,35.421,37.113,35.942,34.856,
    37.476,36.255,35.798
  ),
  lon = c(
    129.043,126.948,128.693,128.179,126.621,127.588,126.850,127.147,127.062,
    128.327,128.298,129.375,127.502,126.961,128.206,126.761,127.715,126.717,
    127.676,127.423,129.123,127.209,128.688,126.894,127.614,127.088,127.647,
    128.846,129.050,129.060,127.726,128.577,128.626,126.400,126.943,128.630,
    127.349,126.752,128.364,128.485,128.329,127.340,127.244,127.245,129.051,
    129.354,129.351,129.037,126.946,127.706,126.627,127.339,129.139
  )
)

region_map <- list(
  Southern        = c("Gaya","Gwangyang","Naju","Masan","Mokpo","BusanNewPort",
                      "Busanjin","ShingwangyangPort","Onsan","Jeokryang","Taegum",
                      "Heungguksa","Suncheon"),
  Northern        = c("Gwangwoondae","Deokso","Susaek","Okgye","Paldang"),
  `South-Central` = c("Gacheon","Ganchi","Goedong","Gunsan","DaejeonYard","Dongsan",
                      "Shindong","Yakmok","Iksan","Hwangdeung","Taehwagang",
                      "Heukseokri","Gyeongju"),
  Central         = c("Dodam","Doan","Donghae","Mureung","Munsu","BugangCargo",
                      "Sapgyo","Seokhang","Sillyewon","Ssangryong","Yeongju","Obong",
                      "Uiwang","Incheon","Ipseokri","Jecheon","JecheonYard","Cheonan",
                      "Cheoram","Cheongju","Seokpo","Eumseong")
)

region_df <- stack(region_map) |>
  setNames(c("station", "region")) |>
  mutate(region = as.character(region))

centrality <- data.frame(
  station = c(
    "JecheonYard","BusanNewPort","Donghae","Obong","Goedong","Yeongju","Dongsan",
    "ShingwangyangPort","Dodam","Busanjin","Cheoram","Hwangdeung","Sapgyo",
    "Ssangryong","Gwangyang","Suncheon","DaejeonYard","Uiwang","Cheongju","Onsan",
    "Heungguksa","Okgye","Taegum","Deokso","Gunsan","Gacheon","Incheon","Masan",
    "Yakmok","Ipseokri","Naju","Jeokryang","Ganchi","Paldang","Doan","Mokpo",
    "Eumseong","Munsu","BugangCargo","Seokhang","Shindong","Gaya","Jecheon",
    "Gyeongju","Heukseokri","Seokpo","Sillyewon","Taehwagang","Iksan","Mureung",
    "Susaek","Gwangwoondae","Cheonan"
  ),
  degree_cent = c(
    0.327,0.173,0.192,0.231,0.173,0.096,0.058,0.077,0.154,0.096,0.096,0.058,
    0.038,0.058,0.058,0.038,0.077,0.077,0.038,0.077,0.038,0.038,0.077,0.058,
    0.038,0.038,0.038,0.019,0.038,0.115,0.019,0.038,0.038,0.019,0.019,0.019,
    0.019,0.019,0.038,0.019,0.019,0.019,0.019,0.019,0.019,0.019,0.019,0.019,
    0.019,0.019,0.077,0.058,0.038
  ),
  betweenness = c(
    0.513,0.278,0.185,0.183,0.166,0.086,0.141,0.108,0.061,0.070,0.038,0.079,
    0.074,0.038,0.039,0.046,0.000,0.039,0.042,0.006,0.038,0.000,0.014,0.045,
    0.009,0.000,0.000,0.000,0.026,0.000,0.000,0.038,0.000,0.000,0.000,0.000,
    0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,
    0.000,0.000,0.000,0.000,0.000
  ),
  composite = c(
    0.327,0.221,0.209,0.154,0.148,0.106,0.087,0.073,0.066,0.052,0.045,0.047,
    0.030,0.035,0.035,0.050,0.023,0.042,0.021,0.024,0.031,0.017,0.024,0.025,
    0.013,0.011,0.011,0.004,0.024,0.025,0.004,0.031,0.008,0.004,0.004,0.004,
    0.004,0.004,0.008,0.004,0.004,0.004,0.004,0.004,0.004,0.004,0.004,0.004,
    0.004,0.004,0.019,0.012,0.030
  )
)

plot_df <- coords |>
  left_join(region_df,  by = "station") |>
  left_join(centrality, by = "station")

region_colors <- c(
  Southern        = "#E63946",
  Northern        = "#457B9D",
  `South-Central` = "#2A9D8F",
  Central         = "#F4A261"
)

major_hubs <- c("JecheonYard","Obong","BusanNewPort","Donghae","Goedong")

# =============================================================================
# FIG. 2 — Merged regional map
# =============================================================================

# Station abbreviations
abbrev <- function(s) {
  parts <- strsplit(s, "(?=[A-Z])", perl = TRUE)[[1]]
  paste0(toupper(substr(parts, 1, 1)), collapse = "")
}

# Per-station nudge values for the dense southern cluster
nudge_x <- c(
  Busanjin = 0.15, Gaya = 0.12, Masan = -0.16, Taegum = -0.22,
  ShingwangyangPort = -0.16, Suncheon = 0.12, Gwangyang = -0.12,
  Heungguksa = -0.20, Jeokryang = 0.12, Naju = -0.14
)
nudge_y <- c(
  Busanjin = 0.09, Gaya = -0.09, Masan = 0.09, Taegum = -0.09,
  ShingwangyangPort = 0.09, Suncheon = -0.09, Gwangyang = 0.09,
  Heungguksa = 0.09, Jeokryang = 0.09, Naju = -0.09
)

plot_df2 <- plot_df |>
  mutate(
    abbr       = sapply(station, abbrev),
    label_text = ifelse(station %in% major_hubs, station, abbr),
    is_hub     = station %in% major_hubs,
    nx         = ifelse(station %in% names(nudge_x), nudge_x[station], 0),
    ny         = ifelse(station %in% names(nudge_y), nudge_y[station], 0)
  )

hub_df    <- plot_df2 |> filter(is_hub)
nonhub_df <- plot_df2 |> filter(!is_hub)

korea_map <- map_data("world", region = "South Korea")

fig2 <- ggplot() +
  geom_polygon(data = korea_map,
               aes(x = long, y = lat, group = group),
               fill = "grey93", color = "grey70", linewidth = 0.3) +
  # Regular stations
  geom_point(data = nonhub_df,
             aes(x = lon, y = lat, color = region, shape = "Regular Station"),
             size = 3.0, alpha = 0.88) +
  # Major hubs
  geom_point(data = hub_df,
             aes(x = lon, y = lat, color = region, shape = "Major Hub"),
             size = 6.5, alpha = 0.95) +
  scale_shape_manual(
    name   = "Station Type",
    values = c("Major Hub" = 17, "Regular Station" = 16),
    guide  = guide_legend(override.aes = list(size = c(4.5, 2.8), color = "grey30"))
  ) +
  scale_color_manual(values = region_colors, name = "Region") +
  # Labels for regular stations (abbreviations)
  geom_text_repel(
    data            = nonhub_df,
    aes(x = lon, y = lat, label = abbr, color = region),
    size            = 2.0, fontface = "plain",
    box.padding     = 0.22, point.padding = 0.15,
    max.overlaps    = 55,
    nudge_x         = nonhub_df$nx,
    nudge_y         = nonhub_df$ny,
    segment.size    = 0.25, segment.color = "grey60",
    min.segment.length = 0.2,
    show.legend     = FALSE
  ) +
  # Labels for major hubs (full names)
  geom_text_repel(
    data          = hub_df,
    aes(x = lon, y = lat, label = station),
    size          = 3.0, fontface = "bold", color = "#1d1d1b",
    box.padding   = 0.55, point.padding = 0.40,
    max.overlaps  = 10,
    segment.size  = 0.5, segment.color = "#1d1d1b",
    nudge_y       = 0.08,
    show.legend   = FALSE
  ) +
  coord_fixed(ratio = 1.3, xlim = c(125.5, 130.2), ylim = c(34.1, 38.3)) +
  labs(
    title    = "Figure 2.  Regional Subgraph Mapping of the Korean Freight Rail Network",
    subtitle = "All four administrative regions on a single map.  \u25b2 = Major hub;  \u25cf = Regular station.",
    x        = "Longitude (\u00b0E)", y = "Latitude (\u00b0N)",
    caption  = paste0(
      "Abbreviations denote station codes. Colors indicate administrative region. ",
      "Regional assignments follow KORAIL operational jurisdiction boundaries. ",
      "Major hubs shown with full names."
    )
  ) +
  theme_bw(base_size = 11) +
  theme(
    legend.position   = c(0.10, 0.22),
    legend.background = element_rect(fill = "white", color = "grey70", linewidth = 0.4),
    legend.key.size   = unit(0.4, "cm"),
    legend.title      = element_text(face = "bold", size = 9),
    plot.title        = element_text(face = "bold", size = 12),
    plot.subtitle     = element_text(color = "grey40", size = 9),
    plot.caption      = element_text(size = 8, color = "grey50"),
    panel.grid        = element_line(color = "grey88", linewidth = 0.3)
  )

ggsave(file.path(OUT_DIR, "Fig2_merged_regional_map_v2.png"),
       fig2, width = 8, height = 10, dpi = 300)
message("\u2705  Fig2_merged_regional_map_v2.png saved")

# Interactive leaflet version
pal <- colorFactor(
  palette = unname(region_colors),
  domain  = names(region_colors)
)

leaf_map <- leaflet(plot_df2) |>
  addProviderTiles("CartoDB.Positron") |>
  addCircleMarkers(
    data        = nonhub_df,
    lng         = ~lon, lat = ~lat,
    color       = ~pal(region), fillColor = ~pal(region),
    fillOpacity = 0.85, radius = 6, weight = 1.2,
    popup       = ~paste0("<b>", station, "</b><br>Region: ", region,
                          "<br>C_comp: ", round(composite, 3))
  ) |>
  addCircleMarkers(
    data        = hub_df,
    lng         = ~lon, lat = ~lat,
    color       = "black", fillColor = ~pal(region),
    fillOpacity = 0.95, radius = 11, weight = 2,
    popup       = ~paste0("<b>\u2605 HUB: ", station, "</b><br>Region: ", region,
                          "<br>C_comp: ", round(composite, 3))
  ) |>
  addLegend("bottomright", pal = pal, values = ~region, title = "Region")

saveWidget(leaf_map,
           file.path(OUT_DIR, "Fig2_merged_regional_map_v2.html"),
           selfcontained = TRUE)
message("\u2705  Fig2_merged_regional_map_v2.html saved")

# =============================================================================
# FIG. 8 — Rich-Club analysis
# =============================================================================

rc <- data.frame(
  k           = c(3,     5,    7,    9),
  phi_norm    = c(0.423, 1.42, 1.45, 1.65),
  ci_lo       = c(0.312, 1.18, 1.22, 1.38),
  ci_hi       = c(0.589, 1.67, 1.73, 1.97),
  p_adj       = c(0.234, 0.045, 0.012, 0.003),
  N_eligible  = c(22,   10,   6,    5)
) |>
  mutate(
    sig       = case_when(p_adj < 0.01 ~ "**", p_adj < 0.05 ~ "*", TRUE ~ "ns"),
    sig_color = case_when(p_adj < 0.01 ~ "#D32F2F", p_adj < 0.05 ~ "#F57C00",
                          TRUE ~ "#757575"),
    pt_size   = N_eligible / max(N_eligible) * 5 + 2
  )

hub_labels <- data.frame(
  k        = c(9,                      7,              5,                  5),
  label    = c("Jecheon Yard\n(k=17)", "Obong\n(k=12)",
               "Donghae\n(k=10)",      "Busan New Port\n(k=9)"),
  phi_norm = c(1.65, 1.45, 1.42, 1.42)
)

fig8 <- ggplot(rc, aes(x = k, y = phi_norm)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              fill = "#E3F2FD", alpha = 0.55) +
  geom_hline(yintercept = 1, linetype = "dashed",
             color = "#F18F01", linewidth = 1.1, alpha = 0.8) +
  geom_line(color = "#1565C0", linewidth = 2, alpha = 0.85) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                width = 0.25, color = "#424242", linewidth = 0.8) +
  geom_point(aes(fill = sig_color, size = pt_size),
             shape = 21, color = "white", stroke = 1.5) +
  geom_text(aes(label = paste0("\u03c6=", phi_norm, sig), y = ci_hi + 0.11),
            size = 3.5, fontface = "bold", vjust = 0) +
  geom_text(aes(label = paste0("N=", N_eligible), y = ci_lo - 0.10),
            size = 2.9, color = "#616161", vjust = 1) +
  annotate("rect", xmin = 8.5, xmax = 9.5, ymin = 1.30, ymax = 2.05,
           alpha = 0.07, fill = "#D32F2F") +
  annotate("text", x = 9, y = 1.97,
           label = "STRONG HUB REGION\n(Peak at k\u22659)",
           size = 3.1, fontface = "bold", color = "#D32F2F") +
  geom_point(data = hub_labels, aes(x = k, y = phi_norm),
             size = 3, color = "#D32F2F", shape = 17, inherit.aes = FALSE) +
  geom_text_repel(data = hub_labels,
                  aes(x = k, y = phi_norm, label = label),
                  size = 2.85, color = "#D32F2F", fontface = "bold",
                  nudge_x = 0.35, nudge_y = 0.06,
                  box.padding = 0.3, inherit.aes = FALSE) +
  scale_x_continuous(breaks = rc$k, limits = c(2.5, 9.8)) +
  scale_y_continuous(limits = c(0, 2.18), breaks = seq(0, 2, 0.5)) +
  scale_fill_identity() +
  scale_size_identity() +
  labs(
    title    = "Figure 8.  Rich-Club Phenomenon Analysis with Bootstrap Confidence Intervals",
    subtitle = paste0(
      "Normalized rich-club coefficient (\u03c6_norm) across degree thresholds; ",
      "95% bootstrap CIs (1,000 iterations)\n",
      "FDR-adjusted p-values (Benjamini-Hochberg): * p < 0.05,  ** p < 0.01"
    ),
    x       = "Degree Threshold (k)",
    y       = "Normalized Rich-Club Coefficient (\u03c6_norm)",
    caption = paste0(
      "Error bars = 95% bootstrap CI.  Point size \u221d eligible nodes N_{>k}.\n",
      "Note: k \u2265 11 excluded (N < 3; statistically unreliable)."
    )
  ) +
  theme_bw(base_size = 11) +
  theme(plot.title       = element_text(face = "bold", size = 11),
        plot.subtitle    = element_text(size = 9,  color = "grey40"),
        plot.caption     = element_text(size = 8,  color = "grey50"),
        panel.grid.minor = element_blank())

ggsave(file.path(OUT_DIR, "Fig8_richclub_v2.png"),
       fig8, width = 9, height = 6, dpi = 300)
message("\u2705  Fig8_richclub_v2.png saved")

# =============================================================================
# FIG. A2 — Centrality distribution (new Appendix figure)
# =============================================================================

gini_coeff <- function(x) {
  x <- sort(x[x > 0]); n <- length(x)
  round(2 * sum(seq_len(n) * x) / (n * sum(x)) - (n + 1) / n, 4)
}

deg_k   <- pmax(1, round(centrality$degree_cent * 52))
btw_raw <- centrality$betweenness

gini_deg <- gini_coeff(deg_k)
gini_btw <- gini_coeff(btw_raw)

deg_freq <- as.data.frame(table(deg_k)) |>
  mutate(k = as.integer(as.character(deg_k)), P_k = Freq / sum(Freq)) |>
  filter(P_k > 0)

lm_log  <- lm(log(P_k) ~ log(k), data = deg_freq)
gamma   <- -round(coef(lm_log)[2], 2)
r2_log  <- round(summary(lm_log)$r.squared, 3)

top8 <- centrality |>
  mutate(deg_k = pmax(1, round(degree_cent * 52))) |>
  arrange(desc(composite)) |>
  head(8)

# (a) Degree histogram
p_hist <- ggplot(data.frame(deg_k = deg_k), aes(x = deg_k)) +
  geom_histogram(binwidth = 1, fill = "#264653", color = "white", alpha = 0.85) +
  geom_vline(xintercept = mean(deg_k), color = "#E76F51",
             linewidth = 1, linetype = "dashed") +
  annotate("text",
           x = mean(deg_k) + 0.5, y = max(table(deg_k)) * 0.88,
           label = sprintf("Mean = %.1f\nGini = %.3f", mean(deg_k), gini_deg),
           color = "#E76F51", hjust = 0, size = 3.2, fontface = "bold") +
  scale_x_continuous(breaks = seq(1, max(deg_k))) +
  labs(title = "(a) Degree Distribution  [N = 53 stations]",
       x = "Degree (k)", y = "Number of Stations") +
  theme_bw(base_size = 11) + theme(plot.title = element_text(face = "bold"))

# (b) Log-log scale-free test
note_gamma <- sprintf(
  "\u03b3 = %.2f  (R\u00b2 = %.3f)\n\nNote: Spatial transport networks\ntypically yield \u03b3 < 2 due to\ngeographic embedding constraints\n(Barth\u00e9lemy, 2011).",
  gamma, r2_log
)

p_loglog <- ggplot(deg_freq, aes(x = log(k), y = log(P_k))) +
  geom_point(size = 3.2, color = "#2A9D8F") +
  geom_smooth(method = "lm", color = "#E76F51", se = TRUE,
              linewidth = 1.1, fill = "#E76F51", alpha = 0.13) +
  annotate("text", x = min(log(deg_freq$k)),
           y = max(log(deg_freq$P_k)) - 0.1,
           label = note_gamma, hjust = 0, vjust = 1,
           size = 2.9, color = "#264653") +
  labs(title = "(b) Log-Log Degree Distribution (Scale-Free Test)",
       x = "log(k)", y = "log P(k)") +
  theme_bw(base_size = 11) + theme(plot.title = element_text(face = "bold"))

# (c) Betweenness histogram
p_btw <- ggplot(data.frame(btw = btw_raw), aes(x = btw)) +
  geom_histogram(bins = 15, fill = "#A8DADC", color = "white", alpha = 0.9) +
  geom_vline(xintercept = mean(btw_raw), color = "#E63946",
             linewidth = 1, linetype = "dashed") +
  annotate("text",
           x = mean(btw_raw) + 0.005, y = Inf, vjust = 1.5, hjust = 0,
           label = sprintf("Mean = %.3f\nGini = %.3f", mean(btw_raw), gini_btw),
           color = "#E63946", size = 3.2, fontface = "bold") +
  labs(title = "(c) Betweenness Centrality Distribution  [N = 53]",
       x = "Normalized Betweenness Centrality", y = "Number of Stations") +
  theme_bw(base_size = 11) + theme(plot.title = element_text(face = "bold"))

# (d) Degree vs. betweenness scatter
cent_df <- centrality |>
  mutate(deg_k  = pmax(1, round(degree_cent * 52)),
         is_hub = composite >= 0.05)

p_scatter <- ggplot(cent_df, aes(x = deg_k, y = betweenness,
                                  size = composite, shape = is_hub)) +
  geom_point(alpha = 0.55, color = "#457B9D") +
  geom_point(data = top8 |> mutate(deg_k = pmax(1, round(degree_cent * 52))),
             aes(x = deg_k, y = betweenness),
             color = "#E63946", size = 4.8, shape = 17, inherit.aes = FALSE) +
  geom_text_repel(data = top8 |> mutate(deg_k = pmax(1, round(degree_cent * 52))),
                  aes(x = deg_k, y = betweenness, label = station),
                  size = 2.8, box.padding = 0.45, max.overlaps = 20,
                  segment.color = "grey60", inherit.aes = FALSE) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 17),
                     labels = c("Peripheral", "Hub (C_comp \u2265 0.05)"),
                     name   = "Node Type") +
  scale_size_continuous(range = c(1.5, 8), name = "Composite\nCentrality") +
  labs(title = "(d) Degree vs Betweenness  (Top-8 Hubs Highlighted)",
       x = "Degree (k)", y = "Betweenness Centrality") +
  theme_bw(base_size = 11) +
  theme(plot.title = element_text(face = "bold"), legend.position = "right")

fig_cent <- (p_hist | p_loglog) / (p_btw | p_scatter) +
  plot_annotation(
    title    = "Figure A2.  Centrality Distribution of the Korean Freight Rail Network",
    subtitle = sprintf(
      "Scale-free exponent \u03b3 = %.2f (R\u00b2 = %.3f) | Degree Gini = %.3f | Betweenness Gini = %.3f",
      gamma, r2_log, gini_deg, gini_btw
    ),
    caption  = paste0(
      "Note: \u03b3 < 2 is consistent with spatially embedded transport networks ",
      "subject to geographic constraints\n",
      "(Barth\u00e9lemy, 2011; Physics Reports). ",
      "High Gini coefficients confirm extreme centrality concentration."
    ),
    theme    = theme(
      plot.title    = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 9, color = "grey40"),
      plot.caption  = element_text(size = 8, color = "grey50")
    )
  )

ggsave(file.path(OUT_DIR, "Fig_centrality_distribution_v2.png"),
       fig_cent, width = 13, height = 10, dpi = 300)
message("\u2705  Fig_centrality_distribution_v2.png saved")

cat(sprintf("\nDegree Gini = %.4f | Betweenness Gini = %.4f\n", gini_deg, gini_btw))
cat(sprintf("Scale-free exponent gamma = %.2f (R2 = %.3f)\n\n", gamma, r2_log))
message("All revision figures complete. Check ", OUT_DIR)
