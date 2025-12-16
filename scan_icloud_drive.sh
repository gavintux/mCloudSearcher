#!/bin/bash
# ============================================================
# iCloud Drive 索引產生指令稿（格式統一版）
# 功能：掃描 iCloud Drive 本機資料夾，產生與 Google Drive 相同格式的 Markdown 索引檔
# ============================================================

# 設定區
ICLOUD_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
OBSIDIAN_VAULT="/Users/xxxxx/Obsidian/zenlife"
OUTPUT_FILE="$OBSIDIAN_VAULT/Drive_Index/Drive_Index_iCloud.md"
ACCOUNT_NAME="iCloud_linkc"

# 提高檔案描述符限制
ulimit -n 4096

# 檢查 iCloud Drive 資料夾是否存在
if [ ! -d "$ICLOUD_ROOT" ]; then
    echo "❌ 錯誤：找不到 iCloud Drive 資料夾"
    echo "路徑: $ICLOUD_ROOT"
    exit 1
fi

# 檢查 Obsidian vault 是否存在
if [ ! -d "$OBSIDIAN_VAULT" ]; then
    echo "❌ 錯誤：找不到 Obsidian vault 路徑"
    echo "路徑: $OBSIDIAN_VAULT"
    exit 1
fi

# 確保 Drive_Index 資料夾存在
mkdir -p "$OBSIDIAN_VAULT/Drive_Index"

echo "🔍 開始掃描 iCloud Drive..."
echo "來源: $ICLOUD_ROOT"
echo "目標: $OUTPUT_FILE"

# 取得當前時間
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 初始化 md 檔內容（使用與 Google Drive 相同的格式）
{
    echo "# iCloud Drive 檔案索引"
    echo ""
    echo "> 索引帳號: **$ACCOUNT_NAME**"
    echo "> 🔄 最後同步時間：$CURRENT_TIME"
    echo "> 索引模式：本機掃描 (macOS)"
    echo ""
    
    # 計數變數
    FILE_COUNT=0
    
    # 用 find 掃描所有檔案，並逐行處理
    find "$ICLOUD_ROOT" -type f 2>/dev/null | while IFS= read -r file; do
        # 檢查檔案是否存在（避免軟連結問題）
        if [ ! -f "$file" ]; then
            continue
        fi
        
        file_name=$(basename "$file")
        
        # 跳過特殊檔案和索引檔
        if [[ "$file_name" == "."* ]] || [[ "$file_name" == *".DS_Store" ]] || [[ "$file_name" == "iCloud_Index"* ]]; then
            continue
        fi
        
        # 取得相對路徑（相對於 iCloud 根目錄）
        file_path="${file#$ICLOUD_ROOT/}"
        
        # URL 編碼空格和特殊字元
        encoded_file=$(echo "$file" | sed 's/ /%20/g')
        
        # ★ 使用與 Google Drive 相同的格式（三行：file_name / url / path）
        echo "file_name: $file_name"
        echo "url: file://$encoded_file"
        echo "path: $file_path"
        echo ""
        
        ((FILE_COUNT++))
        
        # 每掃 100 個檔案印一次進度
        if [ $((FILE_COUNT % 100)) -eq 0 ]; then
            echo "   正在掃描... 已索引 $FILE_COUNT 個檔案" >&2
        fi
    done
    
} > "$OUTPUT_FILE"

# 統計資料夾數
FOLDER_COUNT=$(find "$ICLOUD_ROOT" -type d 2>/dev/null | wc -l | tr -d ' ')

# 統計檔案數
FILE_COUNT=$(grep -c "^file_name:" "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo "✅ 索引檔已產生"
echo "📊 統計："
echo "   - 掃描資料夾數: $FOLDER_COUNT"
echo "   - 索引檔案數: $FILE_COUNT"
echo "📁 輸出路徑: $OUTPUT_FILE"
echo "🔄 完成時間: $(date '+%Y-%m-%d %H:%M:%S')"
