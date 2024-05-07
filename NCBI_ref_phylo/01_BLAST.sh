#!/usr/bin/bash -l
#SBATCH -p short --nodes 1 --ntasks 4 --mem 2G --job-name=BLASTN
#SBATCH --output=blastn.%A.log

module load ncbi-blast/2.9.0+

#Meant to be run with a file ASVs containing tips names subsetted from phyloseq pipeline (usually ASVs)


CPUS=$SLURM_CPUS_ON_NODE
if [ ! $CPUS ]; then
    CPUS=1
fi
if [ ! -f  maarjam_database_onlyITS.fasta.nhr ]; then
  makeblastdb -in maarjam_database_onlyITS.fasta -dbtype nucl
fi
if [ ! -f  ASV.vs.Maarjam.BLASTN.tab ]; then
blastn -query ASVs.fas -db maarjam_database_onlyITS.fasta \
-evalue 1e-5 -outfmt 6 -out ASV.vs.Maarjam.BLASTN.tab -num_threads $CPUS      
fi
export LANG=C; export LC_ALL=C; sort -k1,1 -k12,12gr -k11,11g -k3,3gr ASV.vs.Maarjam.BLASTN.tab | sort -u -k1,1 --merge > bestHits.Maarjam.BLASTN.tab

#modify file and select top hits using an R script
Rscript BLAST_process.R