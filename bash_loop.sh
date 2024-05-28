#!/bin/bash
filename="models_short"
while IFS= read -r line
do
    for L in {0..400..50}
    do
        bash job.slurm $line $L
    done
done < "$filename"

filename="models_long"
while IFS= read -r line
do
    for L in {0..4000..500}
    do
        bash job.slurm $line $L
    done
done < "$filename"