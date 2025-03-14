# Load necessary libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Load the data (corrected file path with forward slashes or double backslashes)
data <- read.csv("C:/Users/sunch/Desktop/Project/PD1-Docking/5_old/interaction_results.csv")

# Convert from wide to long format
interaction_table <- data %>%
  pivot_longer(cols = c("Residue.1", "Residue.2"), 
               values_to = "Residue") %>%
  filter(!grepl("R \\(", Residue))

# Summarize energy contributions by residue, and arrange in descending order by energy contribution
residue_table <- interaction_table %>%
  group_by(Residue) %>%
  summarize(Total_Energy_Contribution = sum(`Energy.Contribution`, na.rm = TRUE)) %>%
  arrange(desc(Total_Energy_Contribution))  # Ensure arrange is part of the same pipeline

# Select the top 10 residues
top_5_high_residues <- head(residue_table, 5)
top_5_high_residues$Residue <- factor(top_5_high_residues$Residue, levels = top_5_high_residues$Residue[order(top_5_high_residues$Total_Energy_Contribution, decreasing = TRUE)])

# Create a histogram plot for top 10 residues
ggplot(top_5_high_residues, aes(x = Residue, y = Total_Energy_Contribution)) +
  geom_bar(stat = "identity") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Top 5 Residues in Pembrolizumab with the Highest PD1 Binding Energy", x = "Residues", y = "Interaction Free Energy (kcal/mol)") +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 16)
  )

top_5_low_residues <- tail(residue_table, 5)
top_5_low_residues$Residue <- factor(top_5_low_residues$Residue, levels = top_5_low_residues$Residue[order(top_5_low_residues$Total_Energy_Contribution, decreasing = FALSE)])

# Create a histogram plot for top 10 residues
ggplot(top_5_low_residues, aes(x = Residue, y = Total_Energy_Contribution)) +
  geom_bar(stat = "identity") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Top 5 Residues in Pembrolizumab with the Lowest PD1 Binding Energy", x = "Residues", y = "Interaction Free Energy (kcal/mol)") +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 16)
  )
