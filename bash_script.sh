# Biomarker peptide identification
# Fredrik Boulund 2015-2017

SPECIES="Staphylococcus aureus"

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


if [ -e peptide_counts_all.txt ]
then
	echo "WARNING: removing existing peptide_counts_all.txt in 5 seconds"
	sleep 5
	rm -fv peptide_counts_all.txt
fi

echo "Count how many samples each peptide occurs in"
for peptide in `awk '{print $2}' peptide_counts.txt`; do 
	COUNT=`grep $peptide peps/*.peps | cut -f1 -d":" | sort | uniq | wc -l`
	echo -n "$COUNT " >> peptide_counts_all.txt
	echo "$peptide" >> peptide_counts_all.txt
done

# Perform BLAST search to retrieve most likely source and short description of each peptide
sed 's/^/>/' peptide_counts_all.txt | sed 's/ /\n/' > peptide_counts_all.fasta
# Requires blast+ 2.3.0 or greater
blastp \
	-db /shared/genbank/nr/2015-11-11/nr \
	-query peptide_counts_all.fasta \
	-out peptide_counts_all.fasta.json \
	-outfmt 15 \
	-num_threads 10 \
	-evalue 20000 \
	-word_size 2 \
	-gapopen 9 \
	-gapextend 1 \
	-matrix PAM30 \
	-threshold 11 \
	-comp_based_stats 0 
