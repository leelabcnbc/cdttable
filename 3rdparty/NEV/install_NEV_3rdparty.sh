#!/usr/bin/env bash

cp ce_read_cortex_index.m ../../+nevreader
cp ce_read_cortex_record.m ../../+nevreader

# remove existing dirs
rm -rf NPMK
rm -rf NPMK-4.0.0.0
unzip NPMK-4.0.0.0.zip