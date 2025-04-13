#!/bin/bash

# Activate virtual environment
source venv/bin/activate

# Set environment variables to suppress CUDA errors
export CUDA_VISIBLE_DEVICES=""

# Disable TensorFlow warnings
export TF_CPP_MIN_LOG_LEVEL=2

# Run with Intel OpenVINO provider and specify camera index 0 (which is available)
python run.py --execution-provider openvino --live-mirror
