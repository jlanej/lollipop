# Frequently Asked Questions (FAQ)

## General Questions

### Q: What is a lollipop plot?

A: A lollipop plot is a visualization that shows variants along a protein sequence. It consists of:
- A horizontal line representing the protein
- Vertical lines (stems) from the protein to variant positions
- Circles (heads) at the top showing variant counts
- Additional features like protein domains and PTMs

### Q: What data do I need?

A: You need a variant file with these required columns:
- `Family_ID`: Family identifier
- `CHROM`: Chromosome
- `POS`: Position (amino acid or genomic)
- `REF`: Reference allele
- `ALT`: Alternate allele
- `vepSYMBOL`: Gene symbol
- `vepMAX_AF`: Maximum allele frequency
- `vepIMPACT`: Impact level (HIGH/MODERATE/LOW/MODIFIER)
- `vepConsequence`: Consequence type
- `sample`: Sample identifier
- `kid_GT`: Genotype (0/0, 0/1, 1/1)

Optional: Protein domain and PTM data files

### Q: Can I use this with VCF files?

A: Yes, but you need to annotate your VCF with VEP first and convert to TSV format:
```bash
# Annotate with VEP
vep -i input.vcf -o output.vcf --everything

# Convert to TSV
# Extract needed columns and convert to tab-separated format
```

## Installation and Setup

### Q: Which R version is required?

A: R version 3.6 or higher is recommended. The package has been tested with R 4.0+.

### Q: Package installation fails. What should I do?

A: Try these steps:
1. Update R to the latest version
2. Install packages individually:
```r
install.packages("ggplot2")
install.packages("dplyr")
install.packages("scales")
install.packages("ggrepel")
```
3. If behind a firewall, specify a different mirror:
```r
install.packages("ggplot2", repos = "https://cloud.r-project.org/")
```

### Q: Can I use this on Windows?

A: Yes! Install R for Windows and run the scripts in RStudio or R console.

### Q: Can I use this on Mac?

A: Yes! Install R for macOS and run the scripts in Terminal or RStudio.

### Q: Do I need RStudio?

A: No, RStudio is not required. You can run the scripts from command line using `Rscript`.

## Data Preparation

### Q: How do I convert genomic positions to protein positions?

A: Use VEP annotation which includes protein positions. Alternatively:
```r
# If you have CDS coordinates
# Position in CDS / 3 = amino acid position
aa_pos <- ceiling(cds_position / 3)
```

For accurate conversion, you need exon boundaries and strand information.

### Q: What if my positions are in hg19 and I need hg38?

A: Use liftOver or similar tools to convert coordinates:
```bash
# Using UCSC liftOver
liftOver input.bed hg19ToHg38.over.chain.gz output.bed unlifted.bed
```

### Q: Can I use nucleotide positions instead of amino acid positions?

A: Yes, but you should convert them or adjust the protein_length accordingly. The plots work with any position system.

### Q: My data has multiple transcripts per gene. What should I do?

A: Choose one canonical transcript per gene:
- Select the longest transcript
- Use MANE (Matched Annotation from NCBI and EBI) transcripts
- Filter to one transcript before plotting

### Q: How do I handle indels?

A: The script handles indels automatically. They're displayed at their position with appropriate consequence colors.

## Running the Scripts

### Q: How do I run from R console instead of command line?

A: 
```r
# In R console
source("detailed_lollipop_plot.R")
library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# Load data
variants <- read.delim("variants.tsv", sep="\t")

# Create plot
plot <- create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "plot.png"
)
```

### Q: Can I save plots in different formats?

A: Yes! Change the file extension:
```r
output_file = "plot.pdf"  # PDF
output_file = "plot.png"  # PNG
output_file = "plot.svg"  # SVG
output_file = "plot.tiff" # TIFF
```

### Q: How do I make high-resolution plots for publication?

A: Specify higher DPI in the script:
```r
ggsave("plot.png", plot = p, width = 16, height = 10, dpi = 300)
```

### Q: The script is slow with my large dataset. What can I do?

A: Filter your data before plotting:
```r
# Keep only relevant variants
filtered <- variants %>%
  filter(kid_GT != "0/0") %>%                    # Has variant
  filter(vepIMPACT %in% c("HIGH", "MODERATE")) %>% # High impact
  filter(vepMAX_AF < 0.01)                       # Rare
```

## Plot Customization

### Q: How do I change colors?

A: Edit the `consequence_colors` vector in `detailed_lollipop_plot.R`:
```r
consequence_colors <- c(
  "missense_variant" = "#0000FF",  # Blue
  "frameshift_variant" = "#FF0000" # Red
  # Add more as needed
)
```

### Q: Can I change the plot size?

A: Yes, adjust width and height parameters:
```r
create_detailed_lollipop_plot(
  ...,
  width = 20,   # inches
  height = 12   # inches
)
```

### Q: How do I remove labels from all variants?

A: Comment out or remove the `geom_text_repel()` section in the script.

### Q: Can I change the point sizes?

A: Yes, modify the `scale_size_continuous()` call:
```r
scale_size_continuous(range = c(2, 8))  # Smaller
scale_size_continuous(range = c(5, 15)) # Larger
```

### Q: How do I add my own annotations?

A: Add custom annotations after creating the plot:
```r
plot <- create_detailed_lollipop_plot(...)

plot <- plot +
  annotate("text", x = 500, y = 5, label = "Important site") +
  annotate("rect", xmin = 450, xmax = 550, ymin = 0, ymax = 6,
           fill = NA, color = "red", linetype = "dashed")
```

## Domain and PTM Data

### Q: Where do I get protein domain data?

A: Download from:
1. **UniProt**: https://www.uniprot.org/
   - Search gene → Features → Export as TSV
2. **Pfam**: http://pfam.xfam.org/
   - Search protein → Download domain coordinates
3. **InterPro**: https://www.ebi.ac.uk/interpro/
   - Search protein → Export domain information

### Q: Where do I get PTM data?

A: PTM data sources:
1. **PhosphoSitePlus**: https://www.phosphosite.org/
   - Comprehensive PTM database
2. **UniProt**: Feature table includes PTMs
3. **dbPTM**: http://dbptm.mbc.nctu.edu.tw/

### Q: What format should domain data be in?

A:
```
gene    domain_name         start    end
BRCA1   RING domain         1        100
BRCA1   BRCT domain 1       1650     1740
```

### Q: What format should PTM data be in?

A:
```
gene    ptm_type           position    description
BRCA1   Phosphorylation    150         DNA damage response
BRCA1   Acetylation        654         Chromatin remodeling
```

### Q: Can I plot without domain/PTM data?

A: Yes! Simply omit those parameters:
```r
create_detailed_lollipop_plot(
  variant_data = variants,
  gene_name = "BRCA1",
  protein_length = 1863,
  output_file = "plot.png"
)
```

## Troubleshooting

### Q: My plot is empty!

A: Check these common issues:
1. Gene name matches exactly (case-sensitive):
```r
unique(variants$vepSYMBOL)
```
2. Positions are within range:
```r
summary(variants$POS)
```
3. kid_GT has variants:
```r
table(variants$kid_GT)
```

### Q: Labels are overlapping!

A: Try:
1. Increase plot size
2. Filter to fewer variants
3. Adjust `max.overlaps` in the script:
```r
geom_text_repel(..., max.overlaps = 30)
```

### Q: Domains are not showing!

A: Verify:
1. Gene names match exactly
2. Domain coordinates are within protein_length
3. Domain data is loaded correctly:
```r
print(domains)
```

### Q: Colors are all the same!

A: Check that vepConsequence values match defined colors:
```r
unique(variants$vepConsequence)
```

### Q: Plot creation fails with error!

A: Common solutions:
1. Ensure all required columns exist
2. Check for NA values:
```r
sum(is.na(variants$POS))
```
3. Verify numeric columns are numeric:
```r
class(variants$POS)
```

## Advanced Usage

### Q: Can I plot multiple genes in one script?

A: Yes:
```r
genes <- list(
  list(name = "BRCA1", length = 1863),
  list(name = "TP53", length = 393)
)

for (gene_info in genes) {
  create_detailed_lollipop_plot(
    variant_data = variants,
    gene_name = gene_info$name,
    protein_length = gene_info$length,
    output_file = paste0(gene_info$name, "_plot.png")
  )
}
```

### Q: How do I filter variants by allele frequency?

A:
```r
rare_variants <- variants %>%
  filter(vepMAX_AF < 0.001)  # AF < 0.1%

create_detailed_lollipop_plot(
  variant_data = rare_variants,
  ...
)
```

### Q: Can I show only specific consequence types?

A:
```r
missense <- variants %>%
  filter(vepConsequence == "missense_variant")

create_detailed_lollipop_plot(
  variant_data = missense,
  ...
)
```

### Q: How do I focus on a specific protein region?

A:
```r
# Filter variants to region
region_variants <- variants %>%
  filter(POS >= 1650 & POS <= 1855)

# Filter domains to region
region_domains <- domains %>%
  filter(start >= 1650 | end <= 1855)

create_detailed_lollipop_plot(
  variant_data = region_variants,
  protein_domains = region_domains,
  ...
)
```

### Q: Can I combine multiple families' data?

A: Yes, the script automatically aggregates variants across families. You can also filter:
```r
# Specific families
selected_families <- c("FAM001", "FAM002", "FAM003")
family_variants <- variants %>%
  filter(Family_ID %in% selected_families)
```

## Integration with Other Tools

### Q: Can I use this with VEP output?

A: Yes! Extract the needed columns from VEP output:
```bash
# Extract columns from VEP TSV output
cut -f1,2,3,4,5,14,48,50,49,... vep_output.tsv > formatted_variants.tsv
```

### Q: Can I integrate with ANNOVAR?

A: Yes, convert ANNOVAR output to the required format by mapping column names.

### Q: How do I use this in a pipeline?

A: Create a wrapper script:
```bash
#!/bin/bash
# pipeline.sh
VCF=$1
GENE=$2
LENGTH=$3

# Annotate
vep -i $VCF -o annotated.vcf --everything

# Convert and filter
# ... conversion steps ...

# Plot
Rscript detailed_lollipop_plot.R variants.tsv $GENE $LENGTH output.png
```

## Performance

### Q: How many variants can it handle?

A: The script can handle thousands of variants, but plotting may be slow with >10,000 variants per gene. Filter your data for better performance.

### Q: Can I speed up plot generation?

A: Yes:
1. Pre-filter data
2. Use fewer labels (adjust threshold)
3. Simplify PTM/domain data
4. Use lower DPI for drafts

### Q: Memory issues with large datasets?

A: Filter data before loading:
```r
# Use data.table or dplyr for efficient filtering
library(data.table)
variants <- fread("large_file.tsv") %>%
  filter(vepSYMBOL == "BRCA1") %>%
  as.data.frame()
```

## Output and Sharing

### Q: How do I share plots with collaborators?

A: Export as PNG or PDF:
- PNG: Good for presentations, emails, web
- PDF: Best for publications, vector graphics
- SVG: Editable in vector graphics software

### Q: Can I edit the plots after creation?

A: Yes:
- SVG/PDF: Edit in Illustrator, Inkscape
- Save as R object: Modify and re-render
```r
saveRDS(plot, "plot.rds")
# Later
plot <- readRDS("plot.rds")
plot <- plot + theme_bw()
ggsave("modified.png", plot)
```

### Q: How do I create a report with multiple plots?

A: Use R Markdown:
```rmarkdown
---
title: "Variant Report"
output: html_document
---

```{r}
source("detailed_lollipop_plot.R")
# Generate plots
```
```

## Getting Help

### Q: Where can I find more examples?

A: Check these files:
- `run_example.R`: Basic example
- `advanced_example.R`: Advanced filtering and customization
- `USAGE.md`: Detailed usage guide
- `VISUALIZATION_GUIDE.md`: Customization guide

### Q: I found a bug. What should I do?

A: Please:
1. Check if it's already fixed in the latest version
2. Create an issue on GitHub with:
   - Description of the problem
   - Example data (if possible)
   - Error messages
   - R version and package versions

### Q: Can I contribute?

A: Yes! Contributions are welcome:
- Bug fixes
- New features
- Documentation improvements
- Examples

Submit pull requests on GitHub.

### Q: How do I cite this tool?

A:
```
Detailed Lollipop Plots for Genomic Variants
https://github.com/jlanej/lollipop
```

## Additional Resources

- **VEP Documentation**: https://www.ensembl.org/vep
- **UniProt**: https://www.uniprot.org/
- **ggplot2 Documentation**: https://ggplot2.tidyverse.org/
- **R for Data Science**: https://r4ds.had.co.nz/
