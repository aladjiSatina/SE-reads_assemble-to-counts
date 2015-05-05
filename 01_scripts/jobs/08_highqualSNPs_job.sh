#!/bin/bash
#$ -N detectvar
#$ -M $MY_EMAIL_ADDRESS
#$ -m beas
#$ -pe smp 10
#$ -l h_vmem=100G
#$ -l h_rt=48:00:00
#$ -cwd
#$ -S /bin/bash

time ./01_scripts/08_highqualSNPs.sh

