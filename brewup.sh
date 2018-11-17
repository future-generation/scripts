#!/bin/bash
brew=$(which brew)
logfile="$HOME/Library/Logs/brewup.log"
echo "Log @ $logfile"
date | tee -a $logfile
$brew update | tee -a $logfile
$brew upgrade | tee -a $logfile
$brew cleanup -s 2>&1 | tee -a $logfile
rm -rf $($brew --cache)
echo ""