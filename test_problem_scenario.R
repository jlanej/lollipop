#!/usr/bin/env Rscript

# Reproduces the exact scenario from the problem statement
# This should now work with the fix

cat("\n")
cat("Reproducing Problem Statement Scenario\n")
cat("=======================================\n\n")

cat("This test reproduces the exact scenario from the problem statement:\n")
cat("  - Call create_detailed_lollipop_plot with auto_retrieve = TRUE\n")
cat("  - Use gene JMJD1C\n")
cat("  - Expect it to retrieve protein data and create a plot\n\n")

# Source required files
source("data_retrieval.R")
source("detailed_lollipop_plot.R")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)
library(httr)
library(jsonlite)

# Create minimal test data for JMJD1C
combined_report <- data.frame(
  Family_ID = c("FAM001", "FAM002", "FAM003"),
  CHROM = c("chr10", "chr10", "chr10"),
  POS = c(100, 200, 300),
  REF = c("A", "C", "G"),
  ALT = c("G", "T", "A"),
  vepSYMBOL = c("JMJD1C", "JMJD1C", "JMJD1C"),
  vepMAX_AF = c(0.001, 0.002, 0.001),
  vepIMPACT = c("HIGH", "MODERATE", "LOW"),
  vepConsequence = c("missense_variant", "synonymous_variant", "intron_variant"),
  sample = c("S001", "S002", "S003"),
  kid_GT = c("0/1", "0/1", "1/1"),
  stringsAsFactors = FALSE
)

cat("Created test variant data with", nrow(combined_report), "variants\n\n")

cat("Attempting to create plot with auto_retrieve = TRUE...\n")
cat("Expected output:\n")
cat("  Auto-retrieving protein data for JMJD1C\n")
cat("  Fetching protein data for JMJD1C from UniProt...\n")
cat("    Found UniProt accession: Q15652\n")
cat("    Protein length: 2540 amino acids\n")
cat("    Found X domains (may be 0 if extraction fails)\n")
cat("    Found X PTMs (may be 0 if extraction fails)\n")
cat("  Plot created successfully\n\n")

cat("Actual output:\n")
cat(rep("=", 60), collapse = ""), "\n")

tryCatch({
  plot <- create_detailed_lollipop_plot(
    variant_data = combined_report,
    gene_name = "JMJD1C",
    output_file = "JMJD1C_lollipop.png",
    auto_retrieve = TRUE
  )
  
  cat(rep("=", 60), collapse = ""), "\n\n")
  cat("✓✓✓ SUCCESS ✓✓✓\n\n")
  cat("The fix is working! The plot was created successfully.\n")
  cat("This means protein_length was retrieved even if domain/PTM extraction had issues.\n\n")
  cat("Output file: JMJD1C_lollipop.png\n\n")
  
  # Clean up
  if (file.exists("JMJD1C_lollipop.png")) {
    cat("Cleaning up output file...\n")
    unlink("JMJD1C_lollipop.png")
  }
  
}, error = function(e) {
  cat(rep("=", 60), collapse = ""), "\n\n")
  cat("✗✗✗ FAILURE ✗✗✗\n\n")
  cat("Error:", e$message, "\n\n")
  cat("If the error is 'protein_length must be provided or auto_retrieve must be enabled',\n")
  cat("then the fix did not work. The protein_length was not successfully retrieved.\n\n")
  cat("If the error is something else, there may be a different issue.\n\n")
})

# Clean up cache if it exists
if (dir.exists(".lollipop_cache")) {
  cat("Cleaning up cache directory...\n")
  unlink(".lollipop_cache", recursive = TRUE)
}

cat("\nTest complete!\n\n")
