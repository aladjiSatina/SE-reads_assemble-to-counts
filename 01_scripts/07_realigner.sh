#!/bin/bash
# note these scripts are from Simple Fools Guide - Palumbi lab and slightly modified.

REFERENCE="05_trinity_output/sfontinalis_contigs.fasta"
SNP_FOLDER="08_callSNPs"
GATKjar="/project/lbernatchez/drobo/users/bensuth/programs/GenomeAnalysisTK-1.0-6150-g32730b1/GenomeAnalysisTK.jar"


###  Identify regions in need of realignment:
java -Xmx75g -jar $GATKjar \
  -T RealignerTargetCreator \
  -R $REFERENCE \
  -o $SNP_FOLDER/merged_output.intervals \
  -I $SNP_FOLDER/merged.bam \
  --minReadsAtLocus 3
  
#  defaults for optional parameters:
#  --minReadsAtLocus N [the minimum coverage at a locus for the entropy calculation to be enabled; default=4]
#  --windowSize N [any two SNP calls and/or high entropy positions are considered clustered when they occur no more than N basepairs apart; default=10]
#  --mismatchFraction f [fraction of total sum of base qualities at a position that need to mismatch for the position to be considered to have high entropy; default=0.15; to disable, set to <= 0 or > 1]
#  Note that this fraction should be adjusted based on your particular data set. For deep coverage and/or when looking for indels with low allele frequency, this number should be smaller.
#  --maxIntervalSize [max size in bp of intervals that we'll pass to the realigner; default=500]

#-------------------------------------------------------------------------

###  Run realigner over intervals:
java -Xmx75g -jar $GATKjar \
  -I $SNP_FOLDER/merged.bam \
  -R $REFERENCE \
  -T IndelRealigner \
  -targetIntervals ./08_callSNPs/merged_output.intervals \
  -o $SNP_FOLDER/merged_realigned.bam \
  -LOD 3.0 \
  --maxReadsInMemory 1000000 \
  --maxReadsForRealignment 100000

#Optional parameters:
# -compress 0 \
#    this argument recommended to speed up the process *if* this is only a temporary file; otherwise, use the default value
#    defaults for optional parameters:
# -compress, --bam_compression; Compression level to use for output bams; [default:5].
# -LOD, --LODThresholdForCleaning; LOD threshold above which the realigner will proceed to realign; default=5.0]
#    This term is equivalent to "significance" - i.e. is the improvement significant enough to merit realignment? Note that this number should be adjusted based on your particular data set. For low coverage and/or when looking for indels with low allele frequency, this number should be smaller.
# -targetNotSorted, --targetIntervalsAreNotSorted; This tool assumes that the target interval list is sorted; if the list turns out to be unsorted, it will throw an exception. Use this argument when your interval list is not sorted to instruct the Realigner to first sort it in memory.
# -knownsOnly, --useOnlyKnownIndels; Don't run 'Smith-Waterman' to generate alternate consenses; use only known indels provided as RODs for constructing the alternate references. 

#--------------------------------------------------------------------------

##### To view a region in sam format:
##### java -Xmx4g -jar ~/programs/GATK/dist/GenomeAnalysisTK.jar \  
##### -I merged_realigned.bam \
##### -R REFERENCE_ASSEMBLY_NAME.fasta \
##### -T PrintReads -L [contig name] > [file.txt]




