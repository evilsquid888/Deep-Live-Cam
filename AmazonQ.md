# Deep-Live-Cam Setup with Amazon Q

This document outlines the steps taken to set up Deep-Live-Cam on a Linux system with Python 3.12 using Amazon Q assistance.

## Environment Setup

1. Created a Python virtual environment with Python 3.12.7:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. Modified requirements for Python 3.12 compatibility:
   - Updated onnxruntime-gpu to version >=1.17.0
   - Ensured all dependencies work with Python 3.12

3. Installed system dependencies:
   ```bash
   sudo apt-get install python3-tk
   ```

4. Installed Python dependencies:
   ```bash
   pip install -r requirements_updated.txt
   ```

## Intel-Specific Optimizations

For Intel CPU systems:
- Use `--execution-provider cpu` with appropriate thread count
- Example: `python run.py --execution-provider cpu --execution-threads 8`

For Intel GPU acceleration (if available):
- Install OpenVINO: `pip install onnxruntime-openvino==1.15.0`
- Run with: `python run.py --execution-provider openvino`

## Required Models

The following models are required and should be placed in the `models` directory:
- GFPGANv1.4.pth
- inswapper_128_fp16.onnx

## Usage Tips

1. For webcam mode:
   - Select a source face image
   - Click "Live"
   - Wait for the preview (10-30 seconds)
   - Use screen capture tools like OBS to stream

2. Performance optimization:
   - Adjust `--max-memory` parameter based on available RAM
   - Use smaller resolution videos/images for better performance
   - Consider disabling face enhancement if performance is slow

3. Common features:
   - Mouth mask: Retain original mouth for accurate movement
   - Face mapping: Use different faces on multiple subjects
   - Many faces: Process every face in the frame

## Troubleshooting

If you encounter issues:
- Ensure all dependencies are correctly installed
- Check that model files are in the correct location
- Try running with `--execution-provider cpu` if GPU acceleration fails
- For GUI issues, verify tkinter is properly installed
