# Automatic Data Retrieval

This document describes the automatic data retrieval feature that fetches protein information from UniProt.

## Overview

Previously, creating lollipop plots required:
1. Manually looking up protein lengths
2. Downloading and formatting domain data from UniProt/Pfam
3. Downloading and formatting PTM data from PhosphoSitePlus

**Now, all of this is automated!** Simply provide your variant data and gene symbol (vepSYMBOL), and the tool will automatically fetch:
- Protein length
- Protein domains
- Post-Translational Modifications (PTMs)

## How It Works

The auto-retrieval feature uses the UniProt REST API to fetch protein information:

1. **Gene Symbol → UniProt Accession**: Converts your gene symbol (e.g., "BRCA1") to a UniProt accession ID
2. **Fetch Protein Data**: Retrieves complete protein information including sequence, features, and annotations
3. **Extract Domains**: Parses domain information (RING domains, BRCT domains, etc.)
4. **Extract PTMs**: Parses post-translational modifications (phosphorylation, acetylation, etc.)
5. **Cache Results**: Saves data locally to speed up future runs

## Usage

### Basic Usage

```r
source("detailed_lollipop_plot.R")

# Load your variant data
variants <- read.delim("variants.tsv", sep="\t")

# Create plot with auto-retrieval
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",  # Only gene name needed!
  output_file = "brca1_plot.png"
)
```

### Command Line

```bash
# Just gene name and variant file
Rscript detailed_lollipop_plot.R variants.tsv BRCA1 output.png
```

### Batch Processing

```bash
# Create a simple gene list (just gene names, no protein lengths needed)
echo -e "gene_name\nBRCA1\nTP53\nPTEN" > genes.tsv

# Process all genes with auto-retrieval
Rscript batch_process.R variants.tsv genes.tsv
```

## Caching

To improve performance, retrieved data is cached locally:

- **Default cache location**: `.lollipop_cache/` in the current directory
- **Cache files**: `GENE_protein_data.rds` for each gene
- **Reuse**: Subsequent runs use cached data instead of making new API calls

### Custom Cache Location

```r
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  cache_dir = "/path/to/my/cache"
)
```

### Clearing Cache

```bash
rm -rf .lollipop_cache/
```

## Disabling Auto-Retrieval

If you want to provide your own data:

```r
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  protein_domains = my_domains,
  ptms = my_ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  auto_retrieve = FALSE  # Disable auto-retrieval
)
```

## Requirements

Auto-retrieval requires two additional R packages:

```r
install.packages(c("httr", "jsonlite"))
```

These are automatically installed if missing when you first use the feature.

## Data Sources

### UniProt REST API

- **URL**: https://rest.uniprot.org/
- **Coverage**: All reviewed human proteins
- **Update Frequency**: Updated regularly by UniProt curators

### What's Retrieved

#### Protein Domains
- Domain types: Domain, Region, Repeat, Zinc finger, DNA binding
- Includes: Domain name, start position, end position

#### PTMs (Post-Translational Modifications)
- PTM types: Phosphorylation, Acetylation, Methylation, Ubiquitination, Glycosylation
- Includes: PTM type, position, description

#### Protein Length
- Total amino acid length of the canonical isoform

## Troubleshooting

### No data retrieved for gene

**Problem**: Warning "No UniProt entry found for gene: GENE_NAME"

**Solutions**:
1. Check gene symbol spelling (case-sensitive)
2. Ensure it's a human gene
3. Use official HUGO gene symbol
4. Try manually providing protein length

### API connection failed

**Problem**: Warning "UniProt API request failed"

**Solutions**:
1. Check internet connection
2. Verify firewall allows HTTPS to rest.uniprot.org
3. Try again later (temporary API issue)
4. Use manual data as fallback

### Slow performance

**Problem**: First run is slow for each gene

**Solutions**:
1. This is normal - data is being downloaded
2. Subsequent runs use cached data and are fast
3. Pre-download data for multiple genes using `test_auto_retrieval.R`

## Examples

### Example 1: Single Gene

```r
source("detailed_lollipop_plot.R")

variants <- read.delim("variants.tsv", sep="\t")

# Auto-retrieval for TP53
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "TP53",
  output_file = "tp53.png"
)
```

### Example 2: Multiple Genes

```r
source("detailed_lollipop_plot.R")

variants <- read.delim("variants.tsv", sep="\t")
genes <- c("BRCA1", "BRCA2", "TP53", "PTEN")

for (gene in genes) {
  plot <- create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = gene,
    output_file = paste0(gene, "_plot.png")
  )
}
```

### Example 3: Testing Auto-Retrieval

```bash
# Test the feature
Rscript test_auto_retrieval.R

# Run the complete example
Rscript auto_retrieval_example.R
```

## API Rate Limits

UniProt's REST API has rate limits:
- Reasonable use is allowed
- Batch processing of many genes should include delays
- Caching prevents repeated requests for the same gene

## Offline Usage

To use the tool offline:
1. Run with internet first to cache data
2. Keep `.lollipop_cache/` directory
3. Future runs work offline using cached data
4. Or provide manual domain/PTM data

## Comparison: Before vs After

### Before (Manual)

```r
# 1. Look up protein length on UniProt website
# 2. Download domain data
# 3. Format domain TSV file
# 4. Download PTM data
# 5. Format PTM TSV file
# 6. Create plot

domains <- read.delim("manually_created_domains.tsv")
ptms <- read.delim("manually_created_ptms.tsv")

plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1.png"
)
```

### After (Automatic)

```r
# Just create the plot!
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  output_file = "brca1.png"
)
```

## Benefits

✓ **Time Saving**: No manual data collection  
✓ **Accuracy**: Direct from curated UniProt database  
✓ **Up-to-Date**: Always uses latest protein annotations  
✓ **Consistency**: Same data source for all genes  
✓ **Easy Batch Processing**: Process many genes effortlessly  
✓ **Reproducibility**: Cached data ensures consistent results  

## See Also

- [README.md](README.md) - Main documentation
- [USAGE.md](USAGE.md) - Detailed usage guide
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- `data_retrieval.R` - Source code for retrieval functions
- `auto_retrieval_example.R` - Complete working example
