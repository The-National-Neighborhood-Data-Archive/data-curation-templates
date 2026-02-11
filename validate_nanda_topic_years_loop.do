/* 	validate_nanda_topic_years_auto.do
	Looped template for validating traditional NaNDA datasets - run once for all geographies
	Runs validation for all four geographies
	username date
	CHANGE LINES 9-17 and LINES 13-16 to select your dataset, then run
*/
**********************************************************************************************************
* CHOOSE YOUR DATASET: Change these lines only
local workdir "O:\NaNDA\Data\DATASET_FOLDER\" // UPDATE: your dataset folder name
local dataset_name "XXXXXXXX"    // Short name for the dataset (e.g., "broadbnd", "nhpd")
local date_range "2020-2023"     // Years covered (for log filename only)

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
    
    // Set geographic variable info and expected observations
    if "`dataset_type'" == "tract10" {
        local geoid_var "tract_fips10"
        local geoid_length "11"
        local expected_obs "73000"
    }
    else if "`dataset_type'" == "tract20" {
        local geoid_var "tract_fips20"
        local geoid_var2 "tract_fips22"
        local geoid_length "11"
        local expected_obs "84400"
    }
    else if "`dataset_type'" == "zcta10" {
        local geoid_var "zcta10"
        local geoid_length "5"
        local expected_obs "33000"
    }
    else if "`dataset_type'" == "zcta20" {
        local geoid_var "zcta20"
        local geoid_length "5"
        local expected_obs "33600"
    }
    
    display as text _newline(2) "Running validation for: `sourcefile'" _newline
    if "`dataset_type'" == "tract20" {
        display as text "Geographic variables: `geoid_var', `geoid_var2'"
    }
    else {
        display as text "Geographic variable: `geoid_var'"
    }
    display as text "Expected observations: ~`expected_obs'"
    
    **********************************************************************************************************
    * Validation code 
    local date: display %tdCY-N-D td(`c(current_date)')
    local logfile = "code\validate_`dataset_name'_`geolevel'_`date_range'_`date'.log"
    local workfile = "datasets\workfiles_received\`sourcefile'"
    local dictionary = "code\validate_`dataset_name'_`geolevel'_`date_range'_`date'_data_dictionary.xlsx"
    
    capture log close
    cd `workdir'
    log using `logfile', replace
    
    ******************************************************************************
    *Load working dataset
    pwd
    use `workfile', clear
    
    ******************************************************************************
    * Dataset exploration & common validation checks
    describe, fullnames
    
    * NAMES AND LABELS
    if "`dataset_type'" == "tract20" {
        display as text "Expected geographic variables: `geoid_var', `geoid_var2'"
        capture confirm variable `geoid_var2'
        if _rc {
            display as error "WARNING: `geoid_var2' not found in dataset"
        }
    }
    else {
        display as text "Expected geographic variable: `geoid_var'"
    }
    * Are variable names clear? Do they need renaming or relabeling? Are units obvious?
    
    * VALUE LABELS
    label list
    
    * DATA TYPES & NUMBER OF OBSERVATIONS  
    display as text "Expected observations: ~`expected_obs'"
    summarize
    
    * LEADING ZEROS
    describe `geoid_var'
    generate geoid_len = strlen(`geoid_var')
    tab geoid_len
    display as text "All `geoid_var' should be `geoid_length' digits long"
    
    * STATES/REGIONS REPRESENTED
    if regexm("`dataset_type'", "^tract") {
        * For census tracts: check state
        * 02 Alaska, 15 Hawaii, 72/43 Puerto Rico, 78/52 Virgin Islands 
        generate state = substr(`geoid_var', 1, 2)
        tab state
    }
    else if regexm("`dataset_type'", "^zcta") {
        * For ZCTAs: check region (first 3 digits)
        generate region = substr(`geoid_var', 1, 3)
        tab region
    }
    
    drop geoid_len
    
    * MISSINGNESS
    capture ssc install mdesc
    mdesc
    * Do any variables have unusually high levels of missing data?
    
    * OUTLIER VALUES
    * Considering what they represent, do any variables have unusual max, min, or average values?
    
    * VARIABLE RELATIONSHIPS
    * Are there variables whose values should relate to one another (sums, ratios)?
    * Do they relate as expected?
    
    log close
    
    ******************************************************************************
    * Export data dictionary to Excel for easier variable renaming/relabeling
    
    log using `logfile', append
    
    describe, replace clear
    keep name type varlab
    rename name Variable
    rename type Type
    rename varlab Label
    
    export excel using `dictionary', firstrow(variables) replace
    display as text "Data dictionary exported: `dictionary'"
    
    log close

}  // end geography loop

display as text _newline(2) "All geographies validated!"