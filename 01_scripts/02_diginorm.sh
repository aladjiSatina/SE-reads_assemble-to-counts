#!/bin/bash
# Normalizing by coverage with 'normalize_by_kmer_coverage.pl' from Trinity

#### FIRST SET THE FILES YOU WANT TO USE FOR ASSEMBLY OF REFERENCE ###
# only add the sample name, as below it will be assumed that the file can be found within the $TRIMMED_FOLDER
sample1="example1"
sample2="example2"
sample3="example3"
# add as many as necessary

# point to insilico_read_normalization.pl
NORMALIZE_PROGRAM="/prg/trinityrnaseq/trinityrnaseq_r20140717/util/insilico_read_normalization.pl"

# Global variables
TRIMMED_FOLDER="03_trimmed"
NORMALIZED_FOLDER="04_normalized"

# Copy samples of interest to normalized folder, add $TRIMMED_FOLDER/$sample2 as many as necessary
cp $TRIMMED_FOLDER/$sample1 $TRIMMED_FOLDER/$sample2 $NORMALIZED_FOLDER/



# Digital normalization of samples of interest
ls -1 $NORMALIZED_FOLDER/*trimmed.fastq.gz | \
        perl -pe 's/\.gz//' | \
    sort -u | \
    while read i
    do
        echo 
        echo ">>> Treating $i:"
        echo "-----------------------------------------------------"
        echo "$i"
        echo "-----------------------------------------------------"
        echo 

        # Decompressing reads
        echo "Decompressing reads"
        gunzip -c "$i".gz > "$i"

        $NORMALIZE_PROGRAM \
            --seqType fq \
            --JM 75G \
            --max_cov 50 \
            --single "$i" \
            --output $NORMALIZED_FOLDER \
            --CPU 10

        # Removing decompressed reads
        echo "Removing decompressed reads"
        rm "$i"
    done

# Remove temporary 'ok', 'left', and 'right' links
rm $NORMALIZED_FOLDER/*.fq.ok

# Remove copied trimmed files
rm $NORMALIZED_FOLDER/*trimmed.fastq.gz

# Compress normalized files
echo "Compressing normalized files"
gzip $NORMALIZED_FOLDER/*.fq

# Concatenate all files for Trinity
echo "Concatenating all normalized files for Trinity"
cat $NORMALIZED_FOLDER/*.fq.gz > $NORMALIZED_FOLDER/norm_libs_for_trinity.fq.gz
