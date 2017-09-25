# Find shared peptides (i.e. potential biomarkers) between MSMS runs
This README file is a very basic and barebones instruction, mostly intended 
for private use.

# Installation
These scripts rely on the output of some external software:

- [TCUP](https://tcup.readthedocs.org) for lists of peptides in each sample/run
- [setop.py](https://github.com/pombredanne/setop) for basic set operations on plain text files
- [blastp](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) for BLASTP search against NR
- [jq](https://stedolan.github.io/jq/) for JSON processing

# Usage
Usage instructions:

 1. Before you begin, in an empty folder, create a directory structure to hold
    the input files: `mkdir -p discpeps peps fasta`. You also need to create a
    simple one-column text file called `samples.txt` that contains the sample
    names.
 2. Download all discriminative peptides for each sample into the `discpeps`
    folder e.g. `./discpeps/<sample>.discriminative_peptides.txt`. The format
    should be the four column TCUP format for discriminative peptides. Also
    download the FASTA files for each sample into `./fasta/<sample>.fasta`.
 3. Edit the `SPECIES` variable at the top of `bash_script.sh`.
 4. Run `bash_script.sh`. This will find all peptides that are shared between 
    samples/runs. This script produces a lot of files. The most important output
    here is the BLASTP results in JSON format (`peptide_counts_all.fasta.json`).
 5. Run the jq command in `extract_from_blast_json.sh` to produce the 
    `best_matches.txt` output file.
 6. Concatenate all FASTA files in the `fasta` directory, i.e. 
    `cat fasta/* > fasta/all.fasta`.
 7. Run `merge_blast_best_hists_and_mz_values_fasta.py`, giving it the `best_matches.txt`
    and `fasta/all.fasta` as input. It will then produce a list of potential 
    biomarker peptides, annotated by best BLASTP hit to NR and the number of 
    the input samples/runs that contained the peptide.

