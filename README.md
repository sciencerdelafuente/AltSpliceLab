# AltSpliceLab

# Data Download
We downloaded the `assembly_summary_refseq.txt` file from:
> https://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/

This file contains metadata for all genome assemblies annotated by NCBI RefSeq. Additional references:
- [GenBank Summary](https://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_genbank.txt)
- [RefSeq Eukaryotic Annotation Pipeline](https://www.ncbi.nlm.nih.gov/refseq/annotation_euk/all/)
- [Genome FTP Docs](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/policies-annotation/genomeftp/)

# Filtering and Classification 
- Filters species by three conditions: **assembly level** (chromosome or complete genome), **annotation provider** (NCBI RefSeq), and **taxonomic group**.
- Classifies eukaryotic species into: `Mammals`, `Birds`, `Plants`, `Fish`, and `Arthropods`.

Filtering was performed using the 'Filtering.ipynb' script, executed in Jupyter Notebook version 6.4.12 with Python 3. The script parses the RefSeq assembly summary file 'assembly_summary_refseq.csv' provided by NCBI and applies a set of predefined criteria to select relevant eukaryotic genomes. Specifically, it filters assemblies by their level of completeness (e.g., chromosome or complete genome), by annotation provider (only retaining those annotated by NCBI RefSeq), and by taxonomic group (focusing on multicellular eukaryotes, including mammals, birds, fish, arthropods, and plants). The output includes curated genome metadata, species lists, and taxonomic classifications, which are used for downstream analyses.

**Key outputs:**
- `Refseq_Eukaryotes.csv`

#Download of data
We then downloaded the annotation files and all available metadata reports for the species listed in 'Refseq_Eukaryotes.csv'.


# Genomic Variable Analysis
Using `refseqGenomeAnalysis.cpp`, annotation files for each species were processed to extract genome size, gene and coding content, and alternative splicing ratio.

**Inputs:**
- Annotation files for species listed in `Refseq_Eukaryotes.csv`

**Outputs:**
- `Output_Genome_Variables_Eukaryotes.txt`

 Test: 
 
   > g++ refseqGenomeAnalysis.cpp -o o

   > ./o GCF_004115265.1_mRhiFer1_v1.p_genomic.gff 


 Output: Creates an Output file with the following information:
 
         > #GCF_004115265.1_mRhiFer1_v1.p_genomic.gff
         
         > Genome Size: 2075768562
         
         > Coding Size: 33885542
         
         > Gene Size: 984758131
         
         > ALternative Splicing Ratio: 2.953
         
         
         
         
         
#Download Metadata
We investigated potential annotation biases in multicellular eukaryotes by collecting detailed metadata associated with each genome in our filtered dataset (Refseq_Eukaryotes.csv).

For this purpose, we downloaded two sets of files for each species:

- The .xml files provided by NCBI contain structured metadata for each genome assembly, including information on the submitting organization, assembly statistics, and sequencing strategy. These files were retrieved from the NCBI FTP server as part of the official genome assembly metadata resources.

- Assembly statistics reports (GCF_..._assembly_stats.txt)


#Metadata extraction and processing from NCBI annotation reports
This script 'MetadataExtraction.ipynb' parses metadata from NCBI RefSeq XML and assembly report files associated with annotated eukaryotic genomes. Using Python (with pandas, xml.etree.ElementTree, and other libraries), it processes two input datasets: a list of XML files (File_names.csv) and a list of assembly report files. For each species, the script extracts key annotation statistics—such as gene counts, isoform classifications, structural feature lengths, and transcript/protein alignment statistics (including RNA-seq support and tissue diversity). It also retrieves assembly-level metrics such as N50 values, scaffold/contig counts, and GC content. The output consists of two tab-delimited tables (Metadata.csv and Metadata_Assembly.csv) that summarize annotation quality, expression support, and genome assembly features, which are later used for downstream comparative analyses.

**Outputs:**
- Metadata.csv: extracted information from .xml metadata files.

- Metadata_Assembly.csv: parsed assembly-level statistics for each genome.



#Integration of genome variables
This step integrates information from:

**Inputs:**
- Refseq_Eukaryotes.csv

- Metadata.csv

- Metadata_Assembly.csv

- Output_Genome_Variables_Eukaryotes.txt

The resulting consolidated file is:

**Outputs:**
- Analisis_Metadata.csv: contains the final variables selected for the comparative analysis of genome annotations across eukaryotic species.

The script 'IntegrationData.ipynb' merges multiple sources of metadata into a unified dataset containing genome-wide annotation and assembly statistics for eukaryotic species. It reads in four previously generated files (Metadata.csv, Metadata_Assembly.csv, Output_Genome_Variables.csv, and Refseq_Eukaryotes.csv) and links them by matching assembly accession identifiers. The script enriches the core dataset with gene counts, CDS statistics, isoform support categories, length distributions of genic features, and protein/transcript alignment metrics. It also incorporates assembly quality metrics such as scaffold and contig counts, N50 values, GC content, and RNA-seq support metadata. When necessary, alternative matching strategies (e.g., by organism name) are used to avoid missing data. The final dataset is exported as Analisis_Metadata.csv, serving as a comprehensive matrix of genome, annotation, and transcriptomic attributes across hundreds of eukaryotic genomes for downstream statistical analyses.



# Normalized Alternative Splicing Ratio
We computed in Rstudio (R version 4.3.3) the normalized alternative splicing ratio (ASR*) for each genome. This adjustment accounts for differences in annotation quality, particularly the proportion of fully supported coding sequences (CDSs), which was found to strongly influence raw ASR estimates.

**Inputs:**
- Analisis_Metadata.csv

**Outputs:**
- data_normalized.csv




#Annotation of predicted and normalized ASR values
The script 'AnnotationASRvalues.ipynb' links the predicted and normalized values of the Alternative Splicing Ratio (ASR) to the annotated genomes from the 'Output_Genome_Variables_Eukaryotes.txt' dataset. It loads the predicted (ASR_predicho) and normalized (ASR_normalizado_resta_min) ASR values from 'data_normalized.csv', and assigns them to each genome in 'Output_Genome_Variables_Eukaryotes.txt' by matching the original ASR value. It then annotates each genome with its corresponding taxonomy group and species name by matching the assembly accession against the reference list in Refseq_Eukaryotes.csv. Entries for which a predicted ASR could not be matched are removed. The resulting table, saved as 'Output_Genome_Variables_Eukaryotes_Normalized.csv', contains predicted and normalized ASR estimates alongside full taxonomic metadata, and serves as the input for downstream comparative analyses.

         
# External Resources

- **NCBI RefSeq**: https://www.ncbi.nlm.nih.gov/refseq/
- **Genome Assembly Reports**: https://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/
- **RefSeq Annotation Pipeline**: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/policies-annotation/genomeftp/
- **Common Tree (NCBI) + iTOL visualization**: https://itol.embl.de






