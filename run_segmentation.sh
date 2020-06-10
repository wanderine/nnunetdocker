#!/bin/bash

#docker run --rm --gpus '"device=2"' -v /raid/andek67/nnunetdocker/testdata:/in -v /raid/andek67/nnunetdocker/testoutput:/out nnimage-gpu-dicom

docker run --rm --gpus '"device=2"' -v /raid/andek67/nnunetdocker/testdicom/NSCLC-RADIOMICS-INTEROBSERVER1/interobs06/02-18-2019-CT-43086/01133:/in -v /raid/andek67/nnunetdocker/testoutput:/out nnimage-gpu-dicom

