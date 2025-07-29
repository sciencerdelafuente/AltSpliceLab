#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 gtf_size_fastq_list.txt"
  exit 1
fi

list_file=$1

# Compilar asr.cpp solo una vez
g++ asr.cpp -o o
if [ $? -ne 0 ]; then
  echo "Error al compilar asr.cpp"
  exit 1
fi

output_file="asr_individual_summary.tsv"
echo -e "GTF_file\tGTF_size_GB\tFASTQ_size_GB\tASR_value" > "$output_file"

convert_to_gb() {
  size_str=$1
  # Extraer número y sufijo
  num=$(echo "$size_str" | grep -oE '^[0-9.]+')
  unit=$(echo "$size_str" | grep -oE '[MG]$')
  
  if [[ "$unit" == "M" ]]; then
    # Convertir megabytes a gigabytes
    echo "scale=6; $num / 1024" | bc
  elif [[ "$unit" == "G" ]]; then
    echo "$num"
  else
    # Sin sufijo, asumimos GB
    echo "$num"
  fi
}

while IFS=' ' read -r gtf_file fastq_size_str; do
  gtf_path="$gtf_file"
  
  if [ ! -f "$gtf_path" ]; then
    echo "Advertencia: archivo $gtf_path no encontrado, saltando..."
    continue
  fi
  
  # Obtener tamaño del GTF en bytes y pasar a GB
  size_bytes=$(stat -c%s "$gtf_path")
  size_gb=$(echo "scale=6; $size_bytes/(1024*1024*1024)" | bc)

  # Convertir tamaño fastq a GB numérico
  fastq_size_gb=$(convert_to_gb "$fastq_size_str")
  
  # Ejecutar asr.cpp para ese archivo
  asr_val=$(./o "$gtf_path")
  
  # Guardar resultados
  echo -e "${gtf_file}\t${size_gb}\t${fastq_size_gb}\t${asr_val}" >> "$output_file"
  
  echo "Procesado $gtf_file: GTF_size=${size_gb}GB, FASTQ_size=${fastq_size_gb}GB, ASR=$asr_val"
done < "$list_file"

echo "Proceso finalizado. Resultados guardados en $output_file"


