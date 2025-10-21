# Testing the JMJD1C Auto-Retrieval Fix

This directory contains test files to verify that the auto-retrieval fix works correctly.

## Test Files

### 1. test_problem_scenario.R
Reproduces the exact scenario from the problem statement where JMJD1C auto-retrieval was failing.

**Purpose**: Verify that the specific issue reported is now fixed.

**Run with**:
```bash
Rscript test_problem_scenario.R
```

**Expected Output**:
- Should successfully create a plot
- Should print "SUCCESS" at the end
- Should NOT fail with "protein_length must be provided or auto_retrieve must be enabled"

### 2. test_jmjd1c_fix.R
Full integration test with JMJD1C including plot generation.

**Purpose**: Test the complete workflow with realistic data.

**Run with**:
```bash
Rscript test_jmjd1c_fix.R
```

**Expected Output**:
- Should successfully retrieve protein data
- Should create a lollipop plot
- May show warnings if domain/PTM extraction has issues (this is expected and acceptable)

### 3. test_unit_data_retrieval.R
Unit tests for the `retrieve_protein_data()` function.

**Purpose**: Test just the data retrieval layer independently.

**Run with**:
```bash
Rscript test_unit_data_retrieval.R
```

**Expected Output**:
- Should successfully retrieve protein_length for JMJD1C
- Should successfully retrieve protein_length for BRCA1 (control test)
- Should return proper data structures (data frames) for domains and PTMs

## Running All Tests

To run all tests at once:

```bash
Rscript test_problem_scenario.R
Rscript test_jmjd1c_fix.R
Rscript test_unit_data_retrieval.R
```

## What to Look For

### Success Indicators
- ✓ Messages showing "SUCCESS" or "PASS"
- ✓ Protein length is retrieved (e.g., "2540 amino acids" for JMJD1C)
- ✓ No errors about "protein_length must be provided"
- ✓ Plots are created successfully

### Acceptable Warnings
- ⚠ "Failed to extract domains: ..." - This is acceptable if the UniProt features data is in an unexpected format
- ⚠ "Failed to extract PTMs: ..." - This is acceptable if the UniProt features data is in an unexpected format
- ⚠ "Features is not a data frame" - This indicates the data validation is working correctly

The key point is that even with these warnings, the function should still succeed and return protein_length.

### Failure Indicators
- ✗ Error: "protein_length must be provided or auto_retrieve must be enabled"
- ✗ Error in retrieve_protein_data() that prevents it from completing
- ✗ protein_length is NULL after retrieval

## Notes

- Tests require an internet connection to access the UniProt API
- Some tests create temporary cache directories that are automatically cleaned up
- Generated plot files are automatically removed after testing

## Troubleshooting

If tests fail:

1. **Check internet connection**: The tests need to access UniProt API
2. **Check R packages**: Ensure all required packages are installed (ggplot2, dplyr, httr, jsonlite, scales, ggrepel)
3. **Check UniProt API**: The UniProt API may be temporarily unavailable
4. **Check for API changes**: UniProt may have changed their data format

If you see the original error ("protein_length must be provided..."), the fix is not working correctly.
