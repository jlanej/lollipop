#!/usr/bin/env Rscript

# Test script for automatic data retrieval functionality
# This script tests the new auto-retrieval features

cat("\n")
cat("Testing Automatic Data Retrieval\n")
cat("=================================\n\n")

# Source required scripts
source("data_retrieval.R")

# Test genes
test_genes <- c("BRCA1", "TP53", "PTEN")

cat("Testing data retrieval for multiple genes...\n\n")

for (gene in test_genes) {
  cat(paste(rep("-", 60), collapse = ""), "\n")
  cat("Testing:", gene, "\n")
  cat(paste(rep("-", 60), collapse = ""), "\n")
  
  tryCatch({
    # Retrieve protein data
    protein_data <- retrieve_protein_data(gene, cache_dir = ".test_cache")
    
    cat("\nResults:\n")
    cat("  Protein length:", protein_data$protein_length, "amino acids\n")
    cat("  Domains found:", nrow(protein_data$domains), "\n")
    if (nrow(protein_data$domains) > 0) {
      cat("    Domain names:", paste(protein_data$domains$domain_name, collapse = ", "), "\n")
    }
    cat("  PTMs found:", nrow(protein_data$ptms), "\n")
    if (nrow(protein_data$ptms) > 0) {
      ptm_summary <- table(protein_data$ptms$ptm_type)
      cat("    PTM types:", paste(names(ptm_summary), "=", ptm_summary, collapse = ", "), "\n")
    }
    
    cat("  ✓ SUCCESS\n")
    
  }, error = function(e) {
    cat("  ✗ ERROR:", e$message, "\n")
  })
  
  cat("\n")
}

cat(paste(rep("=", 60), collapse = ""), "\n")
cat("Testing complete!\n")
cat("\nCached data stored in .test_cache/ directory\n")

# Clean up test cache
if (dir.exists(".test_cache")) {
  cat("Removing test cache directory...\n")
  unlink(".test_cache", recursive = TRUE)
  cat("Test cache cleaned up.\n")
}

cat("\n")
