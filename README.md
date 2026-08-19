# NaNDA Data Curation Templates

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22018832.svg)](https://doi.org/10.5281/zenodo.22018832)

This repository contains standardized Stata templates for the National Neighborhood Data Archive (NaNDA) data curation workflow. These templates automate quality control, variable standardization, and data dictionary generation across multiple geographic boundary definitions.

## About NaNDA

The [National Neighborhood Data Archive (NaNDA)](https://nanda.isr.umich.edu/) is a publicly available data repository providing neighborhood-level datasets for health research. All datasets are published through [ICPSR](https://search.icpsr.umich.edu/search/search/nanda/studies) and normalized to four geographic levels: Census Tract 2010, Census Tract 2020, ZCTA 2010, and ZCTA 2020.

## Templates

### validate_nanda_topic_years_loop.do
Performs initial quality checks on newly received datasets:
- Verifies geographic identifier format and completeness
- Checks observation counts against expected totals
- Assesses state/region coverage
- Identifies missing data patterns
- Exports preliminary data dictionary for review

### turnover_nanda_topic_years_loop.do
Converts working datasets to internally curated versions:
- Standardizes variable naming conventions
- Corrects data types and preserves leading zeros
- Applies comprehensive variable labels
- Prepares datasets for publication

### publish_nanda_topic_years_loop.do
Finalizes datasets for public release:
- Saves public versions in Stata format
- Exports CSV versions for broader accessibility
- Generates detailed data dictionaries
- Processes all four geographic levels automatically

### [NETS/](NETS/) — NETS SIC counts driver template
Driver template for building neighborhood-level business counts from the
National Establishment Time Series (NETS) database:
- Builds establishment counts per geography-year for user-defined SIC
  business categories, then merges categories into one dataset
- Supports tract10, tract20, zcta10, and zcta20 geographies
- Requires licensed NETS data access and a counts subroutine not included in
  this repository (NETS is proprietary); the template covers the driver logic only
- See [NETS/README.md](NETS/README.md) for full usage, configuration, and
  label-escaping documentation

## Usage

The three curation templates (validate → turnover → publish) run sequentially:

1. Update parameters at the top of each template (lines 8-11):
   - `workdir`: Your dataset folder path
   - `dataset_name`: Short identifier for your dataset
   - `dataset_type`: tract10, tract20, zcta10, or zcta20
   - `date_range`: Years covered
   - `version`: Two-digit version number

2. Update source filenames in the designated section

3. Add dataset-specific processing steps where indicated

4. Run sequentially: validate → turnover → publish

The NETS counts template runs standalone; see its header comments for setup.

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

## Citation

Archived on Zenodo. Cite all versions with the concept DOI
[10.5281/zenodo.22018832](https://doi.org/10.5281/zenodo.22018832), or a
specific release by its version DOI (v1.0.0:
[10.5281/zenodo.22018833](https://doi.org/10.5281/zenodo.22018833)). See
CITATION.cff for the citation format.

## License

These templates are released under the MIT License. See LICENSE file for details.
