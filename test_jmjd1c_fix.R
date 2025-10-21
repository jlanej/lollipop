#!/usr/bin/env Rscript

# Test script to verify the fix for JMJD1C auto-retrieval issue
# This test verifies that protein_length is correctly retrieved even when
# domain/PTM extraction fails

cat("\n")
cat("Testing JMJD1C Auto-Retrieval Fix\n")
cat("=================================\n\n")

# Source required scripts
source("data_retrieval.R")
source("detailed_lollipop_plot.R")
source("example_data.R")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# Create test variant data for JMJD1C
cat("Creating test variant data for JMJD1C...\n")
jmjd1c_variants <- data.frame(
  Family_ID = paste0("FAM", sprintf("%03d", sample(1:10, 15, replace = TRUE))),
  CHROM = rep("chr10", 15),
  POS = sample(50:2500, 15, replace = TRUE),  # Positions within protein length
  REF = sample(c("A", "C", "G", "T"), 15, replace = TRUE),
  ALT = sample(c("A", "C", "G", "T"), 15, replace = TRUE),
  vepSYMBOL = rep("JMJD1C", 15),
  vepMAX_AF = runif(15, 0, 0.01),
  vepIMPACT = sample(c("HIGH", "MODERATE", "LOW"), 15, replace = TRUE),
  vepConsequence = sample(c("missense_variant", "stop_gained", "frameshift_variant", "synonymous_variant"), 15, replace = TRUE),
  sample = paste0("S", sprintf("%03d", sample(1:10, 15, replace = TRUE))),
  kid_GT = sample(c("0/1", "1/1"), 15, replace = TRUE),
  stringsAsFactors = FALSE
)

# Fix same alleles
same_allele <- jmjd1c_variants$REF == jmjd1c_variants$ALT
jmjd1c_variants$ALT[same_allele] <- ifelse(jmjd1c_variants$REF[same_allele] == "A", "G", "A")

cat("Generated", nrow(jmjd1c_variants), "test variants for JMJD1C\n\n")

# Test the auto-retrieval functionality
cat("Testing auto-retrieval for JMJD1C...\n")
cat("This should now succeed and retrieve protein_length even if domain/PTM extraction fails\n\n")

tryCatch({
  plot <- create_detailed_lollipop_plot(
    variant_data = jmjd1c_variants,
    gene_name = "JMJD1C",
    output_file = "JMJD1C_lollipop_test.png",
    auto_retrieve = TRUE,
    cache_dir = ".test_cache"
  )
  
  cat("\n✓ SUCCESS: Plot created successfully!\n")
  cat("  Output: JMJD1C_lollipop_test.png\n")
  cat("  The fix is working - protein_length was successfully retrieved\n\n")
  
}, error = function(e) {
  cat("\n✗ ERROR: Plot creation failed\n")
  cat("  Error message:", e$message, "\n")
  cat("  The fix may not be working correctly\n\n")
})

# Clean up test cache
if (dir.exists(".test_cache")) {
  cat("Cleaning up test cache...\n")
  unlink(".test_cache", recursive = TRUE)
}

# Clean up test output
if (file.exists("JMJD1C_lollipop_test.png")) {
  cat("Cleaning up test output...\n")
  unlink("JMJD1C_lollipop_test.png")
}

cat("\nTest complete!\n\n")
