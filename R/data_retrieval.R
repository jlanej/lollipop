# Data Retrieval Module for Protein Information
# Automatically fetches domain and PTM data from UniProt API
# Uses gene symbols (HUGO nomenclature) to retrieve protein information

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
  domain_df <- data.frame(
    gene = gene_symbol,
    domain_name = sapply(domains$description, function(x) if(is.null(x)) "Domain" else x),
    start = sapply(domains$location, function(x) {
      if (!is.null(x$start) && !is.null(x$start$value)) {
        return(x$start$value)
      } else {
        return(NA)
      }
    }),
    end = sapply(domains$location, function(x) {
      if (!is.null(x$end) && !is.null(x$end$value)) {
        return(x$end$value)
      } else {
        return(NA)
      }
    }),
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
  ptm_df <- data.frame(
    gene = gene_symbol,
    ptm_type = character(nrow(ptms)),
    position = numeric(nrow(ptms)),
    description = character(nrow(ptms)),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:nrow(ptms)) {
    ptm <- ptms[i, ]
    
    # Get position - use start position for PTMs
    position <- NA
    if (!is.null(ptm$location) && !is.null(ptm$location$start) && !is.null(ptm$location$start$value)) {
      position <- ptm$location$start$value
    }
    
    # Get PTM type and description
    description <- if (!is.null(ptm$description)) ptm$description else ""
    
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
    
    ptm_df$ptm_type[i] <- ptm_category
    ptm_df$position[i] <- position
    ptm_df$description[i] <- description
  }
  
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
  
  # Extract domains and PTMs
  domains <- extract_domains(protein_info, gene_symbol)
  message(paste("  Found", nrow(domains), "domains"))
  
  ptms <- extract_ptms(protein_info, gene_symbol)
  message(paste("  Found", nrow(ptms), "PTMs"))
  
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
