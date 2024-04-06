//TODO:

// currently does not work with abbreviated variable names

//- is there a way to implement / generalize Dorry's "maxedout" option?
//  (if no match, pick somebody with age within 5y, BMI 20-30, BP 100-140)

//TODO: radii are reported incorrectly in posted dataset
//(always reported as maximum allowable radius)
//for exmaple, in ltmatch_k2_without, "init_age" always = 5 even though actual radius is usu 1 or 2

//- k>1 and "without are IMPLEMENTED!

program define irmatch
//rmatch 0.03
//by Allan Massie and Dorry Segev, Segev lab
//Department of Surgery, Johns Hopkins School of Medicine

syntax anything using, case(varname) id(varname) ///
    [k(int 1)] [seed(real 420)] [without] [replace] [verbose] [pedantic]
   //without = without replacement

    disp in smcl "{hline}"
    disp "rmatch 0.03."
    disp "When using this code, please cite:"
    disp in smcl "Massie et al 2013, {hi:'Stata Journal Article'}"
    disp "For a good reference on the radius matching techniques, consider:"
    disp in smcl "James et al 2013, {hi:'Iterative Expanding Radius matching for observational studies'}," ///
    " PMID {hi:XXXXXX}"
    disp in smcl "{hline}"

    preserve

    //make a local copy of `0' to parse syntax before we actually get started
    //local arglist = "`0'"
    local arglist "`0'"   //hopefully this fixes the max-256-char thing

    //PARSE INPUT
    local n = 0
    local repeatvars = 0  //once they start repeating, you can't add new vars
    gettoken curarg arglist:arglist
    while "`curarg'" != "using" & `n' < 20 {
        local n = `n' + 1
        //gettoken curarg arglist:arglist
        //curarg = current argument
        //which should be of the form varname(n1(n2)n3) 
        //NOTE: using "tokenize" here will spoil `1', `2', etc.
        //does not spoil `0'
        tokenize "`curarg'", parse("()")
        //now, `1' should be a varname
        local badinput = 0
        if "`2'`4'`6'`8'" != "(())"{
            local badinput = 1
        }
        capture confirm number `3'
        if _rc {
            local badinput = 1
        }
        capture confirm number `5'
        if _rc {
            local badinput = 1
        }
        capture confirm number `7'
        if _rc {
            local badinput = 1
        }
        capture assert `3' < `7'
        if _rc {
            local badinput = 1
        }
        if `badinput' == 1 {
            disp as error in smcl ///
            "Error: each argument must be of the form varname(#1(#2)#3)"
            disp as error in smcl ///
            "Where #1, #2 and #3 are numbers and #1 <= #3"
            disp as error in smcl ///
            "Bad argument `curarg'"
            exit
        }
        capture confirm variable `1'
        if _rc {
            disp as error in smcl "Error: variable `1' does not exist"
            exit
        }
        capture confirm numeric variable `1'
        if _rc {
            disp as error in smcl "Error: variable `1' is not numeric"
            exit
        }
        //input for this variable is valid


        if `repeatvars' == 0 {
            if "``1'_start'" == "" { //this var has not been listed before
                local `1'_start = `3'
                local `1'_rad = `3'
                local distinct_vars "`distinct_vars' `1'"
            }
            else {  //this var HAS been listed before
                local repeatvars = 1
                local n_distinct = `n' - 1  //# of distinct variables
            }
        }
        else if "``1'_start '" == "" {
            disp as error in smcl ///
                "Error: after listing the same variable twice, you can't introduce new variables "
            exit
        }

        local var`n'_name = "`1'"
        local var`n'_min = `3'
        local var`n'_step = `5'
        local var`n'_max = `7'

        gettoken curarg arglist:arglist
    }
    //DONE PARSING INPUT
    //if we get this far, then the function was called correctly

    //construct the if statements
    local n_ifs = 0
    //iterate over (possibly repeating) list of variables
    forvalues i = 1/`n' {
        //iterate stepping from min to max
        local curvar "`var`i'_name'"
//disp  "`var`i'_min'(`var`i'_step')`var`i'_max'"
        forvalues var_step = `var`i'_min'(`var`i'_step')`var`i'_max' {
            local `curvar'_rad = `var_step'
//disp "`curvar'   ``curvar'_rad'"
            local n_ifs = `n_ifs' + 1
            local if`n_ifs' = "(1) " //build the `if' string
            //iterate over distinct vars to build the `if' string
            foreach vv of varlist `distinct_vars' {
                //construct if statement (see macrotest.do)
                //later define local `vv'_cur = value of vv for current record
                //This *seems* to work...
                local cur_if "cond(missing(\``vv'_cur\'), 1, abs(`vv'-\``vv'_cur\')<=``vv'_rad')"

                local cur_disp = substr("`vv'",1,3)
                local cur_disp "`cur_disp' \``vv'_cur\'/``vv'_rad' "
//local age_don_cur "OO"
//disp `"`cur_if'"'
//local age_don_cur "PP"
//disp `"`cur_if'"'
//macval() keeps `age_don_cur' or whatever from being interpreted at this point

                //local if`n_ifs' "`if`n_ifs'' & `cur_if'" 
                local if`n_ifs' "`macval(if`n_ifs')' & `macval(cur_if)'" 
                local disp`n_ifs' "`macval(disp`n_ifs')' `macval(cur_disp)'" 
/*
local age_don_cur "OO"
disp `"`if`n_ifs''"'
local age_don_cur "PP"
disp `"`if`n_ifs''"'
*/
            }
        }
    }
    //DONE CONSTRUCTING IF STATEMENTS
//disp "total `n_ifs' if statements"

    //disp " original: `0'"

    if !inrange(`k', 1, 100) {
        disp in smcl as error "Error: k must be between 1 and 100" 
        exit
    }

    if "`without'" != "" {
        quietly count if `case' == 1
        local ncases = r(N)
        quietly count if `case' == 0
        local ncontrols = r(N)
        if ((`ncases' * `k') > `ncontrols') {
            disp as error in smcl ///
              "Error: controls must exceed k*cases if 'without' option is used" 
            exit
        }
    }

    quietly count if !inlist(`case', 0, 1)
    if r(N) > 0 {
        disp as error in smcl ///
            "Error: case variable(`case') must be 0 or 1 for all records"
        exit
    }
    quietly duplicates report `id'
    if r(N) != r(unique_value) {
        disp as error in smcl ///
            "Error: ID variable(`id') is not a unique identifier"
        exit
    }

    local NUMERIC_ID = 1
    local id_type: type `id'
    if substr("`id_type'", 1,3) == "str" {
        local NUMERIC_ID = 0
    }

    set seed `seed'

    //sort in random order
    tempvar rsort
    gen `rsort' = uniform()

    //to match c cases on v variables, Dorry creates c*v local macros
    //then drops the cases and works with only the controls

    quietly count if `case' == 1
    local ncases = r(N)
    quietly count if `case' == 0
    local ncontrols = r(N)

    //At this point we have `n_ifs' if statements to run for each record


    tempvar to_delete
    gen `to_delete' = 0  //used for "without" option

    //create c*v local macros which store all the data for the cases
    disp "Processing matching variables for cases..."
    gsort -`case' `rsort' //list cases first
    forvalues i = 1/`ncases' {
        local id_`i' = `id'[`i']
        foreach vv of varlist `distinct_vars' {
            local `vv'`i' = `vv'[`i']
        }
    }
    disp "Done."

    quietly keep if `case' == 0
    tempvar newcontrols alreadymatched
    quietly gen int `newcontrols' = 0 //mark whether a control matches the cur case
    quietly gen int `alreadymatched' = 0 //mark whether record has already been matched to cur case

    capture postclose postit
    postfile postit `id_type' (`id'_ctrl `id'_case) ///
        double `distinct_vars' maxedout matchnum ///
        `using', `replace'

    local step_size = 200
    if (`ncases' < 2000) {
        local step_size = ceil(`ncases'/10)
    }

    disp "Starting matching process for `ncases' cases..."
    //MAIN LOOP: iterate over the cases
    forvalues i=1/`ncases' {
        quietly replace `alreadymatched' = 0   //haven't matched to anybody yet
        local id_i `id_`i''
        local nc_total = 0  //how many controls have been matched to this case

        //if var is (e.g.) "age", we need to define "age_cur" = age for this record
        foreach vv of varlist `distinct_vars' {
            local `vv'_cur = ``vv'`i''
        }

        //iterate over the ifs; initialization string
        local if_i 1

        local remaining_matches = `k'   //how many MORE matches are required?
        //BEGIN ITERATION over each of the "if" strings that is used to expand the radius
        while `remaining_matches' > 0 & `if_i' <= `n_ifs' {

            quietly count if `if`if_i'' & `alreadymatched' == 0
            local nc_total = r(N)  

            if "`pedantic'" != "" {
             disp "id `id_i': `disp`if_i'': `nc_total' controls
               // disp "    `if`if_i''"
            }

            //if we identified at least one control...
            if `nc_total' > 0 {
                quietly replace `newcontrols' = (`if`if_i'') & `alreadymatched' == 0
                gsort -`newcontrols' `rsort'

                local new_matches = ///
                    cond(`nc_total' < `remaining_matches', `nc_total', `remaining_matches')
                forvalues j=1/`new_matches' {
                    local nc_num=floor(uniform()*`nc_total')+1
                    if `alreadymatched'[`nc_num'] == 1 {
                        local counter = 0
                        while `alreadymatched'[`nc_num'] == 1 & `counter' < 20 {
                            local nc_num=floor(uniform()*`nc_total')+1
                            local ++counter
                        }
                    }
                    if "`verbose'" != "" {
                        disp "#`i' of `ncases' id `id_i': " ///
                             "control `j' drawn from control #`nc_num' " ///
                             "id " `id'[`nc_num']
                    }
                    local post_str = ""
                    foreach vv of varlist `distinct_vars' {
                        local post_str = "`post_str' (``vv'_rad')"
                    }     //iterate over vars to construct post string

                    if `NUMERIC_ID' == 1 {
                        post postit (`id'[`nc_num']) (`id_i') `post_str' ///
                            (0) (`nc_total')   //(0) = not maxed out
                    }
                    else {
                        local mymatch `id'[`nc_num']
                        post postit (`mymatch') ("`id_i'") `post_str' ///
                            (0) (`nc_total')   //(0) = not maxed out
                    }

                    //if w/o replacement, mark this control for deletion
                    quietly replace `to_delete' = 1 in `nc_num'
                    quietly replace `alreadymatched' = 1 in `nc_num'
                    local --remaining_matches
                }  //loop over the new_matches controls to assign
                //if doing w/o replacement, delete any ctrls that have been used
                if "`without'" != "" {
                    quietly drop if `to_delete' == 1
                }
            }

            //move to next "if" statement
            if `remaining_matches' > 0 {
                local ++if_i
            }           //if we haven't identified enough matches yet
        }               //while no matches & keepgoing == 1
        //END ITERATING OVER "IF" STRINGS

        local maxedout = `remaining_matches' > 0

        if `remaining_matches' > 0 {          //if we FAILED to identify enough controls
            if "`verbose'" != "" {
                disp "#`i' of `ncases' id `id_i': " ///
                " failed to identify enough controls"
            }
            local post_str = ""
            foreach vv of varlist `distinct_vars' {
                local post_str = "`post_str' (``vv'_rad')"
            }     //iterate over vars to construct post string
            //post once for each non-match
            forvalues jj = 1/`remaining_matches' {
                if `NUMERIC_ID' == 1 {
                    post postit (.) (`id_i') `post_str' ///
                        (`maxedout') (`nc_total')
                }
                else {
                    post postit ("") ("`id_i'") `post_str' ///
                        (`maxedout') (`nc_total')
                }
            }
        }   //if we failed to identify enough controls
        if "`verbose'" == "" & mod(`i',`step_size') == 0 {
            disp "Finished `i' of `ncases' cases (" %3.1f `i'*100/`ncases'  "%)"
        }
    }                   //loop over each case

    postclose postit
end
