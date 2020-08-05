import dicom2nifti
import argparse

def convert(input_dicom_path: str, output_nifti_path: str):
    dicom2nifti.convert_directory(input_dicom_path, output_nifti_path, compression=True, reorient=False)

def get_parser():
    """
    Parse input arguments.
    """
    parser = argparse.ArgumentParser(description='Convert DICOM images to nifti file')

    # Positional arguments.
    parser.add_argument("input_dicom", help="Path to input DICOM images")
    parser.add_argument("output_nifti", help="Path to output NIFTI image")
    return parser.parse_args()

if __name__ == "__main__":
    p = get_parser()

    convert(p.input_dicom, p.output_nifti)

