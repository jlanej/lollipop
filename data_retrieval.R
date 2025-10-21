#!/usr/bin/env Rscript

# Data Retrieval Module for Protein Information
# Automatically fetches domain and PTM data from UniProt API
# Uses gene symbols (HUGO nomenclature) to retrieve protein information

# Required libraries
if (!requireNamespace("httr", quietly = TRUE)) {
  message("Installing httr package for API calls...")
  install.packages("httr", repos = "http://cran.r-project.org")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  message("Installing jsonlite package for JSON parsing...")
  install.packages("jsonlite", repos = "http://cran.r-project.org")
}

library(httr)
library(jsonlite)

#' Get UniProt accession from gene symbol
#'
#' @param gene_symbol Gene symbol (e.g., "BRCA1", "TP53")
#' @param organism Organism name (default: "human")
#' @return UniProt accession ID or NULL if not found
#' @export
get_uniprot_accession <- function(gene_symbol, organism = "human") {
  # UniProt API endpoint for gene name search
  base_url <- "https://rest.uniprot.org/uniprotkb/search"
  
  # Construct query
  query <- paste0("gene:", gene_symbol, " AND organism_name:", organism, " AND reviewed:true")
  
  # Make API request
  tryCatch({
    response <- GET(base_url, 
                   query = list(query = query, format = "json", size = 1))
    
    if (status_code(response) != 200) {
      warning(paste("UniProt API request failed for", gene_symbol, "with status:", status_code(response)))
      return(NULL)
    }
    
    content <- content(response, as = "text", encoding = "UTF-8")
    data <- fromJSON(content)
    
    if (length(data$results) > 0) {
      return(data$results$primaryAccession[1])
    } else {
      warning(paste("No UniProt entry found for gene:", gene_symbol))
      return(NULL)
    }
  }, error = function(e) {
    warning(paste("Error fetching UniProt accession for", gene_symbol, ":", e$message))
    return(NULL)
  })
}

#' Get protein information from UniProt
#'
#' @param accession UniProt accession ID
#' @return List with protein information including sequence, length, and features
#' @export
get_protein_info <- function(accession) {
  if (is.null(accession)) {
    return(NULL)
  }
  
  # UniProt API endpoint
  base_url <- paste0("https://rest.uniprot.org/uniprotkb/", accession, ".json")
  
  tryCatch({
    response <- GET(base_url)
    
    if (status_code(response) != 200) {
      warning(paste("Failed to fetch protein info for", accession))
      return(NULL)
    }
    
    content <- content(response, as = "text", encoding = "UTF-8")
    data <- fromJSON(content)
    
    # Extract protein length
    protein_length <- data$sequence$length
    
    # Extract gene name
    gene_name <- NULL
    if (!is.null(data$genes) && length(data$genes) > 0) {
      gene_name <- data$genes[[1]]$geneName$value
    }
    
    return(list(
      accession = accession,
      gene_name = gene_name,
      protein_length = protein_length,
      sequence = data$sequence$value,
      features = data$features
    ))
  }, error = function(e) {
    warning(paste("Error fetching protein info for", accession, ":", e$message))
    return(NULL)
  })
}

#' Extract protein domains from UniProt features
#'
#' @param protein_info Protein information from get_protein_info
#' @param gene_symbol Gene symbol for the output
#' @return Data frame with domain information (gene, domain_name, start, end)
#' @export
extract_domains <- function(protein_info, gene_symbol) {
  if (is.null(protein_info) || is.null(protein_info$features)) {
    return(data.frame(
      gene = character(),
      domain_name = character(),
      start = numeric(),
      end = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  
  features <- protein_info$features
  
  # Ensure features is a data frame or can be treated as one
  if (!is.data.frame(features)) {
    if (length(features) == 0) {
      return(data.frame(
        gene = character(),
        domain_name = character(),
        start = numeric(),
        end = numeric(),
        stringsAsFactors = FALSE
      ))
    }
    # If features is not a data frame, log and return empty
    warning("Features is not a data frame, cannot extract domains")
    return(data.frame(
      gene = character(),
      domain_name = character(),
      start = numeric(),
      end = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Domain types to extract
  domain_types <- c("Domain", "Region", "Repeat", "Zinc finger", "DNA binding")
  
  # Filter for domain features
  domains <- features[features$type %in% domain_types, ]
  
  if (nrow(domains) == 0) {
    return(data.frame(
      gene = character(),
      domain_name = character(),
      start = numeric(),
      end = numeric(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Extract domain information
  num_domains <- nrow(domains)
  
  # Extract domain information with proper handling of list columns
  domain_names <- character(num_domains)
  domain_starts <- numeric(num_domains)
  domain_ends <- numeric(num_domains)
  
  for (i in 1:num_domains) {
    # Get description
    desc <- domains$description[[i]]
    domain_names[i] <- if(is.null(desc)) "Domain" else desc
    
    # Get location
    loc <- domains$location[[i]]
    if (!is.null(loc)) {
      # Handle start position
      if (!is.null(loc$start) && !is.null(loc$start$value)) {
        domain_starts[i] <- loc$start$value
      } else {
        domain_starts[i] <- NA
      }
      
      # Handle end position
      if (!is.null(loc$end) && !is.null(loc$end$value)) {
        domain_ends[i] <- loc$end$value
      } else {
        domain_ends[i] <- NA
      }
    } else {
      domain_starts[i] <- NA
      domain_ends[i] <- NA
    }
  }
  
  domain_df <- data.frame(
    gene = rep(gene_symbol, num_domains),
    domain_name = domain_names,
    start = domain_starts,
    end = domain_ends,
    stringsAsFactors = FALSE
  )
  
  # Remove rows with missing positions
  domain_df <- domain_df[!is.na(domain_df$start) & !is.na(domain_df$end), ]
  
  return(domain_df)
}

#' Extract PTMs from UniProt features
#'
#' @param protein_info Protein information from get_protein_info
#' @param gene_symbol Gene symbol for the output
#' @return Data frame with PTM information (gene, ptm_type, position, description)
#' @export
extract_ptms <- function(protein_info, gene_symbol) {
  if (is.null(protein_info) || is.null(protein_info$features)) {
    return(data.frame(
      gene = character(),
      ptm_type = character(),
      position = numeric(),
      description = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  features <- protein_info$features
  
  # Ensure features is a data frame or can be treated as one
  if (!is.data.frame(features)) {
    if (length(features) == 0) {
      return(data.frame(
        gene = character(),
        ptm_type = character(),
        position = numeric(),
        description = character(),
        stringsAsFactors = FALSE
      ))
    }
    # If features is not a data frame, log and return empty
    warning("Features is not a data frame, cannot extract PTMs")
    return(data.frame(
      gene = character(),
      ptm_type = character(),
      position = numeric(),
      description = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  # PTM types to extract
  ptm_types <- c("Modified residue", "Cross-link", "Glycosylation", 
                 "Lipidation", "Disulfide bond")
  
  # Filter for PTM features
  ptms <- features[features$type %in% ptm_types, ]
  
  if (nrow(ptms) == 0) {
    return(data.frame(
      gene = character(),
      ptm_type = character(),
      position = numeric(),
      description = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Extract PTM information
  num_ptms <- nrow(ptms)
  
  # Extract PTM information with proper handling of list columns
  ptm_types <- character(num_ptms)
  ptm_positions <- numeric(num_ptms)
  ptm_descriptions <- character(num_ptms)
  
  for (i in 1:num_ptms) {
    # Get position - use start position for PTMs
    loc <- ptms$location[[i]]
    position <- NA
    if (!is.null(loc)) {
      if (!is.null(loc$start) && !is.null(loc$start$value)) {
        position <- loc$start$value
      }
    }
    
    # Get PTM type and description
    desc <- ptms$description[[i]]
    description <- if (!is.null(desc)) desc else ""
    
    # Categorize PTM type
    ptm_category <- "Other"
    if (grepl("Phospho", description, ignore.case = TRUE)) {
      ptm_category <- "Phosphorylation"
    } else if (grepl("Acetyl", description, ignore.case = TRUE)) {
      ptm_category <- "Acetylation"
    } else if (grepl("Methyl", description, ignore.case = TRUE)) {
      ptm_category <- "Methylation"
    } else if (grepl("Ubiquitin", description, ignore.case = TRUE)) {
      ptm_category <- "Ubiquitination"
    } else if (grepl("Glyc", description, ignore.case = TRUE)) {
      ptm_category <- "Glycosylation"
    }
    
    ptm_types[i] <- ptm_category
    ptm_positions[i] <- position
    ptm_descriptions[i] <- description
  }
  
  ptm_df <- data.frame(
    gene = rep(gene_symbol, num_ptms),
    ptm_type = ptm_types,
    position = ptm_positions,
    description = ptm_descriptions,
    stringsAsFactors = FALSE
  )
  
  # Remove rows with missing positions
  ptm_df <- ptm_df[!is.na(ptm_df$position), ]
  
  return(ptm_df)
}

#' Get protein length for a gene
#'
#' @param gene_symbol Gene symbol (e.g., "BRCA1", "TP53")
#' @return Protein length in amino acids, or NULL if not found
#' @export
get_protein_length <- function(gene_symbol) {
  accession <- get_uniprot_accession(gene_symbol)
  if (is.null(accession)) {
    return(NULL)
  }
  
  protein_info <- get_protein_info(accession)
  if (is.null(protein_info)) {
    return(NULL)
  }
  
  return(protein_info$protein_length)
}

#' Retrieve all protein data (domains, PTMs, length) for a gene
#'
#' @param gene_symbol Gene symbol (e.g., "BRCA1", "TP53")
#' @param cache_dir Optional directory to cache results (default: NULL, no caching)
#' @return List with domains, ptms, and protein_length
#' @export
retrieve_protein_data <- function(gene_symbol, cache_dir = NULL) {
  # Check cache if provided
  if (!is.null(cache_dir)) {
    if (!dir.exists(cache_dir)) {
      dir.create(cache_dir, recursive = TRUE)
    }
    
    cache_file <- file.path(cache_dir, paste0(gene_symbol, "_protein_data.rds"))
    if (file.exists(cache_file)) {
      message(paste("Loading cached data for", gene_symbol))
      return(readRDS(cache_file))
    }
  }
  
  message(paste("Fetching protein data for", gene_symbol, "from UniProt..."))
  
  # Get UniProt accession
  accession <- get_uniprot_accession(gene_symbol)
  if (is.null(accession)) {
    warning(paste("Could not find UniProt entry for", gene_symbol))
    return(list(
      domains = data.frame(),
      ptms = data.frame(),
      protein_length = NULL
    ))
  }
  
  message(paste("  Found UniProt accession:", accession))
  
  # Get protein information
  protein_info <- get_protein_info(accession)
  if (is.null(protein_info)) {
    warning(paste("Could not fetch protein information for", gene_symbol))
    return(list(
      domains = data.frame(),
      ptms = data.frame(),
      protein_length = NULL
    ))
  }
  
  message(paste("  Protein length:", protein_info$protein_length, "amino acids"))
  
  # Extract domains and PTMs with error handling
  domains <- tryCatch({
    d <- extract_domains(protein_info, gene_symbol)
    message(paste("  Found", nrow(d), "domains"))
    d
  }, error = function(e) {
    warning(paste("Failed to extract domains:", e$message))
    data.frame(
      gene = character(),
      domain_name = character(),
      start = numeric(),
      end = numeric(),
      stringsAsFactors = FALSE
    )
  })
  
  ptms <- tryCatch({
    p <- extract_ptms(protein_info, gene_symbol)
    message(paste("  Found", nrow(p), "PTMs"))
    p
  }, error = function(e) {
    warning(paste("Failed to extract PTMs:", e$message))
    data.frame(
      gene = character(),
      ptm_type = character(),
      position = numeric(),
      description = character(),
      stringsAsFactors = FALSE
    )
  })
  
  result <- list(
    domains = domains,
    ptms = ptms,
    protein_length = protein_info$protein_length
  )
  
  # Save to cache if provided
  if (!is.null(cache_dir)) {
    saveRDS(result, cache_file)
    message(paste("  Cached data to", cache_file))
  }
  
  return(result)
}

# Example usage when script is run directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) {
    cat("Usage: Rscript data_retrieval.R <gene_symbol> [cache_dir]\n")
    cat("\nExample:\n")
    cat("  Rscript data_retrieval.R BRCA1\n")
    cat("  Rscript data_retrieval.R TP53 cache/\n")
    quit(status = 1)
  }
  
  gene_symbol <- args[1]
  cache_dir <- if (length(args) >= 2) args[2] else NULL
  
  # Retrieve data
  result <- retrieve_protein_data(gene_symbol, cache_dir)
  
  # Print results
  cat("\n")
  cat("Protein Data for", gene_symbol, "\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  cat("Protein Length:", result$protein_length, "amino acids\n")
  cat("\nDomains:\n")
  if (nrow(result$domains) > 0) {
    print(result$domains)
  } else {
    cat("  No domains found\n")
  }
  cat("\nPTMs:\n")
  if (nrow(result$ptms) > 0) {
    print(result$ptms)
  } else {
    cat("  No PTMs found\n")
  }
}
