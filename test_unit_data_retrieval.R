#!/usr/bin/env Rscript

# Unit test for retrieve_protein_data error handling
# This test verifies that protein_length is returned even when domain/PTM extraction fails

cat("\n")
cat("Unit Test: retrieve_protein_data Error Handling\n")
cat("================================================\n\n")

# Source data retrieval functions
source("data_retrieval.R")

# Test 1: Verify that retrieve_protein_data returns protein_length for JMJD1C
cat("Test 1: Retrieve protein data for JMJD1C\n")
cat(rep("-", 50), collapse = ""), "\n")

tryCatch({
  protein_data <- retrieve_protein_data("JMJD1C", cache_dir = ".unit_test_cache")
  
  cat("\nResults:\n")
  cat("  protein_length:", protein_data$protein_length, "\n")
  cat("  domains found:", nrow(protein_data$domains), "\n")
  cat("  ptms found:", nrow(protein_data$ptms), "\n")
  
  # Validate results
  if (is.null(protein_data$protein_length)) {
    cat("\n✗ FAIL: protein_length is NULL\n")
    cat("  This is the bug we're trying to fix!\n")
  } else {
    cat("\n✓ PASS: protein_length is not NULL\n")
    cat("  Expected: 2540 amino acids\n")
    cat("  Actual: ", protein_data$protein_length, " amino acids\n")
    
    if (protein_data$protein_length == 2540) {
      cat("  ✓ Length matches expected value\n")
    } else {
      cat("  ⚠ Length differs from expected (may be due to UniProt update)\n")
    }
  }
  
  # Check data structures
  if (is.data.frame(protein_data$domains)) {
    cat("  ✓ domains is a data frame\n")
  } else {
    cat("  ✗ domains is not a data frame\n")
  }
  
  if (is.data.frame(protein_data$ptms)) {
    cat("  ✓ ptms is a data frame\n")
  } else {
    cat("  ✗ ptms is not a data frame\n")
  }
  
}, error = function(e) {
  cat("\n✗ FAIL: Error occurred during retrieval\n")
  cat("  Error message:", e$message, "\n")
})

cat("\n")

# Test 2: Verify that other genes still work
cat("Test 2: Retrieve protein data for BRCA1 (control)\n")
cat(rep("-", 50), collapse = ""), "\n")

tryCatch({
  protein_data <- retrieve_protein_data("BRCA1", cache_dir = ".unit_test_cache")
  
  if (!is.null(protein_data$protein_length)) {
    cat("✓ PASS: BRCA1 protein_length retrieved successfully\n")
    cat("  Length:", protein_data$protein_length, "amino acids\n")
  } else {
    cat("✗ FAIL: BRCA1 protein_length is NULL\n")
  }
  
}, error = function(e) {
  cat("✗ FAIL: Error occurred for BRCA1\n")
  cat("  Error message:", e$message, "\n")
})

cat("\n")

# Clean up
if (dir.exists(".unit_test_cache")) {
  cat("Cleaning up test cache...\n")
  unlink(".unit_test_cache", recursive = TRUE)
}

cat("\nUnit tests complete!\n\n")
