# Load necessary libraries
library(ggplot2)
library(dplyr)
library(gridExtra)
library(ggpubr)
library(gtable)

# Function to extract total_score from a file
extract_total_score <- function(file_path, complex_name) {
  lines <- readLines(file_path)
  header_line <- grep("SCORE:", lines)[1]
  if (is.na(header_line)) stop("SCORE: header not found in file: ", file_path)
  
  # Extract header, remove punctuation and convert to lower case
  header <- strsplit(lines[header_line], "\\s+")[[1]]
  header <- tolower(gsub("[:]", "", header))
  
  score_lines <- lines[(header_line + 1):length(lines)]
  score_data <- sapply(score_lines, function(line) strsplit(line, "\\s+")[[1]])
  
  df <- as.data.frame(t(score_data), stringsAsFactors = FALSE)
  colnames(df) <- header
  
  # Extract total_score and assign complex labels
  total_score <- as.numeric(df[, "score"])
  complex_labels <- rep(complex_name, length(total_score))
  
  return(data.frame(total_score = total_score, Drugs = complex_labels))
}

# File paths for the different complexes
file_paths <- c("C:/Users/sunch/Desktop/Project/A Computer-Aided Drug Discovery Using the Rosetta Suite/1_Pembrolizumab/output/Pembrolizumab.txt", 
                "C:/Users/sunch/Desktop/Project/A Computer-Aided Drug Discovery Using the Rosetta Suite/2_Nivolumab/output/Nivolumab.txt", 
                "C:/Users/sunch/Desktop/Project/A Computer-Aided Drug Discovery Using the Rosetta Suite/3_Cemiplimab/output/Cemiplimab.txt")

# Extract total_score from each file
total_scores_pembrolizumab <- extract_total_score(file_paths[1], "Pembrolizumab")
total_scores_nivolumab <- extract_total_score(file_paths[2], "Nivolumab")
total_scores_cemiplimab <- extract_total_score(file_paths[3], "Cemiplimab")

# Combine all the data
df_scores <- rbind(total_scores_pembrolizumab, 
                   total_scores_nivolumab,
                   total_scores_cemiplimab)

# Calculate statistics for each complex
statistics <- df_scores %>%
  group_by(Drugs) %>%
  summarise(
    Mean = mean(total_score, na.rm = TRUE),
    Min = min(total_score, na.rm = TRUE),
    Max = max(total_score, na.rm = TRUE),
    SD = sd(total_score, na.rm = TRUE)
  )

# Round statistics to 2 decimal places
statistics_rounded <- statistics %>%
  mutate(across(c(Mean, Min, Max, SD), round, 2))

# Order the drugs based on the Mean
ordered_drugs <- statistics_rounded %>%
  arrange(Mean) %>%
  pull(Drugs)

df_scores$Drugs <- factor(df_scores$Drugs, levels = ordered_drugs)

# Box plot of total_score for the complexes
box_plot <- ggplot(df_scores, aes(x = Drugs, y = total_score)) +
  geom_boxplot() +
  labs(title = 'Comparison of Drug-PD-1 Complex Binding Energies Across Three Different Drugs',
       x = "Drugs", 
       y = "Binding Energy (kcal/mol)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Create the data table using tableGrob
statistics_table <- tableGrob(statistics_rounded, rows = NULL)

# Set fixed column widths using gtable::gtable_widths()
statistics_table$widths <- unit(rep(1 / ncol(statistics_rounded), ncol(statistics_rounded)), "npc")

# Arrange the plot and table using ggarrange
final_plot <- ggarrange(
  box_plot, statistics_table, 
  labels = c("A", "B"),
  ncol = 1, 
  heights = c(1.5, 1)
)

# Display the final plot with the fixed column width table
print(final_plot)

# Save the plot as a PDF with specified dimensions (9x5.5 inches)
ggsave("Figure1.pdf", final_plot, width = 9, height = 5.5, units = "in")
