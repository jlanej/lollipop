# Usage Guide for Detailed Lollipop Plots

## Installation

First, ensure R is installed on your system. Then install the required packages:

```r
# Install required packages
install.packages(c("ggplot2", "dplyr", "scales", "ggrepel"))
```

## Step-by-Step Tutorial

### Step 1: Prepare Your Data

Your variant data should be in a tab-separated format with these columns:

```
Family_ID    CHROM    POS    REF    ALT    vepSYMBOL    vepMAX_AF    vepIMPACT    vepConsequence    sample    kid_GT
FAM001       chr17    100    A      G      BRCA1        0.0001       HIGH         missense_variant  S001      0/1
FAM002       chr17    450    C      T      BRCA1        0.0005       MODERATE     synonymous_variant S002     1/1
```

### Step 2: Run the Example

To see how it works with sample data:

```bash
# Generate example data and create plots
Rscript run_example.R
```

This will produce:
- `brca1_detailed_lollipop.png` - Complete plot with all features
- `brca1_simple_lollipop.png` - Basic variant plot
- `example_variants.tsv` - Sample variant data
- `example_domains.tsv` - Sample domain data
- `example_ptms.tsv` - Sample PTM data

### Step 3: Use Your Own Data

#### Option A: Command Line (Simple)

```bash
Rscript detailed_lollipop_plot.R your_variants.tsv GENE_NAME PROTEIN_LENGTH output.png
```

Example:
```bash
Rscript detailed_lollipop_plot.R my_variants.tsv TP53 393 tp53_plot.png
```

#### Option B: R Script (Advanced)

Create a custom R script:

```r
# Load the functions
source("detailed_lollipop_plot.R")

# Load required libraries
library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# Load your data
variants <- read.delim("my_variants.tsv", sep="\t", header=TRUE)

# Optional: Load domain and PTM data
domains <- read.delim("my_domains.tsv", sep="\t", header=TRUE)
ptms <- read.delim("my_ptms.tsv", sep="\t", header=TRUE)

# Create the plot
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  protein_domains = domains,  # Optional
  ptms = ptms,                # Optional
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "my_plot.png",
  width = 16,
  height = 10
)

# Get summary statistics
summary <- summarize_variants(variants, "BRCA1")
print(summary)
```

### Step 4: Customize the Plot

You can customize various aspects:

```r
# Larger plot for presentations
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "large_plot.png",
  width = 20,    # Wider
  height = 12    # Taller
)

# Filter variants before plotting
high_impact_variants <- variants %>%
  filter(vepIMPACT %in% c("HIGH", "MODERATE")) %>%
  filter(kid_GT != "0/0")

plot <- create_detailed_lollipop_plot(
  variant_data = high_impact_variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "high_impact_only.png"
)
```

## Common Workflows

### Workflow 1: Single Gene Analysis

```r
source("detailed_lollipop_plot.R")
library(dplyr)

# Load data
variants <- read.delim("variants.tsv", sep="\t")

# Filter to variants present in kid
kid_variants <- variants %>% filter(kid_GT != "0/0")

# Create plot
create_detailed_lollipop_plot(
  variant_data = kid_variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "brca1_kid_variants.png"
)
```

### Workflow 2: Multiple Genes

```r
source("detailed_lollipop_plot.R")

# List of genes to plot
genes <- list(
  list(name = "BRCA1", length = 1863),
  list(name = "TP53", length = 393),
  list(name = "BRCA2", length = 3418)
)

# Load data once
variants <- read.delim("variants.tsv", sep="\t")

# Create plot for each gene
for (gene_info in genes) {
  output_file <- paste0(gene_info$name, "_lollipop.png")
  
  create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = gene_info$name,
    protein_length = gene_info$length,
    output_file = output_file
  )
}
```

### Workflow 3: Family-Specific Analysis

```r
source("detailed_lollipop_plot.R")
library(dplyr)

# Load data
variants <- read.delim("variants.tsv", sep="\t")

# Get unique families
families <- unique(variants$Family_ID)

# Create plot for each family
for (fam in families) {
  fam_variants <- variants %>% filter(Family_ID == fam)
  
  output_file <- paste0(fam, "_variants.png")
  
  create_detailed_lollipop_plot(
    variant_data = fam_variants,
    gene_name = "BRCA1",
    protein_length = 1863,
    output_file = output_file
  )
}
```

## Data Sources

### Getting Protein Domain Information

1. **UniProt** (https://www.uniprot.org/)
   - Search for your gene
   - Download features in TSV format
   - Extract domain information

2. **Pfam** (http://pfam.xfam.org/)
   - Search for protein domains
   - Export domain coordinates

Example domain file format:
```
gene    domain_name    start    end
BRCA1   RING domain    1        100
BRCA1   BRCT domain    1650     1855
```

### Getting PTM Information

1. **PhosphoSitePlus** (https://www.phosphosite.org/)
   - Download PTM data for your protein
   - Format as TSV

2. **UniProt PTM annotations**
   - Available in the feature table

Example PTM file format:
```
gene    ptm_type           position    description
BRCA1   Phosphorylation    150         DNA damage response
BRCA1   Acetylation        654         Chromatin remodeling
```

### Converting Genomic to Protein Positions

If your POS column contains genomic coordinates, you'll need to convert to amino acid positions:

```r
# Example conversion (adjust for your gene structure)
# This is simplified - actual conversion needs exon boundaries
variants$aa_pos <- ceiling((variants$POS - gene_start) / 3)

# Or use a tool like:
# - Ensembl VEP (includes protein position in output)
# - ANNOVAR (can annotate with protein positions)
```

## Understanding the Output

### Plot Components

1. **Protein Backbone**: Gray horizontal line representing the full protein
2. **Domains**: Blue rectangles showing functional domains
3. **PTMs**: Shaped markers (triangles, diamonds, etc.) below domains
4. **Lollipop Stems**: Gray vertical lines from backbone to variant
5. **Lollipop Heads**: Colored circles showing variant locations
6. **Labels**: Annotations for high-impact variants

### Color Scheme

- **Red**: High impact (frameshift, stop gained/lost, splice sites)
- **Orange**: Moderate impact (missense, inframe indels)
- **Green**: Low impact (synonymous)
- **Light Blue**: Modifier (intronic, UTR)

### Point Size

Point size represents the number of variants at that position. Larger points indicate multiple variants or multiple samples with the same variant.

## Tips and Best Practices

1. **Filter your data**: Focus on variants where kid_GT != "0/0" to show only variants present in the kid

2. **Check position ranges**: Ensure POS values are within 1 to protein_length

3. **Gene name matching**: Ensure gene names match exactly (case-sensitive)

4. **Large datasets**: If you have many variants, consider:
   - Filtering by impact (HIGH/MODERATE only)
   - Filtering by allele frequency (rare variants only)
   - Splitting into multiple plots by region

5. **Publication quality**: Use larger dimensions for publication:
   ```r
   width = 20, height = 12  # inches at 300 DPI
   ```

## Troubleshooting

### Problem: Plot is empty

**Solution**: Check that:
```r
# Verify gene name exists
unique(variants$vepSYMBOL)

# Verify positions are numeric
class(variants$POS)

# Check kid_GT values
table(variants$kid_GT)
```

### Problem: Labels overlap

**Solution**: Adjust filtering in the script or increase plot size

### Problem: Domains not showing

**Solution**: Verify domain data format and gene names match exactly

### Problem: Colors not showing correctly

**Solution**: Check vepConsequence values match the defined color scheme

## Example Output Description

When you run `run_example.R`, you'll see:

1. **Console output** showing:
   - Number of variants loaded
   - Summary statistics
   - File locations

2. **Plot files** showing:
   - Detailed view with all features
   - Simplified view with just variants

3. **Data files** that you can use as templates for your own data

## Next Steps

1. Run the example to see how it works
2. Prepare your data in the correct format
3. Modify the example scripts for your specific needs
4. Create plots for your genes of interest
5. Customize colors, sizes, and labels as needed

For more information, see the main README.md file.
