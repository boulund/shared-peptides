# Biomarker peptide identification
# Fredrik Boulund 2016
#
# Usage instructions:
# 1. Directory structure
#	./
#	./samples.txt
#   ./discpeps/
# 2. Download discriminative peptides for each sample into the discpeps folder
#    e.g. ./discpeps/<sample>.discriminative_peptides.txt for each sample. The
#    format should be the four column TCUP format for discriminative peptides.
# 3. Run this script!

SPECIES="Haemophilus influenzae"

NUM_SAMPLES=`wc -l samples.txt | awk '{print $1}'`
echo "Found $NUM_SAMPLES in samples.txt"

# Find all peptide names for discriminative peptides 
echo "Finding peptide names for discriminative peptides"
for f in `ls discpeps/*.txt`; do 
	grep "$SPECIES" $f | awk '{print $1, $2}' > ${f%.*}.dpeps; 
done

# Extract sequences for all unique peptides from discriminative peptide files
# This step discards duplicates.
echo "Extracting peptide sequences"
mkdir -p peps
for f in `ls discpeps/*.dpeps`; do 
	BASENAME=$(basename ${f%%.*}); 
	awk '{print $2}' $f | sort | uniq > peps/$BASENAME.peps;
done

# Find peptides present in all samples
echo "Finding peptides present in all samples"
setop.py --intersection peps/*.peps > shared_peptides.txt

# Count occurrences of all peptides and extract only those that are shared.
echo "Count occurrences of all peptides and extracting shared peptide counts"
cat peps/*.peps | sort | uniq -c | sort -n > peptide_counts.txt
grep -f shared_peptides.txt peptide_counts.txt | \
	awk -v num_samples=$NUM_SAMPLES '{if ($1>(num_samples-1)) print $1, $2}' > shared_peptide_counts.txt


echo "Count how many samples each peptide occurs in"
for peptide in `awk '{print $2}' peptide_counts.txt`; do 
	COUNT=`grep $peptide peps/*.peps | cut -f1 -d":" | sort | uniq | wc -l`
	echo -n "$COUNT " >> peptide_counts_all.txt
	echo "$peptide" >> peptide_counts_all.txt
done

