#!/bin/bash
#$ -N REFprep
#$ -M $MY_EMAIL_ADDRESS
#$ -m beas
#$ -pe smp 3
#$ -l h_vmem=100G
#$ -l h_rt=12:00:00
#$ -cwd
#$ -S /bin/bash

time ./01_scripts/11b_GXlevels-HTseq.sh

