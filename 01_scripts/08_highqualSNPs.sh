#!/bin/bash
REFERENCE="05_trinity_output/sfontinalis_contigs.fasta"
SNP_FOLDER="08_callSNPs"
GATKjar="/project/lbernatchez/drobo/users/bensuth/programs/GenomeAnalysisTK-1.0-6150-g32730b1/GenomeAnalysisTK.jar"

### Call SNPs with unified genotyper:
java -Xmx75g -jar $GATKjar \
	-R $REFERENCE -T UnifiedGenotyper \
	-I $SNP_FOLDER/merged_realigned.bam -o $SNP_FOLDER/rawSNPS_Q30.vcf \
	-gt_mode DISCOVERY \
	-stand_call_conf 30 -stand_emit_conf 10
	
#Selecting an appropriate quality score threshold (from the Broad Institute's Wiki site):
#A common question is the confidence score threshold to use for variant detection. We recommend:
#Deep (> 10x coverage per sample) data 
#    we recommend a minimum confidence score threshold of Q30 with an emission threshold of Q10. These Q10-Q30 calls will be emitted filtered out as LowQual. 
#Shallow (< 10x coverage per sample) data 
#    because variants have by necessity lower quality with shallower coverage, we recommend a min. confidence score of Q4 and an emission threshold of Q3. 


# Annotate variants:
java -Xmx75g -jar $GATKjar \
  -T VariantAnnotator \
  -l INFO \
  -R $REFERENCE \
  -I $SNP_FOLDER/merged_realigned.bam \
  -o $SNP_FOLDER/rawSNPS_Q30_annotated.vcf \
  -B:variant,VCF $SNP_FOLDER/rawSNPS_Q30.vcf \
  --useAllAnnotations

# Calling InDels (needed for filtering around InDels):
java -Xmx75g -jar $GATKjar \
	-R $REFERENCE -T UnifiedGenotyper \
	-I $SNP_FOLDER/merged_realigned.bam -o $SNP_FOLDER/InDels_Q30.vcf \
	-gt_mode DISCOVERY \
	-glm INDEL \
	-stand_call_conf 30 -stand_emit_conf 10

# Filtering around InDels:
java -Xmx75g -jar $GATKjar \
  -T VariantFiltration \
  -R $REFERENCE \
  -B:mask,VCF $SNP_FOLDER/InDels_Q30.vcf \
  -B:variant,VCF $SNP_FOLDER/rawSNPS_Q30_annotated.vcf \
  -o $SNP_FOLDER/Indel_filtered_Q30.vcf
  
# Additional filtering:
java -Xmx75g -jar $GATKjar \
  -T VariantFiltration \
  -R $REFERENCE \
  -B:variant,VCF $SNP_FOLDER/Indel_filtered_Q30.vcf \
  -o $SNP_FOLDER/analysis_ready_Q30.vcf \
  --clusterWindowSize 10 \
  --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
  --filterName "HARD_TO_VALIDATE" \
  --filterExpression "SB >= -1.0" \
  --filterName "StrandBiasFilter" \
  --filterExpression "QUAL < 10" \
  --filterName "QualFilter" \
  --filterExpression "QUAL < 30.0 || QD < 5.0 || HRun > 5 || SB > -0.10" \
  --filterName GATKStandard
   
# Finally, to save only the header and all SNPS that have passed all the filters in a new file that can be used as a truth training set for the VQSR:  
cat $SNP_FOLDER/analysis_ready_Q30.vcf | grep 'PASS\|^#' > $SNP_FOLDER/highQualSNPS.vcf
