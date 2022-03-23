#!/usr/bin/env bash

# This script stores a number of shared functions that can be used across CI/CD jobs.
# Special care should be taken to treat these functions as interfaces and maintain compatibility with 
# input/output once established and adopted, even if the internal logic changes.
#
# All functions input and output should be documented to help aid in easy adoption.
#
# No constants should be defined in this file. Each functiona should be fully self
# contained, and should document what constants it expects to be set

################################################################################
#### Functions #################################################################
################################################################################

# twr::logger() provides a standard logging framework to use for various logging scopes
# arg1: log type. One of "heading", "sub-heading", "info", "warn", "error", "debug", "pass", or "fail"
# arg2: message. What message you want to be logged. Should be a string.
function twr::logger() {

    local type="${1}"
    local message="${2}"
    local datetime
    
    datetime="$(date '+%F %T')"

    case "${type}" in
        heading)
            echo
            echo "##########################################################################"
            echo "${message}"
            echo "##########################################################################"
            echo
            ;;
        sub-heading)
            echo
            echo "**************************************************************************"
            echo "${message}"
            echo "**************************************************************************"
            echo
            ;;
        info)
            echo
            echo "# [${datetime}] - INFO: ${message} ########"
            echo
            ;;
        warn)
            echo
            echo "# [${datetime}] - WARN: ${message} ########"
            echo
            ;;
        error)
            echo
            echo "# [${datetime}] - ERROR: ${message} ########"
            echo
            ;;
        debug)
            echo
            echo "# [${datetime}] - DEBUG: ${message} ########"
            echo
            ;;
        debug-ml)
            # Use this for multi-line debug output
            echo
            echo "# [${datetime}] - DEBUG:"
            echo
            echo "${message}"
            echo
            echo "########"
            echo
            ;;
        pass)
            echo
            echo "# [${datetime}] - PASS: ${message} ########"
            echo
            ;;
        fail)
            echo
            echo "# [${datetime}] - FAIL: ${message} ########"
            echo
            ;;
        *)
            echo
            ;;
    esac

}