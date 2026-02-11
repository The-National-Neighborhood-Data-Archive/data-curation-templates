/* 	turnover_nanda_topic_years_loop.do
	Looped tmplate for turnover of traditional NaNDA datasets - run once for all geographies
	Converts working versions to internally curated versions
	CHANGE LINES 9-12 and LINES 15-18, add curation steps, then run
	username date
*/
**********************************************************************************************************
* CHOOSE YOUR DATASET: Change these lines only
local workdir "O:\NaNDA\Data\DATASET_FOLDER\" // UPDATE: your dataset folder name
local dataset_name "XXXXXXXX"                  // Short name for the dataset (e.g., "broadbnd", "nhpd")
local date_range "2020-2023"                   // Years covered (for log filename only)
local version "01"                             // 2-digit version number
**********************************************************************************************************
// UPDATE SOURCE FILENAMES (paste actual filenames):
local sourcefile_tract10 "FILENAME.dta"
local sourcefile_tract20 "FILENAME.dta"
local sourcefile_zcta10 "FILENAME.dta"
local sourcefile_zcta20 "FILENAME.dta"
**********************************************************************************************************
* Loop through all four geographies
foreach dataset_type in tract10 tract20 zcta10 zcta20 {
    
    local geolevel = proper("`dataset_type'")
    local sourcefile "`sourcefile_`dataset_type''"

// Set geographic variable info based on dataset_type (don't change):
if "`dataset_type'" == "tract10" {
    local geoid_var "tract_fips10"
    local geoid_label "Census tract FIPS code, 2010"
    local area_var "aland10"
}
else if "`dataset_type'" == "tract20" {
    local geoid_var "tract_fips20"
    local geoid_var2 "tract_fips22"
    local geoid_label "Census tract FIPS code, 2020"
    local geoid_label2 "Census tract FIPS code, 2022 (Connecticut only, 2022-present)"
    local area_var "aland20"
}
else if "`dataset_type'" == "zcta10" {
    local geoid_var "zcta10"
    local geoid_label "ZIP Code Tabulation Area, 2010"
    local area_var "aland10"
}
else if "`dataset_type'" == "zcta20" {
    local geoid_var "zcta20"
    local geoid_label "ZIP Code Tabulation Area, 2020"
    local area_var "aland20"
}

// Auto-generated file paths (don't change):
local logfile = "code\turnover_`dataset_name'_`geolevel'_`date_range'_`version'.log"
local workfile = "datasets\workfiles_received\`sourcefile'"
local curatedfile = "datasets\nanda_`dataset_name'_`geolevel'_`date_range'_`version'.dta"

// Display what we're processing for verification
display as text "Processing: `sourcefile'"
display as text "Output: `curatedfile'"
if "`dataset_type'" == "tract20" {
    display as text "Geographic variables: `geoid_var', `geoid_var2'"
}
else {
    display as text "Geographic variable: `geoid_var'"
}

**********************************************************************************************************
* Start processing

capture log close
cd `workdir'
log using `logfile', replace
set linesize 120

******************************************************************************
* Section 1: Load working dataset
pwd
use `workfile', clear

display as text "Original data: `=_N' observations, `=c(k)' variables"

******************************************************************************
* Section 2: Filter data (if needed)
// Add any filtering logic here (e.g., keep if year >= 2020)

******************************************************************************
* Section 3: Rename variables
// Add dataset-specific renaming here
// Example: rename old_varname new_varname

// Reminder of standard names for geographic units:
// tract_fips10, tract_fips20, tract_fips22
// zcta10, zcta20
// stcofips10, stcofips20

******************************************************************************
* Section 4: Fix data types and leading zeros (if needed)
// Check geographic identifiers are strings with correct length
// Example: tostring tract_fips20, replace format(%11.0f)

// Add tract_fips22 for tract20 datasets
/*if "`dataset_type'" == "tract20" {
    display as text "Adding tract_fips22 for Connecticut boundary changes..."
    
    local tract22xwalk "O:/NaNDA/Data/crosswalks/ct_2022_2020_xwalk/2022-tract-crosswalk-main/2022tractcrosswalk"
    
    display "check if `geoid_var' starts with 090"
    count if substr(`geoid_var', 1, 3) == "090"
    if `r(N)' > 0 {
        display "`geoid_var' starts with 090 so it is tract_fips20, we need to add tract_fips22"
        capture clonevar tract_fips20 = `geoid_var'
        * these tracts have no land area and no population, they are not in the crosswalk
        drop if inlist(tract_fips20, "09001990000", "09007990100", "09009990000", "09011990100")
        capture drop tract_fips22
        merge m:1 tract_fips20 using "`tract22xwalk'", keep(match master) keepusing(tract_fips22) nogen
        replace tract_fips22 = tract_fips20 if missing(tract_fips22)
        order tract_fips20 tract_fips22
    }
    
    display "check if `geoid_var' starts with 091"
    count if substr(`geoid_var', 1, 3) == "091"
    if `r(N)' > 0 {
        display "`geoid_var' starts with 091 so it is tract_fips22, we need to add tract_fips20"
        capture clonevar tract_fips22 = `geoid_var'
        * these tracts have no land area and no population, they are not in the crosswalk
        drop if inlist(tract_fips22, "09120990000", "09190990000", "09170990000", "09130990100", "09180990100")
        capture drop tract_fips20
        merge m:1 tract_fips22 using "`tract22xwalk'", keep(match master) keepusing(tract_fips20) nogen
        replace tract_fips20 = tract_fips22 if missing(tract_fips20)
        order tract_fips20 tract_fips22
    }
    
    display "Validation checks:"
    display "these three numbers should match"
    count if substr(`geoid_var', 1, 2) == "09"
    count if tract_fips20 != tract_fips22
    count if tract_fips20 != tract_fips22 & substr(`geoid_var', 1, 2) == "09" 
    display "this number should be 0"
    count if tract_fips20 != tract_fips22 & substr(`geoid_var', 1, 2) != "09"
    
    display as text "tract_fips22 added successfully"
	*/

******************************************************************************
* Section 5: Variable labels
// Label geographic identifier
label variable `geoid_var' "`geoid_label'"

// Label tract_fips22 for tract20 datasets
if "`dataset_type'" == "tract20" {
    capture confirm variable `geoid_var2'
    if !_rc {
        label variable `geoid_var2' "`geoid_label2'"
    }
}

// Label population variable (if present)
capture confirm variable totpop
if !_rc {
    label variable totpop "Total population"
}

// Label area variable (if present)
capture confirm variable `area_var'
if !_rc {
    if "`dataset_type'" == "tract10" | "`dataset_type'" == "tract20" {
        label variable `area_var' "Census land area, square miles"
    }
    else {
        label variable `area_var' "ZCTA land area, square miles"
    }
}

// Add other dataset-specific variable labels here

display as text "Variable labeling completed"

******************************************************************************
* Section 6: Final QA and save
describe
summarize

display as text "Final data: `=_N' observations, `=c(k)' variables"

// Save cleaned dataset
save `curatedfile', replace
display as text "Saved: `curatedfile'"

display as text "Turnover completed successfully for `geolevel'"
log close

******************************************************************************
* Section 7: Create data dictionary

******************************************************************************
* Section 7: Create data dictionary

// Save current data for dictionary creation
tempfile data_for_dict
save `data_for_dict'

log using "`workdir'code\dictionary_`dataset_name'_`geolevel'_`date_range'.log", replace text

display as text _newline "Creating dictionary for `geolevel'..." _newline

// Get basic variable info
describe, replace clear
rename name variable
rename type type

// Initialize new columns in desired order
gen obs = .
gen unique = .
gen mean = .
gen min = .
gen max = .
gen label = ""

// Save structure
tempfile dict
save `dict'

local nvars = _N

// Fill in info for each variable
forvalues j = 1/`nvars' {
    use `dict', clear
    local varname = variable[`j']
    
    // Load main data to get stats
    use `data_for_dict', clear
    
    // Get label
    local lab : variable label `varname'
    
    // Get counts
    count if !missing(`varname')
    local n_obs = r(N)
    
    // Get unique count
    capture tab `varname'
    if _rc == 0 & r(r) < 10000 {
        // tab worked and has reasonable number of categories
        local n_unique = r(r)
    }
    else {
        // For continuous or high-cardinality vars, count distinct values
        tempfile origdata
        save `origdata'
        keep `varname'
        bysort `varname': keep if _n == 1
        count
        local n_unique = r(N)
        use `origdata', clear
    }
    
    // Get mean/min/max for numeric vars
    capture summarize `varname', meanonly
    if _rc == 0 {
        local var_mean = r(mean)
        local var_min = r(min)
        local var_max = r(max)
    }
    else {
        local var_mean = .
        local var_min = .
        local var_max = .
    }
    
    // Update dictionary
    use `dict', clear
    replace label = "`lab'" in `j'
    replace obs = `n_obs' in `j'
    replace unique = `n_unique' in `j'
    replace mean = `var_mean' in `j'
    replace min = `var_min' in `j'
    replace max = `var_max' in `j'
    save `dict', replace
    
    display "." _continue
}

// Export final dictionary with new column order
use `dict', clear
order variable type obs unique mean min max label
keep variable type obs unique mean min max label

export delimited using "`workdir'documentation\nanda_`dataset_name'_`geolevel'_`date_range'_dictionary.csv", ///
    replace

display _newline "`geolevel' dictionary complete!"

// Close log
log close
}  // end geography loop

display as text _newline(2) "All geographies processed successfully!"

display as text _newline(2) "All geographies processed successfully!"