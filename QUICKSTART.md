# Quick Start Guide

Get up and running with detailed lollipop plots in 5 minutes!

## Prerequisites

Install R from [https://www.r-project.org/](https://www.r-project.org/)

## Installation (1 minute)

```bash
# Clone the repository
git clone https://github.com/jlanej/lollipop.git
cd lollipop

# Install required R packages
Rscript install_packages.R
```

## Run Example (2 minutes)

```bash
# Generate example plots
Rscript run_example.R
```

This creates:
- `brca1_detailed_lollipop.png` - Full featured plot
- `brca1_simple_lollipop.png` - Basic plot
- Example data files

## Use Your Data (2 minutes)

### Prepare your data file

Create a tab-separated file `my_variants.tsv` with these columns:

```
Family_ID    CHROM    POS    REF    ALT    vepSYMBOL    vepMAX_AF    vepIMPACT    vepConsequence    sample    kid_GT
```

### Create your plot

```bash
Rscript detailed_lollipop_plot.R my_variants.tsv GENE_NAME PROTEIN_LENGTH output.png
```

Example:
```bash
Rscript detailed_lollipop_plot.R variants.tsv TP53 393 tp53_plot.png
```

## Common Gene Lengths

For reference:

| Gene | Protein Length (aa) |
|------|---------------------|
| BRCA1 | 1863 |
| BRCA2 | 3418 |
| TP53 | 393 |
| PTEN | 403 |
| APC | 2843 |
| MLH1 | 756 |
| MSH2 | 934 |
| PALB2 | 1186 |
| ATM | 3056 |
| CHEK2 | 543 |

Find protein lengths at [UniProt](https://www.uniprot.org/)

## Next Steps

- See [USAGE.md](USAGE.md) for detailed instructions
- See [VISUALIZATION_GUIDE.md](VISUALIZATION_GUIDE.md) for customization
- See [advanced_example.R](advanced_example.R) for filtering examples

## Need Help?

1. Check the [README.md](README.md) for detailed documentation
2. Run the examples to see how it works
3. Check the FAQ section below

## FAQ

**Q: What if R is not installed?**  
A: Download and install R from https://www.r-project.org/

**Q: Package installation fails?**  
A: Try installing packages manually in R console:
```r
install.packages(c("ggplot2", "dplyr", "scales", "ggrepel"))
```

**Q: My plot is empty?**  
A: Check that:
- Gene name matches `vepSYMBOL` exactly (case-sensitive)
- POS values are within 1 to protein_length
- kid_GT is not all "0/0"

**Q: How do I convert genomic positions to protein positions?**  
A: Use VEP annotation which includes protein positions, or calculate:
```r
# Simplified (actual conversion needs exon boundaries)
aa_position <- ceiling((genomic_pos - gene_start) / 3)
```

**Q: Where do I get protein domain data?**  
A: Download from:
- UniProt: https://www.uniprot.org/
- Pfam: http://pfam.xfam.org/
- InterPro: https://www.ebi.ac.uk/interpro/

**Q: Can I plot multiple genes?**  
A: Yes! Create one plot per gene:
```r
genes <- c("BRCA1", "BRCA2", "TP53")
for (gene in genes) {
  # Create plot for each gene
}
```

**Q: How do I customize colors?**  
A: Edit the `consequence_colors` vector in `detailed_lollipop_plot.R`

**Q: Can I export to PDF?**  
A: Yes! Change the output file extension:
```r
output_file = "my_plot.pdf"
```

**Q: Plot takes too long to generate?**  
A: Filter your data first:
```r
filtered_variants <- variants %>%
  filter(vepIMPACT %in% c("HIGH", "MODERATE")) %>%
  filter(vepMAX_AF < 0.01)
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Package not found | Run `install_packages.R` |
| Empty plot | Check gene name and positions |
| Labels overlap | Increase plot size or filter variants |
| Colors not showing | Verify vepConsequence values |
| File not found | Use absolute paths or check working directory |

## Key Files

- `detailed_lollipop_plot.R` - Main plotting function
- `example_data.R` - Example data generator
- `run_example.R` - Complete example workflow
- `advanced_example.R` - Advanced filtering examples
- `install_packages.R` - Package installer

## Support

For issues or questions, please check the documentation or create an issue on GitHub.
