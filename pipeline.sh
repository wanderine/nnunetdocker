#!/bin/bash

# Convert DICOM to nifti
python /home/convert_to_nifti.py /in /nifti_in

#cp /in/* /nifti_in

# Perform segmentation
python /home/nnUNet/nnunet/inference/predict_simple.py -i /nifti_in -o /nifti_out -t Task01_BraTS_onlyT1ce

# Post-process segmentations
for image in /nifti_out/*.nii.gz; do
  echo "Post-processing $image"
  python /home/post_process_segmentation.py $image $image
done

# Convert nifti to DICOM RTSTRUCT
for image in /nifti_out/*.nii.gz; do
  echo "Converting $image segmentation to RTSTRUCT"
  python /home/convert_to_RTSTRUCT.py $image /in /out
done

# copy nifti output to output directory
cp /nifti_out/*.nii.gz /out 

# copy original nifti to output directory
cp /nifti_in/*.nii.gz /out 

