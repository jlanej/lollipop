#!/usr/bin/env Rscript

# Installation script for required R packages
# Run this before using the lollipop plot scripts

cat("Installing required R packages for detailed lollipop plots...\n\n")

# List of required packages
required_packages <- c("ggplot2", "dplyr", "scales", "ggrepel")

# Function to install and load packages
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat("Installing package:", package, "\n")
    install.packages(package, repos = "http://cran.r-project.org", quiet = TRUE)
    
    if (require(package, character.only = TRUE, quietly = TRUE)) {
      cat("  Successfully installed:", package, "\n")
      return(TRUE)
    } else {
      cat("  ERROR: Failed to install:", package, "\n")
      return(FALSE)
    }
  } else {
    cat("Package already installed:", package, "\n")
    return(TRUE)
  }
}

# Install all required packages
success <- sapply(required_packages, install_if_missing)

# Summary
cat("\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
if (all(success)) {
  cat("All required packages installed successfully!\n")
  cat("You can now use the detailed lollipop plot scripts.\n")
} else {
  cat("Some packages failed to install.\n")
  cat("Failed packages:", paste(required_packages[!success], collapse = ", "), "\n")
  cat("Please install them manually using:\n")
  cat("  install.packages(c(", paste(paste0('"', required_packages[!success], '"'), collapse = ", "), "))\n")
}
cat(paste(rep("=", 60), collapse = ""), "\n")
