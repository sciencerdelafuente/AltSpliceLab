#!/bin/bash
#SBATCH --job-name=rnaseq_pipeline
#SBATCH --cpus-per-task=12
#SBATCH --mem=48G
#SBATCH --time=7-00:00:00
#SBATCH --qos=medium
#SBATCH --output=rnaseq_%j.out

threads=12

if [ $(($# % 2)) -ne 0 ]; then
  echo "Número de argumentos inválido. Debes pasar pares FASTQ GENOME"
  echo "Ejemplo: $0 sample1.fastq genome1.fna sample2.fastq genome2.fna"
  exit 1
fi

# Crear carpetas para resultados
mkdir -p results
mkdir -p bam
mkdir -p gtf

while (( "$#" )); do
  fastq=$1
  genome=$2
  shift 2

  base_fastq=$(basename "$fastq" .fastq)
  base_fastq=$(basename "$base_fastq" .fq)

  echo "Procesando $fastq con genoma $genome..."

  # 1. Alinear con minimap2 (splice-aware long reads)
  minimap2 -ax splice -uf -t $threads -k14 "$genome" "$fastq" > results/${base_fastq}.sam

  # 2. Convertir SAM a BAM y ordenar por coordenadas
  samtools view -@ $threads -bS results/${base_fastq}.sam | samtools sort -@ $threads -o bam/${base_fastq}.sorted.bam

  # 3. Ordenar BAM por nombre para bedtools
  samtools sort -n -@ $threads bam/${base_fastq}.sorted.bam -o bam/${base_fastq}.sorted_by_name.bam

  # 4. Convertir BAM a BED (formato 12 columnas)
  bedtools bamtobed -bed12 -i bam/${base_fastq}.sorted_by_name.bam > bam/${base_fastq}.bed

  # 5. Ensamblar con StringTie
  stringtie bam/${base_fastq}.sorted.bam -o gtf/${base_fastq}.gtf -L -p $threads

  # Opcional: borrar archivos temporales para ahorrar espacio
  rm results/${base_fastq}.sam
  rm bam/${base_fastq}.sorted_by_name.bam
done

