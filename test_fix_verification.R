#!/usr/bin/env Rscript

# Comprehensive test suite to verify the fix for protein domain and variant plotting issues
# This test verifies that:
# 1. Plots are created successfully when auto-retrieval succeeds
# 2. Plots are created with variants even when domains/PTMs are empty
# 3. Error messages are clear when auto-retrieval fails
# 4. Manual protein_length can be used as fallback

cat("\n")
cat("=========================================================\n")
cat("Test Suite: Protein Domain and Variant Plotting Fix\n")
cat("=========================================================\n\n")

# Load required libraries
library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# Create sample variant data
create_test_variants <- function(gene_name, n_variants = 5) {
  data.frame(
    Family_ID = paste0("FAM", sprintf("%03d", 1:n_variants)),
    CHROM = rep("chr1", n_variants),
    POS = seq(100, 100 + (n_variants - 1) * 100, by = 100),
    REF = rep(c("A", "C", "G", "T"), length.out = n_variants),
    ALT = rep(c("G", "T", "A", "C"), length.out = n_variants),
    vepSYMBOL = rep(gene_name, n_variants),
    vepMAX_AF = runif(n_variants, 0.001, 0.01),
    vepIMPACT = rep(c("HIGH", "MODERATE", "LOW"), length.out = n_variants),
    vepConsequence = rep(c("missense_variant", "synonymous_variant", "intron_variant"), length.out = n_variants),
    sample = paste0("S", sprintf("%03d", 1:n_variants)),
    kid_GT = rep(c("0/1", "1/1"), length.out = n_variants),
    stringsAsFactors = FALSE
  )
}

# Test counter
test_num <- 0
tests_passed <- 0
tests_failed <- 0

run_test <- function(test_name, test_func) {
  test_num <<- test_num + 1
  cat(sprintf("\nTest %d: %s\n", test_num, test_name))
  cat(strrep("-", 60), "\n")
  
  result <- tryCatch({
    test_func()
    cat("✓ PASSED\n")
    tests_passed <<- tests_passed + 1
    TRUE
  }, error = function(e) {
    cat("✗ FAILED\n")
    cat("Error:", e$message, "\n")
    tests_failed <<- tests_failed + 1
    FALSE
  })
  
  return(result)
}

# Test 1: Successful auto-retrieval with domains and PTMs
run_test("Auto-retrieval with complete data (mocked)", function() {
  source("R/detailed_lollipop_plot.R")
  
  # Mock successful retrieval (after sourcing)
  retrieve_protein_data <- function(gene_symbol, cache_dir = NULL) {
    list(
      domains = data.frame(
        gene = c("TEST1", "TEST1"),
        domain_name = c("Domain A", "Domain B"),
        start = c(10, 300),
        end = c(100, 400),
        stringsAsFactors = FALSE
      ),
      ptms = data.frame(
        gene = c("TEST1", "TEST1"),
        ptm_type = c("Phosphorylation", "Acetylation"),
        position = c(150, 250),
        description = c("Phospho", "Acetyl"),
        stringsAsFactors = FALSE
      ),
      protein_length = 500
    )
  }
  
  # Explicitly assign to parent environment so exists() can find it
  assign("retrieve_protein_data", retrieve_protein_data, envir = .GlobalEnv)
  
  variants <- create_test_variants("TEST1", 3)
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = "TEST1",
    output_file = "/tmp/test1.png",
    auto_retrieve = TRUE
  )
  
  if (!file.exists("/tmp/test1.png")) {
    stop("Plot file not created")
  }
  unlink("/tmp/test1.png")
})

# Test 2: Auto-retrieval with protein_length only (no domains/PTMs)
run_test("Auto-retrieval with protein_length but no domains/PTMs", function() {
  source("R/detailed_lollipop_plot.R")
  
  # Mock retrieval with length only (after sourcing)
  retrieve_protein_data <- function(gene_symbol, cache_dir = NULL) {
    list(
      domains = data.frame(
        gene = character(),
        domain_name = character(),
        start = numeric(),
        end = numeric(),
        stringsAsFactors = FALSE
      ),
      ptms = data.frame(
        gene = character(),
        ptm_type = character(),
        position = numeric(),
        description = character(),
        stringsAsFactors = FALSE
      ),
      protein_length = 500
    )
  }
  
  assign("retrieve_protein_data", retrieve_protein_data, envir = .GlobalEnv)
  
  variants <- create_test_variants("TEST2", 3)
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = "TEST2",
    output_file = "/tmp/test2.png",
    auto_retrieve = TRUE
  )
  
  if (!file.exists("/tmp/test2.png")) {
    stop("Plot file not created")
  }
  unlink("/tmp/test2.png")
})

# Test 3: Manual protein_length without auto-retrieval
run_test("Manual protein_length without auto-retrieval", function() {
  source("R/detailed_lollipop_plot.R")
  
  variants <- create_test_variants("TEST3", 3)
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = "TEST3",
    protein_length = 500,
    output_file = "/tmp/test3.png",
    auto_retrieve = FALSE
  )
  
  if (!file.exists("/tmp/test3.png")) {
    stop("Plot file not created")
  }
  unlink("/tmp/test3.png")
})

# Test 4: Manual data with domains and PTMs
run_test("Manual domains, PTMs, and protein_length", function() {
  source("R/detailed_lollipop_plot.R")
  
  domains <- data.frame(
    gene = c("TEST4", "TEST4"),
    domain_name = c("Domain X", "Domain Y"),
    start = c(10, 300),
    end = c(100, 400),
    stringsAsFactors = FALSE
  )
  
  ptms <- data.frame(
    gene = c("TEST4"),
    ptm_type = c("Phosphorylation"),
    position = c(150),
    description = c("Test PTM"),
    stringsAsFactors = FALSE
  )
  
  variants <- create_test_variants("TEST4", 3)
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    protein_domains = domains,
    ptms = ptms,
    gene_name = "TEST4",
    protein_length = 500,
    output_file = "/tmp/test4.png",
    auto_retrieve = FALSE
  )
  
  if (!file.exists("/tmp/test4.png")) {
    stop("Plot file not created")
  }
  unlink("/tmp/test4.png")
})

# Test 5: Auto-retrieval failure should give clear error
run_test("Auto-retrieval failure produces clear error message", function() {
  source("R/detailed_lollipop_plot.R")
  
  # Mock failed retrieval (after sourcing)
  retrieve_protein_data <- function(gene_symbol, cache_dir = NULL) {
    stop("Network error: Could not connect to UniProt")
  }
  
  assign("retrieve_protein_data", retrieve_protein_data, envir = .GlobalEnv)
  
  variants <- create_test_variants("TEST5", 3)
  
  error_caught <- FALSE
  error_msg <- ""
  
  tryCatch({
    plot <- create_detailed_lollipop_plot(
      variant_data = variants,
      gene_name = "TEST5",
      output_file = "/tmp/test5.png",
      auto_retrieve = TRUE
    )
  }, error = function(e) {
    error_caught <<- TRUE
    error_msg <<- e$message
  })
  
  if (!error_caught) {
    stop("Expected error was not thrown")
  }
  
  if (!grepl("Could not retrieve protein length", error_msg)) {
    stop(paste("Error message not helpful:", error_msg))
  }
  
  cat("Confirmed helpful error message:", error_msg, "\n")
})

# Test 6: Empty variant data should not crash
run_test("Empty variant data for gene", function() {
  source("R/detailed_lollipop_plot.R")
  
  # Create variants for different gene
  variants <- create_test_variants("OTHERGENE", 3)
  
  # Try to plot for gene with no variants
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = "TEST6",
    protein_length = 500,
    output_file = "/tmp/test6.png",
    auto_retrieve = FALSE
  )
  
  if (!file.exists("/tmp/test6.png")) {
    stop("Plot file not created")
  }
  unlink("/tmp/test6.png")
})

# Summary
cat("\n")
cat(strrep("=", 60), "\n")
cat("Test Summary\n")
cat(strrep("=", 60), "\n")
cat(sprintf("Total tests: %d\n", test_num))
cat(sprintf("Passed: %d\n", tests_passed))
cat(sprintf("Failed: %d\n", tests_failed))

if (tests_failed == 0) {
  cat("\n✓✓✓ ALL TESTS PASSED ✓✓✓\n\n")
  quit(status = 0)
} else {
  cat("\n✗✗✗ SOME TESTS FAILED ✗✗✗\n\n")
  quit(status = 1)
}
