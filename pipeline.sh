#!/bin/bash

# Perform segmentation
python /home/nnUNet/nnunet/inference/predict_simple.py -i /in -o /out -t Task01_BraTS_onlyT1ce

# Post-process segmentations
for image in out/*.nii.gz; do
  echo "Post-processing $image"
  python /home/post_process_segmentation.py $image $image
done
