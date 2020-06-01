# groupadd docker
# usermod -a -G docker $USER
# usermod -a -G docker andek

#!/bin/bash

docker build --no-cache -t nnimage-gpu-2 .
