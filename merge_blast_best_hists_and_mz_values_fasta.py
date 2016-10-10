#!/usr/bin/env python3.5
# Fredrik Boulund 2016
# Merge Blast best hits (from jq json output) with peptide fasta.

from sys import argv, exit

if len(argv) < 2:
    print("usage: script.py blast_best_hits.txt peptides.fasta")
    exit()


def peptide_dict(filename):
    peptides = {}
    with open(filename) as f:
        header_line = ""
        for line in f:
            if line.startswith(">"):
                header_line = line
            else:
                peptides[line.strip()] = header_line.rstrip()[1:]
    return peptides



def insert_z_mh(filename, peptides):
    with open(filename) as f:
        for line in f:
            if "peptide" in line:
                peptide = line.split(":")[1].strip('",\n ')
                print(line.rstrip())
                print('  "peptide_info": "{}",'.format(peptides[peptide]))
            else:
                print(line.rstrip())

if __name__ == "__main__":
    best_hits, peptides_fasta = argv[1:3]
    peptides = peptide_dict(peptides_fasta)
    insert_z_mh(best_hits, peptides)
