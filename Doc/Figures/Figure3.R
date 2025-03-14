# Load required packages
library(ggplot2)
library(dplyr)

# Create a data frame with the values for each metric and group
data <- data.frame(
  Metric = rep(c("Overall Binding Energy", 
                 "Overall van der Waals Energy", 
                 "Overall Hydrogen Bonding Energy", 
                 "Electrostatic Interactions", 
                 "Rotamer Penalty", 
                 "Backbone Conformational Quality", 
                 "Interface Hydrogen Bonds", 
                 "Interface Energy Density"), each = 3),
  Group = rep(c("Original", "Point Mutation", "CDR Mutation"), times = 8),
  Value = c(
    # Overall Binding Energy
    -752.43, -1314.11, -1519.07,
    # Overall van der Waals Energy (fa_atr + fa_rep)
    -2513.23, -2558.73, -2632.80,
    # Overall Hydrogen Bonding Energy (sum of hbond_sr_bb, hbond_lr_bb, hbond_bb_sc, hbond_sc)
    -456.00, -480.02, -511.15,
    # Electrostatic Interactions (fa_elec)
    -811.03, -891.26, -932.43,
    # Rotamer Penalty (fa_dun)
    934.09, 644.24, 625.67,
    # Backbone Conformational Quality (rama_prepro)
    51.90, 29.18, 17.09,
    # Interface Hydrogen Bonds (hbonds_int) -- note: higher is better so no asterisk
    8, 2, 12,
    # Interface Energy Density (dG_separated/dSASAx100)
    1.243, -1.274, -2.843
  )
)

# Ensure the group order is as desired
data$Group <- factor(data$Group, levels = c("Original", "Point Mutation", "CDR Mutation"))

# Define metrics for which a lower value is better
lowerBetter <- c("Overall Binding Energy", 
                 "Overall van der Waals Energy", 
                 "Overall Hydrogen Bonding Energy", 
                 "Electrostatic Interactions", 
                 "Rotamer Penalty", 
                 "Backbone Conformational Quality", 
                 "Interface Energy Density")

# Create a new column for metric labels: add a "*" if lower is better
data <- data %>%
  mutate(MetricLabel = ifelse(Metric %in% lowerBetter,
                              paste0(Metric, " *"),
                              Metric))

# Ensure the order of the metric labels remains as provided
unique_labels <- sapply(c("Overall Binding Energy", 
                          "Overall van der Waals Energy", 
                          "Overall Hydrogen Bonding Energy", 
                          "Electrostatic Interactions", 
                          "Rotamer Penalty", 
                          "Backbone Conformational Quality", 
                          "Interface Hydrogen Bonds", 
                          "Interface Energy Density"), 
                        function(x) if(x %in% lowerBetter) paste0(x, " *") else x)
data$MetricLabel <- factor(data$MetricLabel, levels = unique_labels)

# Create a faceted bar plot with 2 rows and 4 columns, each with its own y-scale and no x-axis title
ggplot(data, aes(x = Group, y = Value, fill = Group)) +
  geom_bar(stat = "identity", width = 0.7) +
  facet_wrap(~ MetricLabel, scales = "free_y", nrow = 2, ncol = 4) +
  labs(title = "Comparison of Key Binding Metrics",
       y = "Value") +
  theme_bw() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_text(size = 10),
        legend.position = "none")
