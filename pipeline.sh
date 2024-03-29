#!/bin/bash

#Download genome graph file and locate it in current direcoty




#Download the decoy genome reference
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37_decoy.fasta.gz
gunzip human_g1k_v37_decoy.fasta.gz


#install Docker before running the followed

sudo docker load --input docker-bpa-0.9.1.tar
sudo docker load --input docker-rasm-0.5.20.tar

#take the right id
sudo docker images

##########################################NOTE: change the directory (~ sign) to current directory which holds data!!!!!
sudo docker run -ti -v ~:/mountedcwd 38bda2551165

################### Docker container starts from wrong directory so go to root directory to have access to bin files:
cd ../..
################### READ MAPPING: needs reference FASTA, VCF graph (.vcf.gz!), two reads that are complimentary. The result .BAM file named sample1 will be saved in current repository.
./usr/local/bin/aligner --vcf ./mountedcwd/SBG.Graph.B37.V6.rc6.vcf.gz --reference ./mountedcwd/human_g1k_v37_decoy.fasta -q ./mountedcwd/example_human_Illumina.pe_1.fastq -Q ./mountedcwd/example_human_Illumina.pe_2.fastq -o ./mountedcwd/sample1.bam --read_group_sample 'SAMPLE_READ_GROUP' --read_group_library 'lib' --threads 4

################### MAke sure samtools and all dependin libraries are installed
################### Exit the container c+D
samtools sort sample.bam > sample.sort.bam
samtools index sample.sort.bam



################### Run variant caller docker
sudo docker run -ti -v ~:/mountedcwd 899444cb5a93
################### Do the variant calling > output VCF file is named sample2result.vcf
./usr/local/bin/reassembly_variant_caller -b ./mountedcwd/sample2.sort.bam -f ./mountedcwd/human_g1k_v37_decoy.fasta -g ./mountedcwd/SBG.Graph.B37.V6.rc6.vcf.gz -v ./mountedcwd/sample2results.vcf
