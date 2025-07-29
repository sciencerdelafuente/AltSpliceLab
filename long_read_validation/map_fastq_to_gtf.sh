#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 samples_list.txt"
  exit 1
fi

samples_file=$1
output_file="fastq_gtf_map.txt"

> "$output_file"  # borrar contenido previo si existe

while read -r fastq genome; do
  base=$(basename "$fastq" .fastq)
  gtf="${base}.gtf"
  echo -e "$gtf\t$fastq" >> "$output_file"
done < "$samples_file"

echo "Archivo de mapeo creado: $output_file"

