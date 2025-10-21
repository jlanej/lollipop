# Project Structure and Workflow

## File Organization

```
lollipop/
├── Core Functionality
│   ├── detailed_lollipop_plot.R    # Main plotting functions
│   ├── example_data.R               # Example data generators
│   └── batch_process.R              # Batch processing script
│
├── Example Scripts
│   ├── run_example.R                # Basic example
│   ├── advanced_example.R           # Advanced filtering examples
│   └── install_packages.R           # Package installer
│
├── Documentation
│   ├── README.md                    # Main documentation
│   ├── QUICKSTART.md                # 5-minute setup guide
│   ├── USAGE.md                     # Detailed usage instructions
│   ├── VISUALIZATION_GUIDE.md       # Plot interpretation guide
│   ├── FAQ.md                       # Common questions
│   └── IMPLEMENTATION_SUMMARY.md    # Technical summary
│
├── Configuration
│   ├── example_genes.tsv            # Gene configuration template
│   └── .gitignore                   # Git ignore rules
│
└── Generated (not in git)
    ├── *.png                        # Output plots
    ├── example_variants.tsv         # Generated example data
    ├── example_domains.tsv          # Generated example domains
    └── example_ptms.tsv             # Generated example PTMs
```

## Workflow Diagrams

### Basic Workflow

```
┌─────────────────┐
│  Install R      │
│  Packages       │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Prepare Your   │
│  Variant Data   │  (TSV with required columns)
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Run Plotting   │
│  Script         │  detailed_lollipop_plot.R
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  View Output    │
│  PNG/PDF        │
└─────────────────┘
```

### Advanced Workflow with All Features

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Variant Data   │     │  Domain Data    │     │  PTM Data       │
│  (Required)     │     │  (Optional)     │     │  (Optional)     │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                        │
         └───────────────────────┼────────────────────────┘
                                 │
                                 ↓
                        ┌─────────────────┐
                        │  Data Filtering │
                        │  - Impact       │
                        │  - AF           │
                        │  - Genotype     │
                        └────────┬────────┘
                                 │
                                 ↓
                        ┌─────────────────┐
                        │  Create Plot    │
                        │  with all       │
                        │  features       │
                        └────────┬────────┘
                                 │
                                 ↓
                        ┌─────────────────┐
                        │  Detailed       │
                        │  Lollipop Plot  │
                        │  + Statistics   │
                        └─────────────────┘
```

### Batch Processing Workflow

```
┌─────────────────┐     ┌─────────────────┐
│  Variant Data   │     │  Gene Config    │
│  (All genes)    │     │  (gene list +   │
│                 │     │   lengths)      │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     │
                     ↓
            ┌─────────────────┐
            │  batch_process  │
            │  .R script      │
            └────────┬────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ↓           ↓           ↓
    ┌────────┐  ┌────────┐  ┌────────┐
    │ Gene 1 │  │ Gene 2 │  │ Gene N │
    │ Plot   │  │ Plot   │  │ Plot   │
    └────────┘  └────────┘  └────────┘
```

## Data Flow

### Input Data Structure

```
Variant Data (TSV):
┌──────────────────────────────────────────────────────┐
│ Family_ID │ CHROM │ POS │ REF │ ALT │ vepSYMBOL │ ... │
├───────────┼───────┼─────┼─────┼─────┼───────────┼─────┤
│ FAM001    │ chr17 │ 123 │ A   │ G   │ BRCA1     │ ... │
│ FAM001    │ chr17 │ 456 │ C   │ T   │ BRCA1     │ ... │
│ FAM002    │ chr17 │ 123 │ A   │ G   │ BRCA1     │ ... │
└──────────────────────────────────────────────────────┘
                           ↓
                    Aggregation
                           ↓
Position-Based Variant Counts:
┌────────────────────────────────────┐
│ Position │ Count │ Consequence │ ... │
├──────────┼───────┼─────────────┼─────┤
│ 123      │ 2     │ missense    │ ... │
│ 456      │ 1     │ frameshift  │ ... │
└────────────────────────────────────┘
```

### Plot Generation Process

```
1. Data Loading
   ↓
2. Filtering & Validation
   ↓
3. Variant Aggregation (by position)
   ↓
4. Plot Construction:
   ├── Protein backbone (horizontal line)
   ├── Protein domains (rectangles)
   ├── PTMs (shaped markers)
   ├── Variant stems (vertical lines)
   ├── Variant heads (colored circles)
   └── Labels (high-impact variants)
   ↓
5. Save to File
```

## Function Call Hierarchy

```
main script
│
├── load_variant_data()
│   └── read.delim()
│
├── create_detailed_lollipop_plot()
│   ├── filter() - gene selection
│   ├── group_by() + summarise() - aggregation
│   ├── ggplot()
│   │   ├── geom_segment() - protein backbone
│   │   ├── annotate() - domains
│   │   ├── geom_point() - PTMs
│   │   ├── geom_segment() - lollipop stems
│   │   ├── geom_point() - lollipop heads
│   │   └── geom_text_repel() - labels
│   └── ggsave() - save to file
│
└── summarize_variants()
    └── group_by() + summarise() - statistics
```

## Script Execution Paths

### Path 1: Command Line Execution

```bash
Rscript detailed_lollipop_plot.R variants.tsv BRCA1 1863 output.png
    ↓
commandArgs() reads parameters
    ↓
load_variant_data(variants.tsv)
    ↓
create_detailed_lollipop_plot(...)
    ↓
summarize_variants(...) - prints to console
    ↓
output.png created
```

### Path 2: R Console/Script

```r
source("detailed_lollipop_plot.R")
    ↓
library() calls load packages
    ↓
User calls functions directly:
    ├── load_variant_data()
    ├── create_detailed_lollipop_plot()
    └── summarize_variants()
```

### Path 3: Example Script

```bash
Rscript run_example.R
    ↓
source() loads functions
    ↓
generate_example_*() creates data
    ↓
create_detailed_lollipop_plot() twice
    ├── Detailed version (with domains/PTMs)
    └── Simple version (variants only)
    ↓
write.table() saves example data
```

## Color Coding Logic

```
Variant → vepConsequence
              ↓
    ┌─────────┴─────────┐
    │                   │
High Impact         Moderate Impact
(frameshift,        (missense,
 stop_gained,        inframe indels)
 splice)                 ↓
    ↓               Orange (#FFA500)
Red (#FF0000)
    │                   │
    └─────────┬─────────┘
              │
    ┌─────────┴─────────┐
    │                   │
Low Impact          Modifier
(synonymous)        (intron, UTR)
    ↓                   ↓
Green (#00AA00)     Light Blue
```

## Quick Reference: File Usage

| File | When to Use | Purpose |
|------|-------------|---------|
| `install_packages.R` | First time setup | Install dependencies |
| `run_example.R` | Learning/Testing | See how it works |
| `detailed_lollipop_plot.R` | Production use | Create plots for your data |
| `batch_process.R` | Multiple genes | Process many genes at once |
| `advanced_example.R` | Learning filters | See filtering examples |
| `QUICKSTART.md` | Getting started | 5-minute setup guide |
| `USAGE.md` | Daily reference | Detailed how-to |
| `FAQ.md` | Troubleshooting | Common problems |

## Integration Points

```
External Tools → This Package → Output
───────────────────────────────────────
VCF file
    ↓ (VEP annotation)
VEP output TSV
    ↓ (format conversion)
variant data TSV → detailed_lollipop_plot.R → PNG/PDF
                            ↑
UniProt/Pfam → domain TSV ──┤
                            ↑
PhosphoSite → PTM TSV ──────┘
```

## Key Design Decisions

1. **TSV Input Format**: Easy to prepare, human-readable, standard
2. **ggplot2 Framework**: High-quality graphics, highly customizable
3. **Modular Functions**: Reusable, testable, maintainable
4. **Optional Components**: Domains/PTMs optional for flexibility
5. **Command Line Support**: Easy integration into pipelines
6. **Comprehensive Docs**: Multiple documentation levels for different needs

## Performance Characteristics

```
Data Size → Processing Time (approx)
─────────────────────────────────────
< 100 variants     → < 1 second
< 1,000 variants   → 1-5 seconds
< 10,000 variants  → 5-30 seconds
> 10,000 variants  → Filter first

Memory Usage:
─────────────
Small dataset  → < 100 MB
Medium dataset → 100-500 MB
Large dataset  → > 500 MB (consider filtering)
```

## Extensibility

The modular design allows easy extension:

1. **New Consequence Types**: Add to `consequence_colors`
2. **New PTM Types**: Add to `ptm_shapes`
3. **Custom Annotations**: Use ggplot2 layers
4. **New Output Formats**: Change `ggsave()` parameters
5. **Additional Stats**: Extend `summarize_variants()`

## Summary

This structure provides:
- ✅ Clear separation of concerns
- ✅ Easy to understand workflow
- ✅ Flexible for different use cases
- ✅ Well-documented at all levels
- ✅ Production-ready code
