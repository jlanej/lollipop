#!/usr/bin/env Rscript

# Example data generation script for detailed lollipop plots
# This creates sample datasets to demonstrate the functionality

#' Generate example variant data
#'
#' @return Data frame with example variant data
#' @export
generate_example_variants <- function() {
  set.seed(42)
  
  # Example variants for BRCA1 gene
  variants <- data.frame(
    Family_ID = paste0("FAM", sprintf("%03d", sample(1:20, 50, replace = TRUE))),
    CHROM = rep("chr17", 50),
    POS = sample(100:1800, 50, replace = TRUE),
    REF = sample(c("A", "C", "G", "T"), 50, replace = TRUE),
    ALT = sample(c("A", "C", "G", "T"), 50, replace = TRUE),
    vepSYMBOL = rep("BRCA1", 50),
    vepMAX_AF = runif(50, 0, 0.01),
    vepIMPACT = sample(c("HIGH", "MODERATE", "LOW", "MODIFIER"), 50, 
                      replace = TRUE, prob = c(0.1, 0.3, 0.3, 0.3)),
    vepConsequence = sample(c("missense_variant", "synonymous_variant", 
                             "frameshift_variant", "stop_gained",
                             "splice_donor_variant", "intron_variant"),
                           50, replace = TRUE, 
                           prob = c(0.3, 0.2, 0.1, 0.05, 0.05, 0.3)),
    sample = paste0("SAMPLE", sprintf("%03d", sample(1:30, 50, replace = TRUE))),
    kid_GT = sample(c("0/1", "1/1", "0/0"), 50, replace = TRUE, prob = c(0.45, 0.05, 0.5)),
    stringsAsFactors = FALSE
  )
  
  # Ensure REF and ALT are different
  same_allele <- variants$REF == variants$ALT
  variants$ALT[same_allele] <- ifelse(variants$REF[same_allele] == "A", "G", "A")
  
  # Filter to only variants where kid has the variant (not 0/0)
  variants <- variants[variants$kid_GT != "0/0", ]
  
  return(variants)
}

#' Generate example protein domain data
#'
#' @return Data frame with example protein domains
#' @export
generate_example_domains <- function() {
  # BRCA1 protein domains (simplified)
  domains <- data.frame(
    gene = c("BRCA1", "BRCA1", "BRCA1", "BRCA1"),
    domain_name = c("RING domain", "DNA binding", "BRCT domain 1", "BRCT domain 2"),
    start = c(1, 500, 1650, 1760),
    end = c(100, 800, 1740, 1855),
    stringsAsFactors = FALSE
  )
  
  return(domains)
}

#' Generate example PTM data
#'
#' @return Data frame with example PTMs
#' @export
generate_example_ptms <- function() {
  # Example Post-Translational Modifications for BRCA1
  ptms <- data.frame(
    gene = rep("BRCA1", 15),
    ptm_type = sample(c("Phosphorylation", "Acetylation", "Methylation", 
                       "Ubiquitination"), 15, replace = TRUE),
    position = c(150, 320, 456, 654, 789, 890, 1100, 1234, 1345, 1456, 
                1523, 1600, 1689, 1720, 1800),
    description = c("Regulatory phosphorylation", "DNA damage response",
                   "Cell cycle control", "Chromatin remodeling",
                   "Transcriptional regulation", "Protein stability",
                   "DNA repair function", "Signal transduction",
                   "Cell growth regulation", "Apoptosis regulation",
                   "DNA binding regulation", "Protein-protein interaction",
                   "Nuclear localization", "BRCT domain regulation",
                   "C-terminal regulation"),
    stringsAsFactors = FALSE
  )
  
  return(ptms)
}

#' Save example data to files
#'
#' @param output_dir Directory to save the files
#' @export
save_example_data <- function(output_dir = ".") {
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Generate and save variant data
  variants <- generate_example_variants()
  variant_file <- file.path(output_dir, "example_variants.tsv")
  write.table(variants, variant_file, sep = "\t", row.names = FALSE, quote = FALSE)
  cat("Saved variant data to:", variant_file, "\n")
  
  # Generate and save domain data
  domains <- generate_example_domains()
  domain_file <- file.path(output_dir, "example_domains.tsv")
  write.table(domains, domain_file, sep = "\t", row.names = FALSE, quote = FALSE)
  cat("Saved domain data to:", domain_file, "\n")
  
  # Generate and save PTM data
  ptms <- generate_example_ptms()
  ptm_file <- file.path(output_dir, "example_ptms.tsv")
  write.table(ptms, ptm_file, sep = "\t", row.names = FALSE, quote = FALSE)
  cat("Saved PTM data to:", ptm_file, "\n")
  
  return(list(variants = variant_file, domains = domain_file, ptms = ptm_file))
}

# Run example data generation when script is executed
if (!interactive()) {
  cat("Generating example data files...\n\n")
  files <- save_example_data()
  cat("\nExample data files created successfully!\n")
  cat("You can now use these files with the detailed_lollipop_plot.R script.\n")
}
