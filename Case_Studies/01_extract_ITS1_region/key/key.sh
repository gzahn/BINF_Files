#!/bin/bash
set -euxo pipefail

# Case Study 1

# Run ITS1 on all samples in ./data/
# all subsequent commands take place in that directory!

# STEP 1: extract fastqs from zip archive
unzip ITS_Reads.zip

# STEP 2: uncompress individual files (bigger, but makes it easier to look inside for later steps)
gunzip DNA*.fastq.gz

# STEP 3: Run ITSxpress on all files, keeping separate names for log and output files
for i in *.fastq; do itsxpress --fastq $i --single_end --outfile $i.ITS1 --log $i.log --taxa All --threads 4 --region ITS1;done

# STEP 4: Make report of input seqs, passing seqs, and timelapse for each file

# create separate tmp files for each field
# filenames:    for i in *.log; do grep "Reading file" $i | cut -d " " -f 3; done > tmp1
# seqs in:      for i in *.log; do grep "nt in" $i | cut -d " " -f 4; done > tmp2
# seqs out:     for i in *.ITS1; do fastq_to_fasta -i $i | grep -c "^>"; done > tmp3

for i in *.log; do grep "Reading file" $i | cut -d " " -f 3; done > tmp1
for i in *.log; do grep "nt in" $i | cut -d " " -f 4; done > tmp2
for i in *.ITS1; do fastq_to_fasta -i $i | grep -c "^>"; done > tmp3
for i in *.log; do grep "ITSxpress ran in" $i | sed 's/ITSxpress ran in /_/' | cut -d "_" -f 2; done > tmp4


# Build file header and add above pasted tmp fields:

paste <(echo "Filename") <(echo "Seqs in") <(echo "Seqs out") <(echo "Elapsed time") > tmp_header

cat tmp_header <(paste tmp1 tmp2 tmp3 tmp4) > summary_output_per_file.tsv

# clean up temp files
rm tmp*

# summary_output_per_file.tsv should be machine-readable
