#!/usr/bin/env bash
# Extract data from NCBI BLAST Single-file JSON output using jq.
# Fredrik Boulund 2016

if [ $# -eq 0 ]                                 
then                                            
	echo "ERROR: No arguments supplied!"        
	echo "usage: ./script.sh <BLAST_RESULT.json>"
	exit 1                                      
fi                                              


JSON=$1

JQ_COMMAND=".BlastOutput2[].report | .results | {peptide: .search.hits[0].hsps[0].qseq, num_samples: .search.query_title, description: .search.hits[0].description[0].title, id: .search.hits[0].description[0].id}"

jq "$JQ_COMMAND" $JSON > best_matches.txt
