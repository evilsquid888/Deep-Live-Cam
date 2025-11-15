# Security Analysis Report - Deep-Live-Cam

**Analysis Date:** 2025-11-15
**Analyzed Version:** Latest from hacksider/Deep-Live-Cam (main branch)
**Analyst:** Automated Security Review

---

## Executive Summary

**Overall Verdict: NOT MALWARE - Legitimate open-source software with some security considerations**

Deep-Live-Cam is a legitimate AI-powered face-swapping application. The codebase shows no evidence of malicious intent, data exfiltration, or system compromise attempts. However, there are some security best practices that could be improved, particularly around dependency management.

---

## What This Software Does

- **Primary Function:** Real-time face swapping and video deepfake generation
- **Technology:** Uses AI/ML models (ONNX, PyTorch, OpenCV) for face detection and swapping
- **Interface:** GUI application built with tkinter
- **Processing:** Works with images, videos, and live camera feeds

---

## Security Analysis

### ✅ No Malicious Behavior Detected

The following malicious patterns were **NOT FOUND**:

- ❌ No data exfiltration or credential harvesting
- ❌ No unauthorized network connections beyond model downloads
- ❌ No system file modifications outside project directory
- ❌ No keylogging or clipboard monitoring
- ❌ No code injection vulnerabilities (eval/exec)
- ❌ No writing to sensitive system directories (/etc/, /bin/, registry, etc.)
- ❌ No SSH/FTP/backdoor connections
- ❌ No cryptocurrency mining code
- ❌ No process injection or privilege escalation attempts

### 🔍 Code Review Findings

#### Network Activity
**Location:** `modules/utilities.py:188-206`

The application downloads ML models from:
1. **HuggingFace:** `https://huggingface.co/hacksider/deep-live-cam/blob/main/inswapper_128_fp16.onnx`
   - Face swapping model (~128MB)
2. **GitHub Releases:** `https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth`
   - Face enhancement model

These downloads are legitimate and expected for this type of application.

#### Subprocess Execution
**Location:** `modules/utilities.py:23-60`

The application executes:
- `ffmpeg` - For video/audio processing (standard multimedia tool)
- `ffprobe` - For video metadata detection (standard multimedia tool)

Both are legitimate system commands, not arbitrary code execution.

---

## 🔴 Security Concerns Identified

### 1. SSL Certificate Verification Disabled (macOS)

**Severity:** MEDIUM
**Location:** `modules/utilities.py:19-20`

```python
if platform.system().lower() == "darwin":
    ssl._create_default_https_context = ssl._create_unverified_context
```

**Risk:**
- Disables SSL certificate validation on macOS
- Could allow man-in-the-middle attacks during model downloads
- Attacker could serve malicious models if they intercept network traffic

**Recommendation:**
- Remove this workaround or only disable for specific known URLs
- Update certificates properly instead of disabling verification

### 2. Unpinned Git Dependencies (CRITICAL)

**Severity:** HIGH
**Location:** `requirements.txt:22-23`

```
git+https://github.com/xinntao/BasicSR.git@master
git+https://github.com/TencentARC/GFPGAN.git@master
```

**Risk:**
- **Supply chain attack vector** - Code pulled from `@master` branch can change at any time
- If either repository is compromised, malicious code could be injected
- No reproducibility - different installations get different code
- No code review - can't verify what code is actually being installed

**Impact:**
An attacker who compromises these repositories could inject:
- Backdoors
- Data exfiltration code
- Cryptocurrency miners
- System exploits

**Repositories Analysis:**
- **BasicSR** (xinntao/BasicSR): 7.9k stars, legitimate image restoration toolbox
- **GFPGAN** (TencentARC/GFPGAN): 37.2k stars, legitimate face restoration by Tencent ARC

While both repositories are currently trustworthy, the unpinned specification is a security anti-pattern.

**Recommendation - Option 1 (BEST):** Use PyPI versions:
```
basicsr==1.4.2
gfpgan==1.3.8
```

**Recommendation - Option 2:** Pin to specific commit hashes:
```
git+https://github.com/xinntao/BasicSR.git@a12b34c56d78ef90ab...
git+https://github.com/TencentARC/GFPGAN.git@e98f76d54c32ab01cd...
```

**Recommendation - Option 3:** Use release tags:
```
git+https://github.com/xinntao/BasicSR.git@v1.4.2
git+https://github.com/TencentARC/GFPGAN.git@v1.3.8
```

---

## 🟡 Other Considerations

### Large Binary Downloads
- First run will download several hundred MB of ML models
- Ensure you have adequate bandwidth and storage
- Models are cached in `models/` directory

### System Requirements
- Requires `ffmpeg` to be installed on system
- GPU support requires CUDA/ROCm/CoreML drivers
- Can consume significant RAM/VRAM during processing

### Privacy Considerations
- All processing appears to be local (no cloud uploads detected)
- No telemetry or analytics code found
- NSFW filter is built-in but can be disabled via command-line flag

---

## Dependencies Analysis

### PyPI Dependencies
All standard packages from requirements.txt appear legitimate:
- `numpy`, `opencv-python`, `torch`, `onnx`, `insightface` - Standard ML/CV libraries
- `customtkinter`, `pillow` - Standard GUI/image libraries
- `psutil`, `protobuf` - Standard utility libraries

### External Package Sources
- PyTorch wheels from: `https://download.pytorch.org/whl/cu128` (Official PyTorch)
- Git dependencies: BasicSR and GFPGAN (See concerns above)

---

## Recommendations

### For Users

**Safe to Use If:**
- ✅ You trust the source (hacksider/Deep-Live-Cam is a popular 37k+ star repo)
- ✅ You understand it downloads large ML models
- ✅ You install in a Python virtual environment (recommended)
- ✅ You're aware of ethical/legal implications of deepfake software
- ✅ You have `ffmpeg` installed

**Best Practices:**
1. Install in a virtual environment: `python -m venv venv`
2. Review downloaded model files if concerned
3. Keep software updated from official repo only
4. Don't use on public/production systems without review
5. Be aware of deepfake laws in your jurisdiction

### For Maintainers

**High Priority:**
1. Pin git dependencies to specific versions/commits
2. Remove SSL verification bypass on macOS or scope it narrowly
3. Consider using PyPI packages instead of git dependencies

**Medium Priority:**
1. Add checksums/hashes for downloaded models
2. Implement signature verification for model files
3. Add security policy and vulnerability reporting process
4. Document security considerations in README

**Low Priority:**
1. Add dependency scanning (Dependabot, Snyk)
2. Add SBOM (Software Bill of Materials)
3. Consider code signing for releases

---

## Testing Methodology

### Static Analysis Performed
- ✅ Manual code review of all Python files
- ✅ Search for dangerous functions: `eval()`, `exec()`, `__import__`
- ✅ Search for system command execution patterns
- ✅ Search for network operations
- ✅ Search for credential/secret handling
- ✅ Review of all external URLs and downloads
- ✅ Analysis of subprocess calls
- ✅ Review of file system operations
- ✅ Dependency tree analysis

### Files Reviewed
- All `.py` files in project (24 files)
- `requirements.txt`
- Shell scripts: `run.py`, `run_with_fixes.sh`, `run-cuda.bat`, `run-directml.bat`
- Configuration files: `.gitignore`
- README and documentation

---

## Conclusion

**Deep-Live-Cam is legitimate software, not malware.**

However, the unpinned git dependencies represent a **medium-to-high security risk** that should be addressed. While the current code is safe, the dependency specification could allow malicious code injection if upstream repositories are compromised.

**Risk Level:** MEDIUM (due to supply chain concerns)

**Recommended Action:**
- Users: Safe to use with caution; install in isolated environment
- Maintainers: Address dependency pinning issues

---

## References

- Repository: https://github.com/hacksider/Deep-Live-Cam
- BasicSR: https://github.com/xinntao/BasicSR (7.9k stars, Apache 2.0)
- GFPGAN: https://github.com/TencentARC/GFPGAN (37.2k stars, maintained by Tencent ARC)
- HuggingFace Models: https://huggingface.co/hacksider/deep-live-cam

---

**Disclaimer:** This analysis is based on static code review at a specific point in time. Dynamic analysis (runtime behavior monitoring) was not performed. Code may change over time, and new vulnerabilities may be introduced. Always keep software updated and monitor for security advisories.
