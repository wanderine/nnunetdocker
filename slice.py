
import argparse
import numpy as np
import nibabel as nib
import matplotlib.image as mpimage
import matplotlib.cm as cm
import sys
import os

parser = argparse.ArgumentParser()
parser.add_argument('input_vol', help='segmentation from which to extract slices')
parser.add_argument('-u', '--underlay', help='image on which to overlay segmentation')

# Parse input path
args = parser.parse_args()
in_vol_path = args.input_vol
und_vol_path = args.underlay

# Check input
if not os.path.isfile(in_vol_path):
    sys.exit(' File ' + in_vol_path + ' does not exist')
    
if not in_vol_path[-6:] == 'nii.gz' or in_vol_path[-3:] == 'nii':
    sys.exit(' Input must be a (compressed) NIfTI file')

# Get volume    
vol = nib.load(in_vol_path).get_data()
max_label = np.unique(vol)[-1]

vol_binary = vol.astype('bool')

# Find slice with maximum number of tumor voxels in each direction
x_sum = vol_binary.sum((1,2))
y_sum = vol_binary.sum((0,2))
z_sum = vol_binary.sum((0,1))

i_max_x = x_sum.argmax()
i_max_y = y_sum.argmax()
i_max_z = z_sum.argmax()

x_slice = vol[i_max_x, :, :]
y_slice = vol[:, i_max_y, :]
z_slice = vol[:, :, i_max_z]

if not und_vol_path == None:
    # Load underlay
    under = nib.load(und_vol_path).get_data()
    under = under / np.unique(under)[-1] * (max_label/2)
    
    # Take underlay slices
    x_slice_under = under[i_max_x, :, :]
    y_slice_under = under[:, i_max_y, :]
    z_slice_under = under[:, :, i_max_z]
    
    x_slice = x_slice.astype('float')
    y_slice = y_slice.astype('float')
    z_slice = z_slice.astype('float')

    # Load underlay and overlay colormaps
    gray = cm.ScalarMappable(cmap='gray')
    viridis = cm.ScalarMappable(cmap='inferno')
    
    # Apply colors to underlay and overlay
    a = gray.to_rgba(x=x_slice_under)
    b = viridis.to_rgba(x=x_slice / (3*max_label) + 0.5, norm=False)
    x_slice_full = a
    x_slice_full[x_slice != 0] = b[x_slice != 0]
    
    a = gray.to_rgba(x=y_slice_under)
    b = viridis.to_rgba(x=y_slice / (3*max_label) + 0.5, norm=False)
    y_slice_full = a
    y_slice_full[y_slice != 0] = b[y_slice != 0]

    a = gray.to_rgba(x=z_slice_under)
    b = viridis.to_rgba(x=z_slice / (3*max_label) + 0.5, norm=False)
    z_slice_full = a
    z_slice_full[z_slice != 0] = b[z_slice != 0]

    mpimage.imsave('slice_x_sagittal.png',np.rot90(x_slice_full,1))
    mpimage.imsave('slice_y_coronal.png',np.fliplr(np.rot90(y_slice_full,1)))
    mpimage.imsave('slice_z_axial.png',np.rot90(z_slice_full,-1))
else:
    # Save images
    mpimage.imsave('slice_x_sagittal.png',np.rot90(x_slice,1), vmin=0, vmax=max_label, cmap='gray')
    mpimage.imsave('slice_y_coronal.png',np.fliplr(np.rot90(y_slice,1)), vmin=0, vmax=max_label, cmap='gray')
    mpimage.imsave('slice_z_axial.png',np.rot90(z_slice,-1), vmin=0, vmax=max_label, cmap='gray')