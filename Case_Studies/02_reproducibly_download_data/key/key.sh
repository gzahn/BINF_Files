#!/bin/bash
set -euxo pipefail

echo "Downloading the NCBI datasets tool first..."

# Case Study 2: Reproducible data retrieval

# This will use the datasets tool from NCBI and the fasta_formatter
# Part of FASTX Toolkit 0.0.14 by assafgordon@gmail.com

# Download datasets tool into Case Study 2 directory (not putting it in $PATH for now)
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets'

# Change permissions to allow execution
chmod +x datasets

# Check version and save record in a file
echo "Data acquired using the NCBI datasets tool, version" >> documentation.txt
./datasets version >> documentation.txt

# Record download date in same file
echo "Data were downloaded $(date)" >> documentation.txt

# Use datasets tool to retrieve sars-cov-2 genome "refseq"
./datasets download virus genome taxon sars-cov-2 --refseq --filename "refseq.zip"

# Download complete genome seq(s) uploaded after 01/08/2021
./datasets download virus genome taxon sars-cov-2 --released-since 01/08/2021 --filename "newer.zip" --complete-only

# Store these two datasets in their own directories
mkdir newer; mkdir refseq
mv refseq.zip refseq/; mv newer.zip newer/

# Unzip retrieved archives
cd ./refseq/; unzip refseq.zip; cd ..
cd ./newer/; unzip newer.zip; cd ..


##########################################################################################################


### REFSEQ - find surface glycoprotein seqs (AA and DNA) and save to files in main directory ###

# Retrieve animo acid sequence for "surface glycoprotein" | get AA seq onto 1 line first
fasta_formatter -i ./refseq/ncbi_dataset/data/protein.faa | grep -A 1 "surface glycoprotein" > ./refseq.faa

# Retrieve nucleotide sequence for "surface glycoprotein" | get fasta onto 1 line first
fasta_formatter -i ./refseq/ncbi_dataset/data/cds.fna | grep -A 1 "surface glycoprotein" > ./refseq.fna



### NEWER STRAIN(S) - find surface glycoprotein seqs (AA and DNA) and save to files in main directory ###

# Retrieve animo acid sequence for "surface glycoprotein" | get AA seq onto 1 line first
fasta_formatter -i ./newer/ncbi_dataset/data/protein.faa | grep -A 1 "surface glycoprotein" > ./newer.faa

# Retrieve nucleotide sequence for "surface glycoprotein" | get fasta onto 1 line first
fasta_formatter -i ./newer/ncbi_dataset/data/cds.fna | grep -A 1 "surface glycoprotein" > ./newer.fna


# Count strains and unique surface glycoprotein genotypes
echo "Parsed Surface Glycoprotein DNA and AA sequences for $(grep -c "^>" newer.fna) sars-cov-2 strains" >> documentation.txt
echo "comprised of $(cat newer.fna | grep -v "^>" | grep -v "^-" | sort | uniq | wc -l) unique DNA variants" >> documentation.txt



# bundle for sharing
zip sars_cov2_Surface_Glycoprotein_Sequences refseq.faa refseq.fna newer.faa newer.fna documentation.txt




## Output

# surface glycoprotein amino acid sequence
#>YP_009724397.2:1-419 nucleocapsid phosphoprotein [organism=Severe acute respiratory syndrome coronavirus 2] [isolate=Wuhan-Hu-1]
#MSDNGPQNQRNAPRITFGGPSDSTGSNQNGERSGARSKQRRPQGLPNNTASWFTALTQHGKEDLKFPRGQGVPINTNSSPDDQIGYYRRATRRIRGGDGKMKDLSPRWYFYYLGTGPEAGLPYGANKDGIIWVATEGALNTPKDHIGTRNPANNAAIVLQLPQGTTLPKGFYAEGSRGGSQASSRSSSRSRNSSRNSTPGSSRGTSPARMAGNGGDAALALLLLDRLNQLESKMSGKGQQQQGQTVTKKSAAEASKKPRQKRTATKAYNVTQAFGRRGPEQTQGNFGDQELIRQGTDYKHWPQIAQFAPSASAFFGMSRIGMEVTPSGTWLTYTGAIKLDDKDPNFKDQVILLNKHIDAYKTFPPTEPKKDKKKKADETQALPQRQKKQQTVTLLPAADLDDFSKQLQQSMSSADSTQA


# surface glycoprotein nucleotide sequence
#>NC_045512.2:28274-29533 nucleocapsid phosphoprotein [organism=Severe acute respiratory syndrome coronavirus 2] [isolate=Wuhan-Hu-1]
#ATGTCTGATAATGGACCCCAAAATCAGCGAAATGCACCCCGCATTACGTTTGGTGGACCCTCAGATTCAACTGGCAGTAACCAGAATGGAGAACGCAGTGGGGCGCGATCAAAACAACGTCGGCCCCAAGGTTTACCCAATAATACTGCGTCTTGGTTCACCGCTCTCACTCAACATGGCAAGGAAGACCTTAAATTCCCTCGAGGACAAGGCGTTCCAATTAACACCAATAGCAGTCCAGATGACCAAATTGGCTACTACCGAAGAGCTACCAGACGAATTCGTGGTGGTGACGGTAAAATGAAAGATCTCAGTCCAAGATGGTATTTCTACTACCTAGGAACTGGGCCAGAAGCTGGACTTCCCTATGGTGCTAACAAAGACGGCATCATATGGGTTGCAACTGAGGGAGCCTTGAATACACCAAAAGATCACATTGGCACCCGCAATCCTGCTAACAATGCTGCAATCGTGCTACAACTTCCTCAAGGAACAACATTGCCAAAAGGCTTCTACGCAGAAGGGAGCAGAGGCGGCAGTCAAGCCTCTTCTCGTTCCTCATCACGTAGTCGCAACAGTTCAAGAAATTCAACTCCAGGCAGCAGTAGGGGAACTTCTCCTGCTAGAATGGCTGGCAATGGCGGTGATGCTGCTCTTGCTTTGCTGCTGCTTGACAGATTGAACCAGCTTGAGAGCAAAATGTCTGGTAAAGGCCAACAACAACAAGGCCAAACTGTCACTAAGAAATCTGCTGCTGAGGCTTCTAAGAAGCCTCGGCAAAAACGTACTGCCACTAAAGCATACAATGTAACACAAGCTTTCGGCAGACGTGGTCCAGAACAAACCCAAGGAAATTTTGGGGACCAGGAACTAATCAGACAAGGAACTGATTACAAACATTGGCCGCAAATTGCACAATTTGCCCCCAGCGCTTCAGCGTTCTTCGGAATGTCGCGCATTGGCATGGAAGTCACACCTTCGGGAACGTGGTTGACCTACACAGGTGCCATCAAATTGGATGACAAAGATCCAAATTTCAAAGATCAAGTCATTTTGCTGAATAAGCATATTGACGCATACAAAACATTCCCACCAACAGAGCCTAAAAAGGACAAAAAGAAGAAGGCTGATGAAACTCAAGCCTTACCGCAGAGACAGAAGAAACAGCAAACTGTGACTCTTCTTCCTGCTGCAGATTTGGATGATTTCTCCAAACAATTGCAACAATCCATGAGCAGTGCTGACTCAACTCAGGCCTAA


