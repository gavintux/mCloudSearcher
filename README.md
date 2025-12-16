# 🔍 mCloudSearcher多雲端檔案整合搜尋系統
<div align="center">
<img src="https://img.shields.io/badge/Obsidian-DataviewJS-blueviolet?style=flat-square" alt="Obsidian">
<img src="https://img.shields.io/badge/Google%20Drive-GAS-green?style=flat-square" alt="Google Apps Script">
<img src="https://img.shields.io/badge/pCloud-Python-orange?style=flat-square" alt="pCloud">
<img src="https://img.shields.io/badge/Dropbox-Bash-brightgreen?style=flat-square" alt="Bash">

**一鍵搜尋 Google Drive、pCloud、iCloud、Dropbox 的所有檔案！**

適合 Obsidian 使用者，支援關鍵字搜尋、路徑複製、樹狀檢視。

</div>

## ✨ 功能特色

- ✅ **多雲端整合**：Google Drive、pCloud、iCloud、Dropbox 統一搜尋
- ✅ **即時搜尋**：支援 `關鍵字`、`排除(-)`、`OR(|)` 進階語法
- ✅ **一鍵開啟**：本地檔案複製路徑 → Finder，雲端檔案直接連結
- ✅ **樹狀檢視**：自動產生資料夾結構，快速導航
- ✅ **跨平台**：Windows、macOS、Linux 完整支援

## 📁 Obsidian Vault 檔案結構

```
📁 Drive_Index/           \# 索引檔案存放區
├── Drive_Index_gavin49.md  \# Google Drive
├── Drive_Index_pCloud.md   \# pCloud
├── Drive_Index_iCloud.md   \# iCloud
├── Drive_Index_dropbox.md  \# Dropbox
└── Drive_Index_93.md       \# 其他帳號

00myGD.md                  \# 主搜尋介面 (DataviewJS)

```

## 🚀 快速開始（5分鐘完成）

### 第一步：準備 Obsidian
```

1. 開啟 Obsidian → 新建 Vault（例如：zenlife）
2. 在 Vault 根目錄建立 `Drive_Index` 資料夾
3. 將 `00myGD.md` 複製到 Vault 根目錄
4. 啟用 **Dataview** 插件
```

### 第二步：執行各雲端掃描（選擇性）

| 雲端服務 | 執行指令 | 產生檔案 |
|---------|----------|----------|
| **Google Drive** | [GAS 腳本執行](#google-drive-gas) | `Drive_Index_gavin49.md` |
| **pCloud** | `python3 scan_pcloud.py` | `Drive_Index_pCloud.md` |
| **iCloud** | `./scan_icloud_drive.sh` | `Drive_Index_iCloud.md` |
| **Dropbox** | `./scan_dropbox_index.sh` | `Drive_Index_dropbox.md` |

### 第三步：開啟搜尋
```

開啟 00myGD.md → 輸入關鍵字 → 立即搜尋！

```

## 🖥️ 各作業系統完整教學

### Windows（推薦使用 WSL）
<details>
<summary>點擊展開 Windows 詳細步驟</summary>

#### Google Drive（最簡單）
1. 瀏覽器開啟 [script.google.com](https://script.google.com)
2. **新建專案** → 刪除預設程式碼
3. 貼上 `scan_GD_GAS.json` 中的 JavaScript 程式碼
4. **修改第5行**：`inputId = "您的Google Drive資料夾ID"`
```

如何取得ID：Google Drive → 右鍵資料夾 → 分享 → 複製連結 → 取 /folders/ 後面的字串

```
5. **執行** → 授權 → 選擇 `generateObsidianIndex_v4_AutoUpdate`
6. 下載產出的 `Drive_Index_gavin49.md` 到 `Drive_Index/` 資料夾

#### pCloud
```


# 1. 下載 Python：https://python.org/downloads

# 2. 命令提示字元執行：

pip install pcloud

# 3. 編輯 scan_pcloud.py

PCLOUD_EMAIL = "您的pCloud信箱"
PCLOUD_PASSWORD = "您的pCloud密碼"
OBSIDIAN_VAULT = "C:\\Users\\您的使用者名稱\\Obsidian\\zenlife"

# 4. 執行

python scan_pcloud.py

```

#### iCloud/Dropbox（建議用 WSL）
```


# 下載 Ubuntu for WSL → 安裝後：

sudo apt install python3 python3-pip
pip3 install pcloud

# 複製腳本到 WSL，修改路徑後執行

```

</details>

### macOS
<details>
<summary>點擊展開 macOS 詳細步驟</summary>

#### Google Drive（GAS）
完全相同步驟，**建議設定每日觸發器自動更新**

#### pCloud
```


# 終端機執行：

brew install python
pip3 install pcloud

# 編輯 scan_pcloud.py

PCLOUD_EMAIL = "gavintux@gmail.com"
PCLOUD_PASSWORD = "cljT@0123"
OBSIDIAN_VAULT = "/Users/您的使用者名稱/Obsidian/zenlife"

chmod +x scan_pcloud.py
./scan_pcloud.py

```

#### iCloud Drive
```

cd 到腳本位置
chmod +x scan_icloud_drive.sh

# 編輯變數：

OBSIDIAN_VAULT="/Users/您的使用者名稱/Obsidian/zenlife"

./scan_icloud_drive.sh

```

#### Dropbox
```

chmod +x scan_dropbox_index.sh
./scan_dropbox_index.sh

```

</details>

### Linux (Debian/Fedora)
<details>
<summary>點擊展開 Linux 詳細步驟</summary>

```


# Debian/Ubuntu

sudo apt update \&\& sudo apt install python3 python3-pip

# Fedora

sudo dnf install python3 python3-pip

pip3 install pcloud

# Google Drive：瀏覽器操作 GAS

# pCloud：同 macOS 步驟

# iCloud/Dropbox：使用 rclone 掛載雲端磁碟

rclone config  \# 新增遠端 → 掛載後修改腳本路徑

```

</details>

## 🔍 Obsidian 搜尋語法

| 搜尋語法 | 說明 | 範例 |
|----------|------|------|
| `南澳 預算` | 包含所有關鍵字（AND） | 找南澳國小預算相關檔案 |
| `pdf -2023` | 找PDF，排除2023年檔案 | pdf 但不含2023 |
| `gavin49 \| Senior` | 任一帳號（OR） | gavin49 或 Senior 帳號 |
| `預算 \| 經費` | 包含任一關鍵字 | 預算 或 經費 |

**操作方式**：
- 🖱️ **本地檔案**：點「📋複製路徑」→ `Cmd+Shift+G` 貼上開啟
- 🔗 **Google Drive**：直接點連結在新分頁開啟
- 📁 **樹狀檢視**：清空搜尋框自動顯示資料夾結構

## ⚙️ 自動化排程

### macOS/Linux (crontab)
```


# 編輯排程：crontab -e

# 每天上午9點執行 pCloud

0 9 * * * /path/to/scan_pcloud.py >> /tmp/pcloud.log 2>\&1

# 每週一執行 iCloud

0 9 * * 1 /path/to/scan_icloud_drive.sh >> /tmp/icloud.log 2>\&1

```

### Google Drive (GAS 觸發器)
```

專案 → 觸發器 → 新增觸發器 → 每日 → generateObsidianIndex_v4_AutoUpdate

```

## 🆘 常見問題排除

| 問題 | 解決方案 |
|------|----------|
| `找不到 Obsidian vault` | 檢查 `OBSIDIAN_VAULT` 路徑是否正確 |
| `pCloud 連線失敗` | 修改 `endpoint='api'`（美國伺服器） |
| `權限不足` | `chmod +x 腳本檔案` |
| `搜尋沒結果` | 確認 `Drive_Index/` 有 `.md` 檔案 |
| `Windows 無法執行 sh` | 安裝 Git Bash 或 WSL Ubuntu |

## 📋 檢查清單

- [ ] Obsidian Vault 已建立 `Drive_Index/` 資料夾
- [ ] `00myGD.md` 已放在 Vault 根目錄
- [ ] Dataview 插件已啟用
- [ ] 至少執行一個雲端掃描（建議從 Google Drive 開始）
- [ ] 開啟 `00myGD.md` 確認顯示檔案清單

## 📄 授權與貢獻

```

MIT License - 歡迎 fork、改進、分享！
如有問題請開 Issue 或 Pull Request

```

<div align="center">

**⭐ 給個 Star 支持開發！感謝您的使用！**

![Demo GIF](demo.gif)

</div>
```
