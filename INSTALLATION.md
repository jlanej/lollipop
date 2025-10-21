# Package Installation Guide

## Overview

The `lollipop` repository has been converted into a proper R package that can be installed directly from GitHub using `devtools::install_github()`.

## Installation

To install the package, run the following commands in R:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install lollipop package from GitHub
devtools::install_github("jlanej/lollipop")
```

## What Changed

### Package Structure

The repository now includes the following R package files:

- **DESCRIPTION**: Contains package metadata, dependencies, and version information
- **NAMESPACE**: Defines exported functions and imports from other packages
- **LICENSE**: MIT license for the package
- **.Rbuildignore**: Specifies files to exclude from the package build
- **R/**: Directory containing the package source code
  - `data_retrieval.R`: Functions for retrieving protein data from UniProt
  - `detailed_lollipop_plot.R`: Functions for creating lollipop plots

### Exported Functions

The package exports the following functions:

1. **create_detailed_lollipop_plot()**: Main function to create detailed lollipop plots
2. **summarize_variants()**: Generate summary statistics for variants
3. **load_variant_data()**: Load and validate variant data from files
4. **get_uniprot_accession()**: Get UniProt accession from gene symbol
5. **get_protein_info()**: Get protein information from UniProt
6. **extract_domains()**: Extract protein domains from UniProt data
7. **extract_ptms()**: Extract PTMs from UniProt data
8. **get_protein_length()**: Get protein length for a gene
9. **retrieve_protein_data()**: Retrieve all protein data (domains, PTMs, length)

### Dependencies

The package automatically installs the following dependencies when you install it:

- ggplot2: For creating plots
- dplyr: For data manipulation
- scales: For plot scaling
- ggrepel: For label positioning
- httr: For making HTTP requests to UniProt API
- jsonlite: For parsing JSON responses

## Using the Package

### Basic Example

```r
# Load the package
library(lollipop)

# Load your variant data
variant_data <- read.delim("your_variants.tsv", sep="\t", header=TRUE)

# Create a plot with automatic data retrieval
plot <- create_detailed_lollipop_plot(
  variant_data = variant_data,
  gene_name = "BRCA1",
  output_file = "brca1_lollipop.png"
)
```

### Advanced Example

```r
library(lollipop)

# Load data
variant_data <- load_variant_data("variants.tsv")

# Create plot with custom settings
plot <- create_detailed_lollipop_plot(
  variant_data = variant_data,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_detailed.png",
  width = 16,
  height = 10,
  auto_retrieve = TRUE,
  cache_dir = ".lollipop_cache"
)

# Get summary statistics
summary <- summarize_variants(variant_data, "BRCA1")
print(summary)
```

## Standalone Scripts

The repository still includes standalone scripts in the root directory for those who prefer command-line usage:

- `detailed_lollipop_plot.R`: Command-line script for creating plots
- `data_retrieval.R`: Command-line script for data retrieval
- `run_example.R`: Complete example script
- `auto_retrieval_example.R`: Example of automatic data retrieval
- `advanced_example.R`: Advanced usage examples
- `batch_process.R`: Batch processing script

These scripts are excluded from the package build but remain available in the repository.

## For Developers

### Package Development

If you want to modify the package:

1. Clone the repository
2. Make changes to files in the `R/` directory
3. Update documentation in roxygen2 format (comments starting with `#'`)
4. Rebuild the package documentation with `devtools::document()`
5. Test the package with `devtools::check()`

### Building Locally

To build and install the package locally:

```r
# Navigate to the package directory
setwd("/path/to/lollipop")

# Build and install
devtools::install()
```

## Troubleshooting

### Installation Issues

If you encounter issues during installation:

```r
# Try installing with dependencies explicitly
devtools::install_github("jlanej/lollipop", dependencies = TRUE)

# Or install dependencies manually first
install.packages(c("ggplot2", "dplyr", "scales", "ggrepel", "httr", "jsonlite"))
devtools::install_github("jlanej/lollipop")
```

### Loading Issues

If the package fails to load:

```r
# Check if it's installed
"lollipop" %in% installed.packages()[, "Package"]

# Reinstall if necessary
remove.packages("lollipop")
devtools::install_github("jlanej/lollipop")
```

## Version History

- **0.1.0** (Initial Release): Converted repository to R package format with devtools::install_github() support
