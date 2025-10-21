# Detailed Lollipop Plot for Genomic Variants
# This script creates lollipop plots showing:
# - Protein domain information
# - Post Translational Modifications (PTMs)
# - Variant positions with counts
# - Color coding by vepConsequence

#' Create a detailed lollipop plot for genomic variants
#'
#' @param variant_data Data frame with columns: Family_ID, CHROM, POS, REF, ALT, 
#'                     vepSYMBOL, vepMAX_AF, vepIMPACT, vepConsequence, sample, kid_GT
#' @param protein_domains Data frame with columns: gene, domain_name, start, end.
#'                        If NULL and auto_retrieve=TRUE, will be fetched from UniProt.
#' @param ptms Data frame with columns: gene, ptm_type, position, description.
#'             If NULL and auto_retrieve=TRUE, will be fetched from UniProt.
#' @param gene_name Gene name to plot (should match vepSYMBOL). Used as HUGO gene symbol for data retrieval.
#' @param protein_length Total length of the protein in amino acids. 
#'                       If NULL and auto_retrieve=TRUE, will be fetched from UniProt.
#' @param output_file Optional output file path for saving the plot
#' @param width Plot width in inches (default: 14)
#' @param height Plot height in inches (default: 10)
#' @param auto_retrieve If TRUE, automatically retrieve domain and PTM data from UniProt when not provided (default: TRUE)
#' @param cache_dir Optional directory to cache retrieved data (default: ".lollipop_cache")
#' @return ggplot object
#' @export
create_detailed_lollipop_plot <- function(variant_data, 
                                          protein_domains = NULL, 
                                          ptms = NULL,
                                          gene_name,
                                          protein_length = NULL,
                                          output_file = NULL,
                                          width = 14,
                                          height = 10,
                                          auto_retrieve = TRUE,
                                          cache_dir = ".lollipop_cache") {
  
  # Auto-retrieve protein data if needed
  if (auto_retrieve && (is.null(protein_domains) || is.null(ptms) || is.null(protein_length))) {
    if (exists("retrieve_protein_data")) {
      message(paste("Auto-retrieving protein data for", gene_name))
      
      tryCatch({
        protein_data <- retrieve_protein_data(gene_name, cache_dir)
        
        # Use retrieved data if not provided
        if (is.null(protein_domains) && nrow(protein_data$domains) > 0) {
          protein_domains <- protein_data$domains
          message(paste("  Using", nrow(protein_domains), "retrieved domains"))
        }
        
        if (is.null(ptms) && nrow(protein_data$ptms) > 0) {
          ptms <- protein_data$ptms
          message(paste("  Using", nrow(ptms), "retrieved PTMs"))
        }
        
        if (is.null(protein_length) && !is.null(protein_data$protein_length)) {
          protein_length <- protein_data$protein_length
          message(paste("  Using retrieved protein length:", protein_length))
        }
      }, error = function(e) {
        warning(paste("Failed to auto-retrieve protein data:", e$message))
      })
    } else {
      warning("Auto-retrieve requested but data_retrieval.R functions not available")
    }
  }
  
  # Validate protein_length
  if (is.null(protein_length)) {
    stop("protein_length must be provided or auto_retrieve must be enabled")
  }
  
  # Filter data for the specified gene
  gene_variants <- variant_data %>%
    filter(vepSYMBOL == gene_name) %>%
    mutate(aa_pos = as.numeric(POS)) # Assuming POS can be converted to AA position
  
  # Count variants per position
  variant_counts <- gene_variants %>%
    group_by(aa_pos, vepConsequence, REF, ALT) %>%
    summarise(
      count = n(),
      families = paste(unique(Family_ID), collapse = ", "),
      samples = paste(unique(sample), collapse = ", "),
      .groups = "drop"
    )
  
  # Define consequence colors (following VEP impact colors)
  consequence_colors <- c(
    "HIGH" = "#FF0000",
    "MODERATE" = "#FFA500", 
    "LOW" = "#FFFF00",
    "MODIFIER" = "#00FF00",
    "frameshift_variant" = "#FF0000",
    "stop_gained" = "#FF0000",
    "stop_lost" = "#FF0000",
    "start_lost" = "#FF0000",
    "splice_acceptor_variant" = "#FF0000",
    "splice_donor_variant" = "#FF0000",
    "missense_variant" = "#FFA500",
    "inframe_deletion" = "#FFA500",
    "inframe_insertion" = "#FFA500",
    "synonymous_variant" = "#00AA00",
    "intron_variant" = "#87CEEB",
    "5_prime_UTR_variant" = "#7FFFD4",
    "3_prime_UTR_variant" = "#7FFFD4"
  )
  
  # Create base plot
  p <- ggplot() +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "right",
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.title = element_text(size = 12, face = "bold")
    ) +
    labs(
      title = paste("Detailed Lollipop Plot for", gene_name),
      subtitle = paste("Protein length:", protein_length, "amino acids"),
      x = "Amino Acid Position",
      y = "",
      color = "VEP Consequence",
      size = "Variant Count"
    ) +
    xlim(0, protein_length)
  
  # Add protein domains if provided
  y_offset <- 0
  if (!is.null(protein_domains)) {
    domains <- protein_domains %>% filter(gene == gene_name)
    if (nrow(domains) > 0) {
      domain_y <- -2
      for (i in 1:nrow(domains)) {
        domain <- domains[i, ]
        p <- p + 
          annotate("rect", 
                   xmin = domain$start, xmax = domain$end,
                   ymin = domain_y - 0.3, ymax = domain_y + 0.3,
                   fill = "steelblue", alpha = 0.6) +
          annotate("text", 
                   x = (domain$start + domain$end) / 2,
                   y = domain_y - 0.8,
                   label = domain$domain_name,
                   size = 3, hjust = 0.5)
      }
      y_offset <- -3
    }
  }
  
  # Add PTMs if provided
  if (!is.null(ptms)) {
    ptm_data <- ptms %>% filter(gene == gene_name)
    if (nrow(ptm_data) > 0) {
      ptm_y <- y_offset - 1.5
      
      # Define PTM shapes
      ptm_shapes <- c(
        "Phosphorylation" = 24,
        "Acetylation" = 22,
        "Methylation" = 23,
        "Ubiquitination" = 25,
        "Glycosylation" = 21
      )
      
      p <- p +
        geom_point(data = ptm_data,
                   aes(x = position, y = ptm_y, shape = ptm_type),
                   size = 4, fill = "purple", alpha = 0.7) +
        scale_shape_manual(name = "PTM Type", values = ptm_shapes) +
        annotate("text", x = 0, y = ptm_y - 0.8, 
                 label = "PTMs", size = 3, hjust = 0, fontface = "bold")
    }
  }
  
  # Add protein backbone line
  p <- p +
    geom_segment(aes(x = 0, xend = protein_length, y = 0, yend = 0),
                 size = 2, color = "gray40")
  
  # Add variant lollipops
  if (nrow(variant_counts) > 0) {
    # Determine colors for consequences
    variant_counts <- variant_counts %>%
      mutate(color = ifelse(vepConsequence %in% names(consequence_colors),
                           vepConsequence,
                           "MODIFIER"))
    
    # Add lollipop stems
    p <- p +
      geom_segment(data = variant_counts,
                   aes(x = aa_pos, xend = aa_pos, y = 0, yend = count),
                   color = "gray60", size = 0.5)
    
    # Add lollipop heads
    p <- p +
      geom_point(data = variant_counts,
                 aes(x = aa_pos, y = count, 
                     color = vepConsequence, size = count),
                 alpha = 0.8) +
      scale_color_manual(values = consequence_colors,
                        breaks = names(consequence_colors)) +
      scale_size_continuous(range = c(3, 10))
    
    # Add variant labels for high-impact variants
    high_impact_variants <- variant_counts %>%
      filter(count > 1 | vepConsequence %in% c("frameshift_variant", "stop_gained", 
                                                 "stop_lost", "start_lost",
                                                 "splice_acceptor_variant", 
                                                 "splice_donor_variant"))
    
    if (nrow(high_impact_variants) > 0) {
      p <- p +
        geom_text_repel(data = high_impact_variants,
                       aes(x = aa_pos, y = count, 
                           label = paste0(REF, aa_pos, ALT)),
                       size = 3,
                       box.padding = 0.5,
                       point.padding = 0.3,
                       segment.color = "gray50",
                       max.overlaps = 20)
    }
  }
  
  # Add horizontal line at y=0
  p <- p + geom_hline(yintercept = 0, linetype = "solid", color = "gray40", size = 0.5)
  
  # Save plot if output file specified
  if (!is.null(output_file)) {
    ggsave(output_file, plot = p, width = width, height = height, dpi = 300)
    message(paste("Plot saved to:", output_file))
  }
  
  return(p)
}

#' Create summary statistics for variants
#'
#' @param variant_data Data frame with variant information
#' @param gene_name Gene name to analyze
#' @return Data frame with summary statistics
#' @export
summarize_variants <- function(variant_data, gene_name) {
  gene_variants <- variant_data %>%
    filter(vepSYMBOL == gene_name)
  
  summary_stats <- list(
    total_variants = nrow(gene_variants),
    unique_positions = length(unique(gene_variants$POS)),
    unique_families = length(unique(gene_variants$Family_ID)),
    unique_samples = length(unique(gene_variants$sample)),
    consequence_counts = table(gene_variants$vepConsequence),
    impact_counts = table(gene_variants$vepIMPACT)
  )
  
  return(summary_stats)
}

#' Load and prepare variant data from file
#'
#' @param file_path Path to the variant data file (CSV or TSV)
#' @param sep Separator character (default: "\t")
#' @return Data frame with variant data
#' @export
load_variant_data <- function(file_path, sep = "\t") {
  data <- read.delim(file_path, sep = sep, header = TRUE, stringsAsFactors = FALSE)
  
  # Validate required columns
  required_cols <- c("Family_ID", "CHROM", "POS", "REF", "ALT", "vepSYMBOL", 
                    "vepMAX_AF", "vepIMPACT", "vepConsequence", "sample", "kid_GT")
  
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    warning(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
  }
  
  return(data)
}
