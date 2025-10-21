#!/usr/bin/env Rscript

# Example demonstrating automatic data retrieval
# This shows how to create plots with only variant data - no manual domain/PTM data needed!

source("detailed_lollipop_plot.R")
source("example_data.R")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

cat("\n")
cat("Automatic Data Retrieval Example\n")
cat("=================================\n\n")

cat("This example demonstrates the new auto-retrieval feature.\n")
cat("You only need to provide variant data - domains and PTMs are fetched automatically!\n\n")

# Generate example variant data
cat("Step 1: Generating example variant data...\n")
variants <- generate_example_variants()
cat("  Generated", nrow(variants), "variants for BRCA1\n\n")

# Create plot with automatic data retrieval
cat("Step 2: Creating lollipop plot with auto-retrieval...\n")
cat("  This will fetch protein length, domains, and PTMs from UniProt\n\n")

plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  # Note: no protein_domains, ptms, or protein_length provided!
  # They will be automatically retrieved from UniProt
  output_file = "brca1_auto_retrieval.png",
  width = 16,
  height = 10,
  auto_retrieve = TRUE,
  cache_dir = ".lollipop_cache"
)

cat("\n")
cat("Plot created successfully!\n")
cat("  Output: brca1_auto_retrieval.png\n")
cat("  Data cached in: .lollipop_cache/\n\n")

cat("Step 3: Creating a second plot (using cached data)...\n")
cat("  This should be faster as data is already cached\n\n")

# Filter to high-impact variants
high_impact <- variants %>%
  filter(vepIMPACT %in% c("HIGH", "MODERATE"))

plot2 <- create_detailed_lollipop_plot(
  variant_data = high_impact,
  gene_name = "BRCA1",
  output_file = "brca1_high_impact_auto.png",
  width = 16,
  height = 10,
  auto_retrieve = TRUE,
  cache_dir = ".lollipop_cache"
)

cat("\n")
cat("Second plot created!\n")
cat("  Output: brca1_high_impact_auto.png\n\n")

# Try with a different gene
cat("Step 4: Testing with TP53...\n\n")

# Create some TP53 variants
tp53_variants <- data.frame(
  Family_ID = paste0("FAM", sprintf("%03d", sample(1:10, 20, replace = TRUE))),
  CHROM = rep("chr17", 20),
  POS = sample(50:350, 20, replace = TRUE),
  REF = sample(c("A", "C", "G", "T"), 20, replace = TRUE),
  ALT = sample(c("A", "C", "G", "T"), 20, replace = TRUE),
  vepSYMBOL = rep("TP53", 20),
  vepMAX_AF = runif(20, 0, 0.01),
  vepIMPACT = sample(c("HIGH", "MODERATE", "LOW"), 20, replace = TRUE),
  vepConsequence = sample(c("missense_variant", "stop_gained", "frameshift_variant"), 20, replace = TRUE),
  sample = paste0("S", sprintf("%03d", sample(1:15, 20, replace = TRUE))),
  kid_GT = sample(c("0/1", "1/1"), 20, replace = TRUE),
  stringsAsFactors = FALSE
)

# Fix same alleles
same_allele <- tp53_variants$REF == tp53_variants$ALT
tp53_variants$ALT[same_allele] <- ifelse(tp53_variants$REF[same_allele] == "A", "G", "A")

plot3 <- create_detailed_lollipop_plot(
  variant_data = tp53_variants,
  gene_name = "TP53",
  # No protein_length provided - will be auto-retrieved
  output_file = "tp53_auto_retrieval.png",
  width = 14,
  height = 8,
  auto_retrieve = TRUE,
  cache_dir = ".lollipop_cache"
)

cat("\n")
cat("TP53 plot created!\n")
cat("  Output: tp53_auto_retrieval.png\n\n")

cat(paste(rep("=", 60), collapse = ""), "\n")
cat("Auto-retrieval example completed successfully!\n\n")
cat("Key benefits:\n")
cat("  ✓ No need to manually download domain data\n")
cat("  ✓ No need to manually download PTM data\n")
cat("  ✓ No need to look up protein lengths\n")
cat("  ✓ Data is cached for faster subsequent use\n")
cat("  ✓ Works with any human gene symbol\n\n")

cat("Files created:\n")
cat("  - brca1_auto_retrieval.png\n")
cat("  - brca1_high_impact_auto.png\n")
cat("  - tp53_auto_retrieval.png\n")
cat("  - .lollipop_cache/ (cached protein data)\n\n")
