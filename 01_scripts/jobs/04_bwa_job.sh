#!/bin/bash
#$ -N bwa 
#$ -M bensutherland7@gmail.com
#$ -m beas
#$ -pe smp 10
#$ -l h_vmem=100G
#$ -l h_rt=100:00:00
#$ -cwd
#$ -S /bin/bash

time ./01_scripts/04_BWAaln.sh
