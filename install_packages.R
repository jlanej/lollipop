#!/usr/bin/env Rscript

# Installation script for required R packages
# Run this before using the lollipop plot scripts

cat("Installing required R packages for detailed lollipop plots...\n\n")

# List of required packages
# Core plotting packages
required_packages <- c("ggplot2", "dplyr", "scales", "ggrepel")

# Packages for automatic data retrieval (optional but recommended)
optional_packages <- c("httr", "jsonlite")

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
cat("Installing core packages...\n")
success <- sapply(required_packages, install_if_missing)

# Install optional packages for auto-retrieval
cat("\nInstalling optional packages for automatic data retrieval...\n")
optional_success <- sapply(optional_packages, install_if_missing)

# Summary
cat("\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
if (all(success)) {
  cat("✓ All core packages installed successfully!\n")
} else {
  cat("✗ Some core packages failed to install.\n")
  cat("  Failed packages:", paste(required_packages[!success], collapse = ", "), "\n")
}

cat("\n")
if (all(optional_success)) {
  cat("✓ All optional packages installed successfully!\n")
  cat("  Automatic data retrieval is fully enabled.\n")
} else {
  cat("⚠ Some optional packages failed to install.\n")
  cat("  Failed packages:", paste(optional_packages[!optional_success], collapse = ", "), "\n")
  cat("  You can still use the tool, but automatic data retrieval won't work.\n")
  cat("  You'll need to provide domain and PTM data manually.\n")
}

cat("\n")
if (all(success)) {
  cat("You can now use the detailed lollipop plot scripts.\n")
  if (all(optional_success)) {
    cat("Try the auto-retrieval example: Rscript auto_retrieval_example.R\n")
  }
} else {
  cat("Please install missing core packages manually using:\n")
  cat("  install.packages(c(", paste(paste0('"', required_packages[!success], '"'), collapse = ", "), "))\n")
}
cat(paste(rep("=", 60), collapse = ""), "\n")
