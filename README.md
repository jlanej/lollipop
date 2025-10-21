# Detailed Lollipop Plots in R

A comprehensive R package for creating detailed lollipop plots to visualize genomic variants with protein domains, Post-Translational Modifications (PTMs), and variant annotations.

## Features

- **Variant Visualization**: Display variants with counts and positions
- **Protein Domains**: Show protein domain architecture
- **PTM Display**: Visualize Post-Translational Modifications
- **Automatic Data Retrieval**: Automatically fetch protein domains and PTMs from UniProt - no manual data collection needed!
- **Color Coding**: Variants colored by VEP consequence
- **Interactive Labels**: Automatic labeling of high-impact variants
- **Flexible Input**: Support for standard VCF-annotated data

## Requirements

The following R packages are required:

```r
# Core plotting packages
install.packages(c("ggplot2", "dplyr", "scales", "ggrepel"))

# For automatic data retrieval (optional but recommended)
install.packages(c("httr", "jsonlite"))
```

## Quick Start

### 1. Generate Example Data

```r
# Generate example data
source("example_data.R")
save_example_data()
```

### 2. Run Complete Example

```bash
Rscript run_example.R
```

This will create:
- `brca1_detailed_lollipop.png` - Full plot with domains and PTMs
- `brca1_simple_lollipop.png` - Simplified variant-only plot
- Example data files (TSV format)

## Usage

### Basic Usage with Auto-Retrieval (NEW!)

The easiest way to create plots - just provide your variant data:

```r
source("detailed_lollipop_plot.R")

# Load your variant data
variant_data <- read.delim("your_variants.tsv", sep="\t", header=TRUE)

# Create plot - protein length, domains, and PTMs are automatically retrieved!
plot <- create_detailed_lollipop_plot(
  variant_data = variant_data,
  gene_name = "BRCA1",
  output_file = "my_lollipop.png"
)
```

No need to manually download domain data or look up protein lengths!

### Advanced Usage with Manual Data

You can still provide your own domain and PTM data if preferred:

```r
# Load protein domain data
domains <- read.delim("protein_domains.tsv", sep="\t", header=TRUE)

# Load PTM data
ptms <- read.delim("ptms.tsv", sep="\t", header=TRUE)

# Create detailed plot with manual data
plot <- create_detailed_lollipop_plot(
  variant_data = variant_data,
  protein_domains = domains,
  ptms = ptms,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "detailed_lollipop.png",
  width = 16,
  height = 10
)
```

### Command Line Usage

```bash
Rscript detailed_lollipop_plot.R <variant_file> <gene_name> [protein_length] [output_file]
```

Examples:
```bash
# With auto-retrieval (recommended)
Rscript detailed_lollipop_plot.R variants.tsv BRCA1 brca1_plot.png

# With manual protein length
Rscript detailed_lollipop_plot.R variants.tsv BRCA1 1863 brca1_plot.png
```

## Input Data Format

### Variant Data (Required)

Tab-separated file with the following columns:

| Column | Description |
|--------|-------------|
| Family_ID | Family identifier |
| CHROM | Chromosome |
| POS | Position (amino acid or genomic) |
| REF | Reference allele |
| ALT | Alternate allele |
| vepSYMBOL | Gene symbol |
| vepMAX_AF | Maximum allele frequency |
| vepIMPACT | VEP impact (HIGH/MODERATE/LOW/MODIFIER) |
| vepConsequence | VEP consequence annotation |
| sample | Sample identifier |
| kid_GT | Genotype (0/0, 0/1, 1/1) |

### Protein Domain Data (Optional)

Tab-separated file with columns:

| Column | Description |
|--------|-------------|
| gene | Gene symbol |
| domain_name | Name of the domain |
| start | Start position (amino acids) |
| end | End position (amino acids) |

### PTM Data (Optional)

Tab-separated file with columns:

| Column | Description |
|--------|-------------|
| gene | Gene symbol |
| ptm_type | Type (Phosphorylation, Acetylation, etc.) |
| position | Position (amino acids) |
| description | Description of the PTM |

## Supported VEP Consequences

The plot automatically color-codes variants based on their VEP consequence:

- **High Impact (Red)**: frameshift_variant, stop_gained, stop_lost, start_lost, splice variants
- **Moderate Impact (Orange)**: missense_variant, inframe deletions/insertions
- **Low Impact (Green)**: synonymous_variant
- **Modifier (Light Blue)**: intron_variant, UTR variants

## Features in Detail

### Variant Counting
- Automatically aggregates variants at the same position
- Shows count with point size
- Labels high-impact and high-count variants

### Domain Visualization
- Shows protein domains as colored rectangles
- Labels each domain
- Positioned below the protein backbone

### PTM Display
- Shows PTMs as distinct shapes based on type:
  - ▲ Phosphorylation
  - ◆ Acetylation
  - ▼ Methylation
  - ◀ Ubiquitination
  - ● Glycosylation

### Summary Statistics
Use the `summarize_variants()` function to get statistics:

```r
summary <- summarize_variants(variant_data, "BRCA1")
print(summary)
```

## Examples

See the `run_example.R` script for a complete working example with all features demonstrated.

## Customization

The plot can be customized by modifying the following parameters:

- `width`, `height`: Output dimensions in inches
- Color schemes in `consequence_colors` (in the source code)
- Point sizes via `scale_size_continuous(range = c(3, 10))`
- Label thresholds in the high-impact variant filtering

## Tips

1. **Position Mapping**: If your POS column contains genomic positions, you may need to convert them to amino acid positions before plotting.

2. **Large Datasets**: For genes with many variants, consider filtering to:
   - Variants with kid_GT != "0/0" (variants present in the kid)
   - High/moderate impact variants only
   - Variants below a certain allele frequency threshold

3. **Multiple Genes**: Create separate plots for each gene of interest.

4. **Domain and PTM Data**: Now automatically retrieved from UniProt! Alternatively, you can manually obtain domain and PTM information from:
   - UniProt (https://www.uniprot.org/)
   - Pfam (http://pfam.xfam.org/)
   - InterPro (https://www.ebi.ac.uk/interpro/)
   - PhosphoSitePlus (https://www.phosphosite.org/)

## Troubleshooting

**Missing packages**: Install required packages with:
```r
install.packages(c("ggplot2", "dplyr", "scales", "ggrepel"))
```

**No variants displayed**: Check that:
- Gene name matches vepSYMBOL exactly
- Position values are numeric and within protein_length range
- kid_GT is not all "0/0"

**Overlapping labels**: Adjust `max.overlaps` parameter in `geom_text_repel()` or filter to fewer high-impact variants.

## Citation

If you use this tool in your research, please cite the repository:

```
Detailed Lollipop Plots for Genomic Variants
https://github.com/jlanej/lollipop
```

## License

This project is open source and available for academic and research use.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
