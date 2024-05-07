#!/usr/bin/bash -l
#SBATCH -p short -c 8 --mem 24gb --out Glomerobuild.%A.log

module load iqtree
module load muscle
module load mafft
module load samtools
module load clipkit
IN=../../../results/amptk/
TAX=Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt
DB=Mojave2020_KKelly202307.ASVs.otus.taxonomy.fa
samtools faidx $IN/$DB

for ASV in $(cat Glom_tip_labels_ASVs.tsv)
do
        sum=$(grep -P "^$ASV\t" $IN/Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt  | cut -f2-50 | perl -p -e '$sum = 0; for my $n ( split ) { $sum += $n }; $_ = "$sum\n"')
        samtools faidx $IN/$DB $ASV | perl -p -e "s/>(\S+)/>\$1.$sum/"
done >  Mojave2020.Glomero.fas

#Note, issue with first sequence appending, had to remove manually from Mojave2020.Glomero.fas

i=0
while IFS= read -r accession; do
    i=$((i+1))
    species_name=$(grep "$accession" maarjam_database_onlyITS.fasta | awk -F '|' '{print $5}' | tr ' ' '_')  # Replace spaces with underscores in the species name
    echo ">${species_name}_${i}"  # Add a number to the end of the species name
    samtools faidx maarjam_database_onlyITS.fasta "$accession" | perl -p -e "s/>(\S+)//"
done < top_hits_filtered.tsv > Mojave2020.Glomero.maarjam.fas


cat Mojave2020.Glomero.maarjam.fas >> Mojave2020.Glomero.fas
#add curated type species to the tree along with best blast hits
cat glomlib.txt >> Mojave2020.Glomero.fas
mafft Mojave2020.Glomero.fas > Mojave2020.Glomero.fasaln
#muscle -align Mojave2020.Glomero.fas -output Mojave2020.Glomero.muscle.fasaln
clipkit Mojave2020.Glomero.fasaln
#clipkit Mojave2020.Glomero.muscle.fasaln
iqtree2 -nt AUTO -s Mojave2020.Glomero.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
#iqtree2 -nt AUTO -s Mojave2020.Glomero.muscle.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP

