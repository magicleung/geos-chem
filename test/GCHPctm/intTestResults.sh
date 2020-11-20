#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: intTestResults.sh
#
# !DESCRIPTION: Displays results from the execution phase of the
#  GCHPctm integration tests.
#\\
#\\
# !CALLING SEQUENCE:
#  sbatch intTestResults.sh
#
# !REVISION HISTORY:
#  03 Nov 2020 - R. Yantosca - Initial version
#  See the subsequent Git history with the gitk browser!
#EOP
#------------------------------------------------------------------------------
#BOC

#============================================================================
# Variable and function definitions
#============================================================================

# Get the long path of this folder
root=$(pwd -P)

# Load common functions for tests
. ${root}/commonFunctionsForTests.sh

# Count the number of tests to be done = 1
# (We don't have to recompile GCHP to change resolutions)
numTests=$(ls -1 ${root}/logs/execute* | wc -l)

# Results logfile name
results="${root}/logs/results.execute.log"
rm -f ${results}

#============================================================================
# Initialize results logfile
#============================================================================

# Print header to results log file
print_to_log "${SEP_MAJOR}"                             ${results}
print_to_log "GCHPctm: Execution Test Results"          ${results}
print_to_log ""                                         ${results}
print_to_log "Number of execution tests: ${numTests}"   ${results}
print_to_log "${SEP_MAJOR}"                             ${results}

#============================================================================
# Configure and compile code in each GEOS_Chem run directory
#============================================================================
print_to_log " "                ${results}
print_to_log "Execution tests:" ${results}
print_to_log "${SEP_MINOR}"     ${results}

# Change to the top-level build directory
cd ${root}

# Keep track of the number of tests that passed & failed
let passed=0
let failed=0
let remain=${numTests}

# Loop over all of the execution logs
for path in logs/execute*; do

    # Get the run directory name from the path
    file=$(basename ${path})
    runDir="${file%.*}"
    runDir="${runDir#*.}"
    
    # Create sucess and failure messages
    passMsg="$runDir${FILL:${#runDir}}.....${EXE_PASS_STR}"
    failMsg="$runDir${FILL:${#runDir}}.....${EXE_FAIL_STR}"

    # Look for the text ----EXTDATA, which shows up
    # at the end of a successful GCHPctm job
    grep -e ----EXTDATA ${path} > /dev/null
    if [[ $? -eq 0 ]]; then
        let passed++
	print_to_log "${passMsg}" ${results}
    else
    	let failed++
	print_to_log "${failMsg}" ${results}

    fi
    let remain--

done

#============================================================================
# Check the number of simulations that have passed
#============================================================================

# Print summary to log
print_to_log " "                                          ${results}
print_to_log "Summary of execution test results:"         ${results}
print_to_log "${SEP_MINOR}"                               ${results}
print_to_log "Execution tests passed:        ${passed}"   ${results}
print_to_log "Execution tests failed:        ${failed}"   ${results}
print_to_log "Execution tests not completed: ${remain}"   ${results}

# Check if all tests passed
if [[ "x${passed}" == "x${numTests}" ]]; then
    print_to_log ""                                      ${results}
    print_to_log "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" ${results}
    print_to_log "%%%  All execution tests passed!  %%%" ${results}
    print_to_log "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" ${results}
fi

#============================================================================
# Cleanup and quit
#============================================================================

# Free local variables
unset failed
unset file
unset runDir
unset log
unset numTests
unset options
unset passed
unset path
unset remain
unset results
unset root

# Free imported variables
unset FILL
unset SEP_MAJOR
unset SEP_MINOR
unset SED_INPUT_GEOS_1
unset SED_INPUT_GEOS_2
unset SED_HISTORY_RC
unset CMP_PASS_STR
unset CMP_FAIL_STR
unset EXE_PASS_STR
unset EXE_FAIL_STR
#EOC
