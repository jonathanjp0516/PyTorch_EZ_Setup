# PyTorch EZ Setup

[English](#english) | [繁體中文](#繁體中文) | [日本語](#日本語)

---

## English

A PowerShell script that automates the entire process of setting up a PyTorch environment on Windows. It detects your hardware, installs Miniconda, and configures the perfect PyTorch version for your GPU (supports the latest **RTX 50-series**).

### Features
* **Auto-Miniconda:** Downloads and installs Miniconda silently if not found.
* **Smart GPU Detection:** Specifically optimized for **Dual-GPU** (AMD/NVIDIA) laptops and high-end **RTX 50-series** cards.
* **CUDA 13.0+ Ready:** Automatically chooses the best PyTorch build (12.4, 12.8, 13.0) via direct PIP wheels to bypass slow Conda channel updates.
* **Collision Protection:** Safely handles existing environment names with options to reuse, overwrite, or rename.

### How to Use
1.  Download `PyTorch EZ Setup`.
2.  Open **PowerShell as Administrator**.
3.  Navigate to the `PyTorch EZ Setup` folder.
4.  Run: `.\Setup.ps1`

### Compatibility
* **OS:** Windows 10 / 11
* **NVIDIA GPUs (CUDA Acceleration):** RTX 50, 40, 30, 20 series, GTX 16, 10 series, and professional workstation cards (e.g., Quadro, RTX A-series). 
  *(The script will automatically detect your driver and install PyTorch with CUDA 11.8, 12.4, 12.6, 12.8, or 13.0).*
* **AMD / Intel / No Dedicated GPU:** Automatically falls back to installing the CPU-only version of PyTorch for maximum compatibility.

---

## 繁體中文

這是一個 PowerShell 腳本，旨在全自動化 Windows 上的 PyTorch 環境建置。它會自動偵測您的硬體規格、安裝 Miniconda，並為您的顯卡配對最適合的 PyTorch 版本（支援最新 **RTX 50 系列** 與 **CUDA 13.0**）。

### 核心功能
* **全自動 Conda 安裝：** 若系統未偵測到 Conda，將自動下載並完成靜默安裝。
* **智慧硬體偵測：** 特別優化**雙顯卡** (AMD+NVIDIA) 偵測邏輯，精準識別硬體。
* **最新生態對接：** 採用 Pip-in-Conda 技術直連官網，確保能安裝到 Conda 頻道尚未更新的最新穩定版 (如 CUDA 13.0)。
* **防撞名機制：** 若環境名稱重複，提供沿用、覆蓋、自動重新命名等選項。

### 使用方式
1.  下載 `PyTorch EZ Setup`
2.  以**系統管理員身分**開啟 PowerShell
3.  導航至 `PyTorch EZ Setup` 資料夾
4.  輸入：`.\Setup.ps1`

### 支援硬體清單
* **作業系統:** Windows 10 / 11
* **NVIDIA 顯示卡 (完整 CUDA 加速):** RTX 50, 40, 30, 20 系列、GTX 16, 10 系列，以及各類專業繪圖卡。
  *(腳本會依據您的系統驅動天花板，自動配對並安裝 CUDA 11.8 ~ 13.0)*
* **AMD / Intel / 無獨立顯卡 (CPU 模式):** 腳本會自動啟動防呆機制，為您安裝 CPU 版本的 PyTorch，確保環境依然能順利建置。

---

## 日本語

Windows 上で PyTorch 環境を完全に自動構築するための PowerShell スクリプトです。ハードウェアを自動的に検出し、Miniconda をインストールし、お使いの GPU（最新の **RTX 50 シリーズ** と **CUDA 13.0** を含む）に最適な PyTorch バージョンを構成します。

### 主な機能
* **Miniconda 自動インストール：** インストールされていない場合、バックグラウンドで自動的にセットアップします。
* **スマート GPU 検出：** **デュアル GPU** (AMD+NVIDIA) やハイエンド **RTX 50 シリーズ** を正確に識別します。
* **最新の CUDA 対応：** Conda チャンネルの更新を待たず、Pip 経由で PyTorch 官網から直接最新版（CUDA 13.0 など）を取得します。
* **名前衝突の回避：** 同名の仮想環境が存在する場合、再利用・上書き・自動リネームを選択可能です。

### 使用方法
1.  `PyTorch EZ Setup` をダウンロードします。
2.  **管理者として PowerShell** を開きます。
3.  `PyTorch EZ Setup` フォルダに移動します。
4.  実行：`.\Setup.ps1`

### 対応ハードウェア
* **OS:** Windows 10 / 11
* **NVIDIA GPU (CUDA 高速化対応):** RTX 50, 40, 30, 20 シリーズ、GTX 16, 10 シリーズ、およびワークステーション用カード。
  *(システムのドライバに応じて、CUDA 11.8 〜 13.0 の最適なバージョンを自動で選択・インストールします)*
* **AMD / Intel / GPUなし (CPU モード):** 互換性を保つため、自動的に CPU 版の PyTorch をインストールします。

---