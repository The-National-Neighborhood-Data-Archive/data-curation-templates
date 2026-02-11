# NaNDA Data Curation Templates

This repository contains standardized Stata templates for the National Neighborhood Data Archive (NaNDA) data curation workflow. These templates automate quality control, variable standardization, and data dictionary generation across multiple geographic boundary definitions.

## About NaNDA

The [National Neighborhood Data Archive (NaNDA)](https://nanda.isr.umich.edu/) is a publicly available data repository providing neighborhood-level datasets for health research. All datasets are published through [ICPSR](https://search.icpsr.umich.edu/search/search/nanda/studies) and normalized to four geographic levels: Census Tract 2010, Census Tract 2020, ZCTA 2010, and ZCTA 2020.

## Templates

### validate_nanda_topic_years_auto.do
Performs initial quality checks on newly received datasets:
- Verifies geographic identifier format and completeness
- Checks observation counts against expected totals
- Assesses state/region coverage
- Identifies missing data patterns
- Exports preliminary data dictionary for review

### turnover_nanda_topic_years_auto.do
Converts working datasets to internally curated versions:
- Standardizes variable naming conventions
- Corrects data types and preserves leading zeros
- Applies comprehensive variable labels
- Prepares datasets for publication

### publish_nanda_topic_years_auto.do
Finalizes datasets for public release:
- Saves public versions in Stata format
- Exports CSV versions for broader accessibility
- Generates detailed data dictionaries
- Processes all four geographic levels automatically

## Usage

1. Update parameters at the top of each template (lines 8-11):
   - `workdir`: Your dataset folder path
   - `dataset_name`: Short identifier for your dataset
   - `dataset_type`: tract10, tract20, zcta10, or zcta20
   - `date_range`: Years covered
   - `version`: Two-digit version number

2. Update source filenames in the designated section

3. Add dataset-specific processing steps where indicated

4. Run sequentially: validate → turnover → publish

## Requirements

- Stata 17 or later
- Source data files in Stata format (.dta)
- Proper directory structure with `datasets/`, `code/`, and `documentation/` folders

## Geographic Standards

NaNDA uses standardized geographic identifier naming:
- `tract_fips10` — 11-digit census tract FIPS code, 2010 boundaries
- `tract_fips20` — 11-digit census tract FIPS code, 2020 boundaries  
- `tract_fips22` — 11-digit census tract FIPS code, 2022 boundaries (Connecticut only)
- `zcta10` — 5-digit ZIP Code Tabulation Area, 2010 boundaries
- `zcta20` — 5-digit ZIP Code Tabulation Area, 2020 boundaries

All geographic identifiers are stored as strings with leading zeros preserved.

## Contact

Questions about NaNDA or these templates? Visit [nanda.isr.umich.edu](https://nanda.isr.umich.edu/) or email nanda-info@umich.edu.

## License

These templates are released under the MIT License. See LICENSE file for details.
