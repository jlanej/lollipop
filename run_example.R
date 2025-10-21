#!/usr/bin/env Rscript

# Complete example demonstrating the detailed lollipop plot functionality
# This script shows how to use all features together

# Source the required scripts
source("detailed_lollipop_plot.R")
source("example_data.R")

# Load required libraries
if (!require("ggplot2")) install.packages("ggplot2", repos = "http://cran.r-project.org")
if (!require("dplyr")) install.packages("dplyr", repos = "http://cran.r-project.org")
if (!require("scales")) install.packages("scales", repos = "http://cran.r-project.org")
if (!require("ggrepel")) install.packages("ggrepel", repos = "http://cran.r-project.org")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# Generate example data
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("Detailed Lollipop Plot - Complete Example\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

cat("Step 1: Generating example data...\n")
variants <- generate_example_variants()
domains <- generate_example_domains()
ptms <- generate_example_ptms()

cat("  - Generated", nrow(variants), "variant records\n")
cat("  - Generated", nrow(domains), "protein domains\n")
cat("  - Generated", nrow(ptms), "PTM records\n\n")

# Display sample of the data
cat("Step 2: Sample of variant data:\n")
print(head(variants, 5))
cat("\n")

# Get summary statistics
cat("Step 3: Variant summary statistics:\n")
summary_stats <- summarize_variants(variants, "BRCA1")
cat("  Total variants:", summary_stats$total_variants, "\n")
cat("  Unique positions:", summary_stats$unique_positions, "\n")
cat("  Unique families:", summary_stats$unique_families, "\n")
cat("  Unique samples:", summary_stats$unique_samples, "\n\n")

cat("  Consequence distribution:\n")
print(summary_stats$consequence_counts)
cat("\n")

cat("  Impact distribution:\n")
print(summary_stats$impact_counts)
cat("\n\n")

# Create the detailed lollipop plot
cat("Step 4: Creating detailed lollipop plot...\n")
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_detailed_lollipop.png",
  width = 16,
  height = 10
)

cat("  Plot created and saved to: brca1_detailed_lollipop.png\n\n")

# Create additional plot without domains/PTMs for comparison
cat("Step 5: Creating simplified plot (variants only)...\n")
plot_simple <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_simple_lollipop.png",
  width = 14,
  height = 8
)

cat("  Simplified plot saved to: brca1_simple_lollipop.png\n\n")

# Save the example data to files for future use
cat("Step 6: Saving example data to files...\n")
write.table(variants, "example_variants.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(domains, "example_domains.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(ptms, "example_ptms.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
cat("  Data files saved:\n")
cat("    - example_variants.tsv\n")
cat("    - example_domains.tsv\n")
cat("    - example_ptms.tsv\n\n")

cat(paste(rep("=", 70), collapse = ""), "\n")
cat("Example completed successfully!\n")
cat("Check the generated PNG files to view the lollipop plots.\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
