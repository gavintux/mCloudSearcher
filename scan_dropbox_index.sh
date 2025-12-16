#!/bin/bash
# scan_dropbox_index.sh
# 掃描 Dropbox 並生成指定格式的索引

DROPBOX_PATH="$HOME/Library/CloudStorage/Dropbox"
OUTPUT_FILE="$HOME/Obsidian/zenlife/Drive_Index/Drive_Index_dropbox.md"
ACCOUNT_NAME="Dropbox_personal"
SYNC_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 檢查 Dropbox 路徑
if [ ! -d "$DROPBOX_PATH" ]; then
    echo "❌ 錯誤：找不到 Dropbox 路徑：$DROPBOX_PATH"
    exit 1
fi

echo "🔍 掃描 Dropbox 中..."

# 建立輸出檔案
{
    echo "> 索引帳號: **$ACCOUNT_NAME**"
    echo "> 🔄 最後同步時間：$SYNC_TIME"
    echo "> 索引模式：本地掃描"
    echo ""
    
    # 掃描所有文件
    find "$DROPBOX_PATH" -type f \( \
        -name "*.md" -o -name "*.txt" -o -name "*.pdf" -o \
        -name "*.doc" -o -name "*.docx" -o -name "*.xls" -o \
        -name "*.xlsx" -o -name "*.jpg" -o -name "*.png" -o \
        -name "*.gif" -o -name "*.mov" -o -name "*.mp4" -o \
        -name "*.pptx" -o -name "*.heic" -o -name "*.jpeg" \
    \) | sort | while read file; do
        file_name=$(basename "$file")
        relative_path="${file#$DROPBOX_PATH/}"
        file_url="file://$file"
        
        echo "file_name: $file_name"
        echo "url: $file_url"
        echo "path: $relative_path"
        echo ""
    done
    
} > "$OUTPUT_FILE"

# 計算文件數量
file_count=$(find "$DROPBOX_PATH" -type f \( \
    -name "*.md" -o -name "*.txt" -o -name "*.pdf" -o \
    -name "*.doc" -o -name "*.docx" -o -name "*.xls" -o \
    -name "*.xlsx" -o -name "*.jpg" -o -name "*.png" -o \
    -name "*.gif" -o -name "*.mov" -o -name "*.mp4" -o \
    -name "*.pptx" -o -name "*.heic" -o -name "*.jpeg" \
\) | wc -l)

echo "✅ 找到 $file_count 個文件"
echo "📄 索引已生成：$OUTPUT_FILE"

