# Changelog

## Version 2.0 - Automatic Data Retrieval

### Major Features

#### Automatic Protein Data Retrieval
- **NEW**: Automatically fetch protein domains from UniProt API
- **NEW**: Automatically fetch PTMs (Post-Translational Modifications) from UniProt
- **NEW**: Automatically retrieve protein lengths
- No more manual data collection required!

### Changes

#### Function Signatures

**`create_detailed_lollipop_plot()`**
- `protein_length` parameter is now optional (was required)
- New parameter: `auto_retrieve` (default: TRUE) - enables automatic data fetching
- New parameter: `cache_dir` (default: ".lollipop_cache") - location for caching retrieved data
- When `auto_retrieve=TRUE` and domain/PTM data is not provided, it's automatically fetched

**`batch_process_genes()`**
- Gene config file no longer requires `protein_length` column (optional)
- New parameter: `auto_retrieve` (default: TRUE)
- New parameter: `cache_dir` (default: ".lollipop_cache")
- Domain and PTM files are now optional

#### New Files

- `data_retrieval.R` - Core data retrieval functionality
  - `get_uniprot_accession()` - Convert gene symbol to UniProt ID
  - `get_protein_info()` - Fetch protein data from UniProt
  - `extract_domains()` - Parse domain information
  - `extract_ptms()` - Parse PTM information
  - `get_protein_length()` - Get protein length for a gene
  - `retrieve_protein_data()` - Main function to retrieve all data

- `test_auto_retrieval.R` - Test script for auto-retrieval
- `auto_retrieval_example.R` - Complete example demonstrating auto-retrieval
- `example_genes_simple.tsv` - Simple gene list without protein lengths
- `AUTO_RETRIEVAL.md` - Comprehensive documentation for auto-retrieval feature

#### Modified Files

- `detailed_lollipop_plot.R`
  - Sources `data_retrieval.R`
  - Updated to support optional protein_length
  - Auto-retrieves missing data when enabled
  - Updated command-line interface

- `batch_process.R`
  - Sources `data_retrieval.R`
  - Updated to support optional protein_length in gene config
  - Auto-retrieves data for each gene when enabled

- `install_packages.R`
  - Added installation of `httr` package
  - Added installation of `jsonlite` package
  - Better installation feedback

#### Documentation Updates

- `README.md` - Added auto-retrieval examples, updated requirements
- `QUICKSTART.md` - Simplified usage instructions with auto-retrieval
- `USAGE.md` - Added auto-retrieval options and examples
- `AUTO_RETRIEVAL.md` - New comprehensive guide for auto-retrieval feature

#### Configuration Updates

- `.gitignore` - Added cache directories to ignore list

### New Requirements

**Optional but Recommended Packages:**
- `httr` - For making HTTP requests to UniProt API
- `jsonlite` - For parsing JSON responses from UniProt

These packages are automatically installed when using `install_packages.R`.

### Data Caching

Retrieved protein data is cached locally to improve performance:
- Default location: `.lollipop_cache/`
- Format: RDS files (one per gene)
- Benefits: Faster subsequent runs, offline usage after initial fetch

### Backward Compatibility

All existing functionality is preserved:
- Can still provide manual domain/PTM data
- Can still specify protein_length explicitly
- Old scripts continue to work without modification
- Set `auto_retrieve=FALSE` to disable new behavior

### Migration Guide

#### Before (Manual Data Collection)

```r
# Had to manually:
# 1. Look up protein length
# 2. Download domains from UniProt
# 3. Download PTMs from PhosphoSitePlus
# 4. Format as TSV files

domains <- read.delim("brca1_domains.tsv")
ptms <- read.delim("brca1_ptms.tsv")

plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1.png"
)
```

#### After (Automatic Retrieval)

```r
# Just provide gene name!
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  output_file = "brca1.png"
)
```

### Performance Notes

- First run for a gene: ~2-5 seconds (fetching from UniProt)
- Subsequent runs: ~0.1 seconds (using cached data)
- Batch processing benefits from caching

### Known Limitations

1. Requires internet connection for initial data retrieval
2. Limited to genes available in UniProt (covers most human genes)
3. Gene symbols must match HUGO nomenclature
4. PTM categorization may not capture all modification types

### Future Enhancements

Potential future improvements:
- Support for additional PTM databases (PhosphoSitePlus API)
- Support for species other than human
- Enhanced domain classification
- Alternative protein isoforms support
- Batch pre-caching utility

## Version 1.0 - Initial Release

- Basic lollipop plot functionality
- Manual domain and PTM data input
- VEP consequence color coding
- High-impact variant labeling
- Batch processing support
- Example data generation
