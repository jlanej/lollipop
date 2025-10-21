#!/usr/bin/env Rscript

# Batch processing script for creating lollipop plots for multiple genes
# This script processes multiple genes at once with optional filtering

source("detailed_lollipop_plot.R")
source("data_retrieval.R")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

#' Batch process multiple genes
#'
#' @param variant_file Path to variant data file
#' @param gene_config Data frame with columns: gene_name, and optionally protein_length.
#'                    If protein_length is not provided, it will be auto-retrieved.
#' @param domain_file Optional path to domain data file. If NULL, domains will be auto-retrieved.
#' @param ptm_file Optional path to PTM data file. If NULL, PTMs will be auto-retrieved.
#' @param output_dir Directory to save plots (default: current directory)
#' @param filter_impact Optional vector of impacts to keep (e.g., c("HIGH", "MODERATE"))
#' @param filter_af Maximum allele frequency to keep (default: 1.0, no filtering)
#' @param filter_gt Filter to only variants present in kid (default: TRUE)
#' @param auto_retrieve If TRUE, automatically retrieve missing protein data from UniProt (default: TRUE)
#' @param cache_dir Optional directory to cache retrieved data (default: ".lollipop_cache")
#' @export
batch_process_genes <- function(variant_file,
                                gene_config,
                                domain_file = NULL,
                                ptm_file = NULL,
                                output_dir = ".",
                                filter_impact = NULL,
                                filter_af = 1.0,
                                filter_gt = TRUE,
                                auto_retrieve = TRUE,
                                cache_dir = ".lollipop_cache") {
  
  cat("\n")
  cat("Batch Processing Lollipop Plots\n")
  cat("================================\n\n")
  
  # Create output directory if needed
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("Created output directory:", output_dir, "\n")
  }
  
  # Load variant data
  cat("Loading variant data from:", variant_file, "\n")
  variants <- load_variant_data(variant_file)
  cat("Loaded", nrow(variants), "variants\n\n")
  
  # Apply filters
  original_count <- nrow(variants)
  
  if (filter_gt) {
    variants <- variants %>% filter(kid_GT != "0/0")
    cat("After filtering for kid variants:", nrow(variants), "remaining\n")
  }
  
  if (!is.null(filter_impact)) {
    variants <- variants %>% filter(vepIMPACT %in% filter_impact)
    cat("After filtering by impact:", nrow(variants), "remaining\n")
  }
  
  if (filter_af < 1.0) {
    variants <- variants %>% filter(vepMAX_AF <= filter_af)
    cat("After filtering by AF <=", filter_af, ":", nrow(variants), "remaining\n")
  }
  
  cat("Filtered from", original_count, "to", nrow(variants), "variants\n\n")
  
  # Load optional data
  domains <- NULL
  ptms <- NULL
  
  if (!is.null(domain_file) && file.exists(domain_file)) {
    domains <- read.delim(domain_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
    cat("Loaded domain data:", nrow(domains), "domains\n")
  }
  
  if (!is.null(ptm_file) && file.exists(ptm_file)) {
    ptms <- read.delim(ptm_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
    cat("Loaded PTM data:", nrow(ptms), "PTMs\n")
  }
  
  cat("\n")
  
  # Process each gene
  results <- list()
  
  for (i in 1:nrow(gene_config)) {
    gene_name <- gene_config$gene_name[i]
    
    # Get protein length - from config or auto-retrieve
    prot_length <- NULL
    if ("protein_length" %in% names(gene_config)) {
      prot_length <- gene_config$protein_length[i]
    }
    
    cat(paste(rep("-", 60), collapse = ""), "\n")
    cat("Processing gene", i, "of", nrow(gene_config), ":", gene_name, "\n")
    cat(paste(rep("-", 60), collapse = ""), "\n")
    
    # Filter variants for this gene
    gene_variants <- variants %>% filter(vepSYMBOL == gene_name)
    
    if (nrow(gene_variants) == 0) {
      cat("  No variants found for", gene_name, "\n")
      results[[gene_name]] <- list(status = "no_variants", count = 0)
      next
    }
    
    cat("  Variants for", gene_name, ":", nrow(gene_variants), "\n")
    
    # Get summary stats
    summary_stats <- summarize_variants(gene_variants, gene_name)
    cat("  Unique positions:", summary_stats$unique_positions, "\n")
    cat("  Families:", summary_stats$unique_families, "\n")
    cat("  Samples:", summary_stats$unique_samples, "\n")
    
    # Create output filename
    output_file <- file.path(output_dir, paste0(gene_name, "_lollipop.png"))
    
    # Create plot
    tryCatch({
      plot <- create_detailed_lollipop_plot(
        variant_data = gene_variants,
        protein_domains = domains,
        ptms = ptms,
        gene_name = gene_name,
        protein_length = prot_length,
        output_file = output_file,
        width = 16,
        height = 10,
        auto_retrieve = auto_retrieve,
        cache_dir = cache_dir
      )
      
      cat("  Plot saved to:", output_file, "\n")
      
      results[[gene_name]] <- list(
        status = "success",
        count = nrow(gene_variants),
        output = output_file,
        summary = summary_stats
      )
      
    }, error = function(e) {
      cat("  ERROR creating plot:", e$message, "\n")
      results[[gene_name]] <- list(status = "error", message = e$message)
    })
    
    cat("\n")
  }
  
  # Print summary
  cat(paste(rep("=", 60), collapse = ""), "\n")
  cat("Batch Processing Summary\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  success_count <- sum(sapply(results, function(x) x$status == "success"))
  cat("Successfully processed:", success_count, "/", nrow(gene_config), "genes\n")
  
  no_variant_count <- sum(sapply(results, function(x) x$status == "no_variants"))
  if (no_variant_count > 0) {
    cat("Genes with no variants:", no_variant_count, "\n")
  }
  
  error_count <- sum(sapply(results, function(x) x$status == "error"))
  if (error_count > 0) {
    cat("Genes with errors:", error_count, "\n")
  }
  
  cat("\nPlots saved to:", output_dir, "\n")
  
  return(invisible(results))
}

# Example usage when run as script
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) < 2) {
    cat("Usage: Rscript batch_process.R <variant_file> <gene_config_file> [domain_file] [ptm_file] [output_dir]\n")
    cat("\nGene config file format (TSV):\n")
    cat("  gene_name    [protein_length]\n")
    cat("  BRCA1        1863\n")
    cat("  TP53         393\n")
    cat("\n  Note: protein_length is optional. If not provided, it will be auto-retrieved from UniProt.\n")
    cat("\nOptional arguments:\n")
    cat("  domain_file: Path to protein domain data (auto-retrieved if not provided)\n")
    cat("  ptm_file: Path to PTM data (auto-retrieved if not provided)\n")
    cat("  output_dir: Directory to save plots (default: plots/)\n")
    cat("\nExamples:\n")
    cat("  # With auto-retrieval (only gene names needed):\n")
    cat("  Rscript batch_process.R variants.tsv genes.tsv\n")
    cat("\n  # With manual domain/PTM data:\n")
    cat("  Rscript batch_process.R variants.tsv genes.tsv domains.tsv ptms.tsv output_plots/\n")
    quit(status = 1)
  }
  
  variant_file <- args[1]
  gene_config_file <- args[2]
  domain_file <- if (length(args) >= 3) args[3] else NULL
  ptm_file <- if (length(args) >= 4) args[4] else NULL
  output_dir <- if (length(args) >= 5) args[5] else "plots"
  
  # Load gene configuration
  gene_config <- read.delim(gene_config_file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # Validate gene config
  if (!"gene_name" %in% names(gene_config)) {
    stop("Gene config file must have column: gene_name")
  }
  
  # protein_length is now optional
  
  # Run batch processing
  results <- batch_process_genes(
    variant_file = variant_file,
    gene_config = gene_config,
    domain_file = domain_file,
    ptm_file = ptm_file,
    output_dir = output_dir,
    filter_gt = TRUE,  # Filter to variants present in kid
    filter_impact = c("HIGH", "MODERATE"),  # Only high/moderate impact
    filter_af = 0.01  # Only variants with AF < 1%
  )
}
