# Deep-Live-Cam for Intel Systems

This guide provides specific instructions for running Deep-Live-Cam on Intel hardware.

## Setup

1. **Environment Setup**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements_updated.txt
   sudo apt-get install python3-tk
   ```

2. **Intel GPU Acceleration**
   ```bash
   pip install onnxruntime-openvino
   ```

## Running the Application

We've created a special script to run Deep-Live-Cam with Intel optimizations:

```bash
./run_with_fixes.sh
```

This script:
- Activates the virtual environment
- Disables CUDA to prevent errors
- Reduces TensorFlow warning verbosity
- Runs with OpenVINO execution provider for Intel GPU acceleration
- Enables mirror mode for webcam

## Camera Issues

If you encounter camera detection issues:
- The application will scan for available cameras
- On this system, cameras 0 and 2 are available
- The warnings about cameras 1, 3-9 can be safely ignored

## Performance Tips

1. **For CPU-only systems:**
   ```bash
   python run.py --execution-provider cpu --execution-threads 8
   ```
   Adjust the thread count based on your CPU.

2. **For systems with Intel integrated graphics:**
   ```bash
   python run.py --execution-provider openvino
   ```

3. **Reduce resource usage:**
   - Use `--max-memory` parameter to limit RAM usage
   - Use smaller resolution videos/images
   - Disable face enhancement if performance is slow

## Troubleshooting

- If the application crashes, try running with CPU provider instead of OpenVINO
- If you see CUDA errors, they can be ignored as we're using Intel graphics
- For webcam issues, try specifying a different camera index with `--camera-id 0` or `--camera-id 2`
