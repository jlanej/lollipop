#!/usr/bin/env Rscript

# Advanced example demonstrating additional features and customizations
# This script shows more complex usage patterns and data filtering

source("detailed_lollipop_plot.R")
source("example_data.R")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

cat("\n")
cat("Advanced Lollipop Plot Examples\n")
cat("================================\n\n")

# Generate example data
variants <- generate_example_variants()
domains <- generate_example_domains()
ptms <- generate_example_ptms()

# Example 1: Filter to high-impact variants only
cat("Example 1: High-Impact Variants Only\n")
cat("-------------------------------------\n")

high_impact <- variants %>%
  filter(vepIMPACT %in% c("HIGH", "MODERATE"))

cat("Total variants:", nrow(variants), "\n")
cat("High/moderate impact:", nrow(high_impact), "\n")

plot1 <- create_detailed_lollipop_plot(
  variant_data = high_impact,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_high_impact.png"
)

cat("Saved: brca1_high_impact.png\n\n")

# Example 2: Filter by allele frequency
cat("Example 2: Rare Variants (AF < 0.005)\n")
cat("--------------------------------------\n")

rare_variants <- variants %>%
  filter(vepMAX_AF < 0.005)

cat("Rare variants:", nrow(rare_variants), "\n")

plot2 <- create_detailed_lollipop_plot(
  variant_data = rare_variants,
  protein_domains = domains,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_rare_variants.png"
)

cat("Saved: brca1_rare_variants.png\n\n")

# Example 3: Specific consequence types
cat("Example 3: Missense Variants Only\n")
cat("----------------------------------\n")

missense <- variants %>%
  filter(vepConsequence == "missense_variant")

cat("Missense variants:", nrow(missense), "\n")

plot3 <- create_detailed_lollipop_plot(
  variant_data = missense,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_missense.png"
)

cat("Saved: brca1_missense.png\n\n")

# Example 4: Variants by region (domain-specific)
cat("Example 4: Variants in BRCT Domains (1650-1855)\n")
cat("-----------------------------------------------\n")

brct_variants <- variants %>%
  filter(POS >= 1650 & POS <= 1855)

cat("Variants in BRCT domains:", nrow(brct_variants), "\n")

# Filter domains to BRCT only
brct_domains <- domains %>%
  filter(grepl("BRCT", domain_name))

# Filter PTMs in region
brct_ptms <- ptms %>%
  filter(position >= 1650 & position <= 1855)

plot4 <- create_detailed_lollipop_plot(
  variant_data = brct_variants,
  protein_domains = brct_domains,
  ptms = brct_ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_brct_region.png",
  width = 12,
  height = 8
)

cat("Saved: brca1_brct_region.png\n\n")

# Example 5: Family-specific variants
cat("Example 5: Top 3 Families by Variant Count\n")
cat("-------------------------------------------\n")

family_counts <- variants %>%
  group_by(Family_ID) %>%
  summarise(n_variants = n()) %>%
  arrange(desc(n_variants)) %>%
  head(3)

print(family_counts)

for (i in 1:nrow(family_counts)) {
  fam_id <- family_counts$Family_ID[i]
  fam_variants <- variants %>% filter(Family_ID == fam_id)
  
  output_file <- paste0("brca1_", fam_id, ".png")
  
  plot_fam <- create_detailed_lollipop_plot(
    variant_data = fam_variants,
    protein_domains = domains,
    gene_name = "BRCA1",
    protein_length = 1863,
    output_file = output_file,
    width = 12,
    height = 8
  )
  
  cat("Saved:", output_file, "\n")
}

cat("\n")

# Example 6: Comprehensive summary statistics
cat("Example 6: Detailed Summary Statistics\n")
cat("---------------------------------------\n")

summary <- summarize_variants(variants, "BRCA1")

cat("\nOverall Statistics:\n")
cat("  Total variants:", summary$total_variants, "\n")
cat("  Unique positions:", summary$unique_positions, "\n")
cat("  Unique families:", summary$unique_families, "\n")
cat("  Unique samples:", summary$unique_samples, "\n")

cat("\nConsequence Distribution:\n")
cons_table <- as.data.frame(summary$consequence_counts)
names(cons_table) <- c("Consequence", "Count")
print(cons_table)

cat("\nImpact Distribution:\n")
impact_table <- as.data.frame(summary$impact_counts)
names(impact_table) <- c("Impact", "Count")
print(impact_table)

# Calculate additional statistics
cat("\nAllele Frequency Statistics:\n")
cat("  Min AF:", min(variants$vepMAX_AF), "\n")
cat("  Max AF:", max(variants$vepMAX_AF), "\n")
cat("  Mean AF:", mean(variants$vepMAX_AF), "\n")
cat("  Median AF:", median(variants$vepMAX_AF), "\n")

cat("\nGenotype Distribution:\n")
print(table(variants$kid_GT))

# Position distribution
cat("\nVariant Position Statistics:\n")
cat("  Min position:", min(variants$POS), "\n")
cat("  Max position:", max(variants$POS), "\n")
cat("  Mean position:", round(mean(variants$POS), 2), "\n")

# Hotspot analysis - positions with multiple variants
hotspots <- variants %>%
  group_by(POS) %>%
  summarise(n_variants = n()) %>%
  filter(n_variants > 1) %>%
  arrange(desc(n_variants))

if (nrow(hotspots) > 0) {
  cat("\nVariant Hotspots (positions with multiple variants):\n")
  print(hotspots)
}

cat("\n")
cat("Advanced examples completed!\n")
cat("Check the generated PNG files for visualizations.\n")
