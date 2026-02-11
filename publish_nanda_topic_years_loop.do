/*==============================================================================
Project: NaNDA [PROJECT NAME]
Purpose: Publish final datasets - save public version, create data dictionary, and export CSV
Template - update parameters for each dataset
gypin [DATE]
==============================================================================*/
capture log close
clear all
set more off

* Parameters - update for each dataset
local filestring "topic"        /* subject/project name */
local daterange "1990-2022"         /* date range */
local version "02"                  /* default version number */

* Set base directory
global basedir "O:\NaNDA\Data\essential_businesses"

* Define geography types and their corresponding variables
local geographies "Tract10 Tract20 Zcta10 Zcta20"
local geoid_vars "tract_fips10 tract_fips20 zcta10 zcta20"

* Create CSV output folder if it doesn't exist
capture mkdir "$basedir/datasets/nanda_`filestring'_csvs"

* Loop through each geography
local i = 1
foreach geo of local geographies {
    local geoid_var : word `i' of `geoid_vars'
    
    display as text _newline(2) "Processing `geo'..." _newline
    
    * Start log file
    log using "$basedir/code/publish_`filestring'_`geo'_`daterange'.log", replace text
    
    * Define file paths
    local workdir "$basedir/datasets"
    local internalfile "`workdir'/nanda_`filestring'_`geo'_`daterange'_`version'.dta"
    * Special case example: uncomment and modify if needed
    * local Tract20file "`workdir'/nanda_`filestring'_Tract20-22_`daterange'_03.dta"
    local publicfile "`workdir'/nanda_`filestring'_`geo'_`daterange'_`version'P.dta"
    local csvfile "$basedir/datasets/nanda_`filestring'_csvs/nanda_`filestring'_`geo'_`daterange'_`version'P.csv"
    
    * Section 1: Load working dataset
    cd `workdir'
    * Determine which file to use
    * Special case handling - comment out if not needed
    * if "`geo'" == "Tract20" {
    *     local fileinuse "`Tract20file'"
    * }
    * else {
        local fileinuse "`internalfile'"
    * }
	
    use `fileinuse', clear
    display "`fileinuse'"
    
    * Section 2: Any other curation steps we need to repeat
    * (Add any final data cleaning or quality checks here)
			
    * Section 3: Save public dataset
    save `publicfile', replace
    
    * Section 4: Export CSV version
    export delimited using `csvfile', datafmt quote replace
    
    * Close log
    log close
	
    * Section 5: Create data dictionary
    * Save current data for dictionary creation
    tempfile data_for_dict
    save `data_for_dict'
	
    log using "$basedir/code/dictionary_`filestring'_`geo'_`daterange'.log", replace text
	
    display as text _newline "Creating dictionary for `geo'..." _newline
	
    * Get basic variable info
    describe, replace clear
    rename name variable
    rename type type
    
    * Initialize new columns in desired order
    gen obs = .
    gen unique = .
    gen mean = .
    gen min = .
    gen max = .
    gen label = ""
    
    * Save structure
    tempfile dict
    save `dict'
    
    local nvars = _N
    
    * Fill in info for each variable
    forvalues j = 1/`nvars' {
        use `dict', clear
        local varname = variable[`j']
        
        * Load main data to get stats
        use `data_for_dict', clear
        
        * Get label
        local lab : variable label `varname'
        
        * Get counts
        count if !missing(`varname')
        local n_obs = r(N)
        
        * Get unique count
        capture tab `varname'
        if _rc == 0 & r(r) < 10000 {
            * tab worked and has reasonable number of categories
            local n_unique = r(r)
        }
        else {
            * For continuous or high-cardinality vars, count distinct values
            tempfile origdata
            save `origdata'
            keep `varname'
            bysort `varname': keep if _n == 1
            count
            local n_unique = r(N)
            use `origdata', clear
        }
        
        * Get mean/min/max for numeric vars
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
        
        * Update dictionary
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
    
    * Export final dictionary with new column order
    use `dict', clear
    order variable type obs unique mean min max label
    keep variable type obs unique mean min max label
    
    export delimited using "$basedir/documentation/nanda_`filestring'_`geo'_`daterange'_dictionary.csv", ///
        replace
    
    display _newline "`geo' dictionary complete!"
    
    * Close log
    log close

    local i = `i' + 1
}

display as text _newline(2) "All geographies published successfully!"
