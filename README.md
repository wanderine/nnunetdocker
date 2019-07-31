# nnunetdocker

Usage:

1. Build container with `bash build.sh`

2. Run with `docker run --rm --gpus <all,0,1,...> -v /path/to/input/images:/in -v /path/to/output/segmentations:/out nnimage-gpu`
