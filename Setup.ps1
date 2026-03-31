# Miniconda & Env Auto-Installer

# Check Admin privileges
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator!"
    Pause; Exit
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Miniconda & Environment Setup Tool    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

#Check if Conda is already installed
Write-Host "`n[1/3] Checking for existing Conda installation..." -ForegroundColor Yellow

$condaPath = $null

#check if it's already in the system PATH
$cmd = Get-Command "conda.exe" -ErrorAction SilentlyContinue
if ($cmd) {
    $condaPath = $cmd.Source
} else {
    # If not in PATH, search common default installation directories
    $commonPaths = @(
        "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
        "$env:USERPROFILE\anaconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\miniconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\anaconda3\Scripts\conda.exe",
        "C:\ProgramData\miniconda3\Scripts\conda.exe",
        "C:\ProgramData\anaconda3\Scripts\conda.exe",
        "C:\miniconda3\Scripts\conda.exe",
        "C:\anaconda3\Scripts\conda.exe"
    )

    foreach ($p in $commonPaths) {
        if (Test-Path $p) {
            $condaPath = $p
            Write-Host "  -> Found Conda hidden at: $condaPath" -ForegroundColor DarkGray
            
            # Temporarily add Conda to the current session's PATH so subsequent commands work
            $condaDir = [System.IO.Path]::GetDirectoryName($p)
            $env:Path = "$condaDir;" + $env:Path
            break
        }
    }
}

if ($null -ne $condaPath) {
    Write-Host "  -> Conda is installed and ready to use!" -ForegroundColor Green
} else {
    #Download and Install Miniconda Silently
    Write-Host "  -> Conda not found anywhere. Starting download..." -ForegroundColor DarkGray
    $url = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
    $outPath = "$env:TEMP\MinicondaSetup.exe"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $outPath -ErrorAction Stop
        Write-Host "  -> Download complete. Installing Miniconda..." -ForegroundColor DarkGray
        
        # Silent install arguments
        Start-Process -FilePath $outPath -ArgumentList "/S", "/InstallationType=JustMe", "/AddToPath=1", "/RegisterPython=1" -Wait -ErrorAction Stop
        
        Remove-Item $outPath -ErrorAction SilentlyContinue
        Write-Host "  -> Miniconda installed successfully!" -ForegroundColor Green
        
        # Refresh environment variables for the current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Host "  -> Failed to install Miniconda: $($_.Exception.Message)" -ForegroundColor Red
        Pause; Exit
    }
}

#Environment Creation Menu
Write-Host "`n[2/3] Environment Creation Options" -ForegroundColor Yellow
Write-Host "------------------------------------------"
Write-Host "1. Full-Auto (Name: 'pytorch_env', Python: 3.10)"
Write-Host "2. Semi-Auto (Custom Name & Version)"
Write-Host "3. Skip (Do not create environment)"
Write-Host "------------------------------------------"

$choice = Read-Host "Select an option (1-3)"

if ($choice -eq "1" -or $choice -eq "2") {
    if ($choice -eq "1") {
        $envName = "pytorch_env"
        $pyVer = "3.10"
    } else {
        $envName = Read-Host "Enter environment name"
        $pyVer = Read-Host "Enter Python version (e.g., 3.11)"
        if ([string]::IsNullOrWhiteSpace($envName)) { $envName = "my_env" }
        if ([string]::IsNullOrWhiteSpace($pyVer)) { $pyVer = "3.10" }
    }

    # --- Collision Detection ---
    $envExists = $false
    $existingEnvs = conda env list
    if ($existingEnvs -match "(?m)^$envName\s+") {
        $envExists = $true
    }

    if ($envExists) {
        Write-Host "`n[!] Environment '$envName' already exists!" -ForegroundColor Yellow
        Write-Host "1. Use the existing environment (Install PyTorch into it)"
        Write-Host "2. Delete and Recreate it (Clean state)"
        Write-Host "3. Auto-rename (Create as '$envName`_new')"
        $colChoice = Read-Host "Select (1-3)"

        if ($colChoice -eq "1") {
            Write-Host "  -> Proceeding with existing environment '$envName'..." -ForegroundColor DarkGray
        } elseif ($colChoice -eq "2") {
            Write-Host "  -> Removing existing '$envName'..." -ForegroundColor DarkGray
            conda env remove -n $envName -y
            Write-Host "  -> Creating fresh '$envName' (Python $pyVer)..." -ForegroundColor Cyan
            conda create -n $envName python=$pyVer -y
        } else {
            $envName = "$envName`_new"
            Write-Host "  -> Creating environment as '$envName' (Python $pyVer)..." -ForegroundColor Cyan
            conda create -n $envName python=$pyVer -y
        }
    } else {
        Write-Host "`n[3/3] Creating environment '$envName' with Python $pyVer..." -ForegroundColor Cyan
        conda create -n $envName python=$pyVer -y
    }
} elseif ($choice -eq "3") {
    Write-Host "`n[3/3] Skipping environment creation." -ForegroundColor DarkYellow
} else {
    Write-Host "`nInvalid selection. Skipping..." -ForegroundColor Red
}


#PyTorch Auto-Detection & Installation
#Detect GPU (Handle Dual-GPU / Laptops correctly)
    $gpuInfoArray = (Get-CimInstance Win32_VideoController).Name
    $gpuInfo = $gpuInfoArray -join " | "  # Splits "AMD... | NVIDIA..."
    $cudaVersion = 0.0
    $installCmd = ""

    #Force locate nvidia-smi (Sometimes it's not in PATH)
    $smiPath = "nvidia-smi"
    $smiPathsToCheck = @(
        "C:\Windows\System32\nvidia-smi.exe",
        "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"
    )
    foreach ($p in $smiPathsToCheck) {
        if (Test-Path $p) { $smiPath = $p; break }
    }

    # Execute nvidia-smi and parse output
    try {
        $nvidiaSmiOut = (& $smiPath 2>&1) -join "`n"
        
        if ($nvidiaSmiOut -match "CUDA Version:\s*(\d+\.\d+)") {
            $cudaVersion = [float]$Matches[1]
        }
    } catch {
        # nvidia-smi failed or not found
        $cudaVersion = 0.0
    }

    Write-Host "  -> Detected GPU(s): $gpuInfo" -ForegroundColor DarkGray
    Write-Host "  -> Max System CUDA Support: $cudaVersion" -ForegroundColor DarkGray

    #Logic to choose the best version or prompt for fallback
    if ($gpuInfo -match "NVIDIA" -and $cudaVersion -ge 11.8) {
        if ($cudaVersion -ge 13.0) {
            Write-Host "  -> System supports CUDA $cudaVersion. Installing PyTorch (CUDA 13.0)" -ForegroundColor Green
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130"
        } elseif ($cudaVersion -ge 12.8) {
            Write-Host "  -> System supports CUDA $cudaVersion. Installing PyTorch (CUDA 12.8)" -ForegroundColor Green
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128"
        } elseif ($cudaVersion -ge 12.6) {
            Write-Host "  -> System supports CUDA $cudaVersion. Installing PyTorch (CUDA 12.6)" -ForegroundColor Green
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
        } elseif ($cudaVersion -ge 12.4) {
            Write-Host "  -> System supports CUDA $cudaVersion. Installing PyTorch (CUDA 12.4)" -ForegroundColor Green
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124"
        } else {
            Write-Host "  -> System supports CUDA $cudaVersion. Installing Legacy PyTorch (CUDA 11.8)" -ForegroundColor Green
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
        }
    } else {
        # NO SUPPORTED GPU FOUND - Prompt User
        Write-Host "`n[!] No compatible NVIDIA GPU or CUDA driver detected." -ForegroundColor Red
        Write-Host "------------------------------------------"
        Write-Host "1. Install CPU-only version (For testing / Non-GPU tasks)"
        Write-Host "2. Abort installation (I need to fix my NVIDIA drivers first)"
        Write-Host "------------------------------------------"
        $fallbackChoice = Read-Host "Please select (1-2)"

        if ($fallbackChoice -eq "1") {
            Write-Host "  -> Proceeding with CPU-only version..." -ForegroundColor DarkYellow
            $installCmd = "conda run --no-capture-output -n $envName pip install torch torchvision torchaudio"
        } else {
            Write-Host "  -> PyTorch installation aborted by user." -ForegroundColor Red
            # We don't exit the whole script, just skip PyTorch install
            $installCmd = "" 
        }
    }

    # 3. Execute Installation
    if ($installCmd -ne "") {
        Write-Host "`nStarting installation... This will take a few minutes." -ForegroundColor Cyan
        
        # Use Invoke-Expression to execute the complete string properly
        Invoke-Expression $installCmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n[SUCCESS] PyTorch is locked and loaded in '$envName'!" -ForegroundColor Green
            Write-Host "To activate your environment, run: conda activate $envName" -ForegroundColor White
        } else {
            Write-Host "`n[ERROR] Installation failed. Please check your internet connection." -ForegroundColor Red
        }
    }

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "    Process Finished. Have a nice day :3    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Pause