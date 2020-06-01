import argparse

import SimpleITK as sitk


def get_parser():
    """
    Parse input arguments.
    """
    parser = argparse.ArgumentParser(description='Postprocess label image containing multiple labels by selecting the'
                                                 'largest component and removing all other components.')

    # Positional arguments.
    parser.add_argument("input_image", help="Path to input image (Nifty or ITK image)")
    parser.add_argument("output_image", help="Path to output image (Nifty or ITK image)")
    return parser.parse_args()


def filter_largest_component(binary_input_label_image: sitk.Image):
    """"
    Use connected component analysis to return the largest connected region in the image.

    Args:
        binary_input_label_image: Binary sitk image containing the different components.

    Returns:
        binary itk image solely containing the largest connected region in the image.
    """
    components = sitk.ConnectedComponent(binary_input_label_image)
    stats_filter = sitk.LabelStatisticsImageFilter()
    stats_filter.Execute(components, components)

    # Iterate through the image components and extract the largest one, background excluded.
    max_volume = 0
    largest_component = 0
    for label in stats_filter.GetLabels():
        if label > 0:
            volume_cc = stats_filter.GetCount(label)
            if volume_cc > max_volume:
                largest_component = label
                max_volume = volume_cc
    output_label = sitk.BinaryThreshold(components, lowerThreshold=largest_component,
                                        upperThreshold=largest_component,
                                        insideValue=1, outsideValue=0)
    return output_label


def post_process(input_label_image_path: str, output_label_image_path: str):
    input_image = sitk.ReadImage(input_label_image_path)

    # Create binary mask of the foreground and select largest component.
    input_mask = sitk.BinaryThreshold(input_image, 1, 100)
    largest_component_mask = filter_largest_component(input_mask)

    # Multiply largest component with input image to obtain the original labels and write to disk.
    result = largest_component_mask * input_image
    sitk.WriteImage(result, output_label_image_path)


if __name__ == "__main__":
    p = get_parser()

    post_process(p.input_image, p.output_image)
