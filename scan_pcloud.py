#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
pCloud 索引產生腳本
功能：掃描 pCloud 雲端資料夾，產生 Markdown 索引檔
"""

import os
from datetime import datetime
from pcloud import PyCloud

# ===== 設定區 =====
PCLOUD_EMAIL = "youraccount@gmail.com"
PCLOUD_PASSWORD = "password"
OBSIDIAN_VAULT = "/Users/xxxxx/Obsidian/zenlife"
OUTPUT_FILE = os.path.join(OBSIDIAN_VAULT, "Drive_Index", "Drive_Index_pCloud.md")
ACCOUNT_NAME = "pCloud_personal"
ROOT_FOLDER_ID = 0  # 0 代表根目錄

# ★ 修正：使用明確的 endpoint（試試看 'eapi' 歐洲伺服器）
try:
    pc = PyCloud(PCLOUD_EMAIL, PCLOUD_PASSWORD, endpoint='eapi')
    print("✅ 已連線到 pCloud (歐洲伺服器)")
except Exception as e:
    print(f"⚠️ 歐洲伺服器連線失敗，嘗試美國伺服器...")
    try:
        pc = PyCloud(PCLOUD_EMAIL, PCLOUD_PASSWORD, endpoint='api')
        print("✅ 已連線到 pCloud (美國伺服器)")
    except Exception as e2:
        print(f"❌ 連線失敗: {e2}")
        exit(1)

def scan_folder(folder_id, path=""):
    """遞迴掃描資料夾"""
    try:
        folder_data = pc.listfolder(folderid=folder_id)
        
        if 'metadata' not in folder_data:
            return []
        
        items = []
        contents = folder_data['metadata'].get('contents', [])
        
        for item in contents:
            item_name = item.get('name', 'Unknown')
            is_folder = item.get('isfolder', False)
            
            if is_folder:
                # 遞迴掃描子資料夾
                subfolder_id = item.get('folderid')
                new_path = f"{path}/{item_name}" if path else item_name
                print(f"   📁 掃描資料夾: {new_path}")
                items.extend(scan_folder(subfolder_id, new_path))
            else:
                # 檔案
                file_id = item.get('fileid', '')
                file_path = f"{path}/{item_name}" if path else item_name
                
                # pCloud 檔案連結格式
                file_link = f"https://my.pcloud.com/#page=filemanager&fileid={file_id}"
                
                items.append({
                    'name': item_name,
                    'url': file_link,
                    'path': file_path,
                    'file_id': file_id,
                    'size': item.get('size', 0),
                    'modified': item.get('modified', '')
                })
        
        return items
        
    except Exception as e:
        print(f"❌ 掃描資料夾 {folder_id} 時發生錯誤: {e}")
        return []

def main():
    print("🔍 開始掃描 pCloud...")
    print(f"來源: pCloud 根目錄 (ID: {ROOT_FOLDER_ID})")
    print(f"目標: {OUTPUT_FILE}")
    
    # 確保 Drive_Index 資料夾存在
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    
    # 掃描檔案
    files = scan_folder(ROOT_FOLDER_ID)
    
    # 產生 Markdown 索引檔
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("# pCloud 檔案索引\n\n")
        f.write(f"> 索引帳號: **{ACCOUNT_NAME}**\n")
        f.write(f"> 🔄 最後同步時間：{current_time}\n")
        f.write("> 索引模式：API 遠端掃描\n\n")
        
        for file in files:
            f.write(f"file_name: {file['name']}\n")
            f.write(f"url: {file['url']}\n")
            f.write(f"path: {file['path']}\n")
            f.write("\n")
    
    print(f"✅ 索引檔已產生")
    print(f"📊 統計：")
    print(f"   - 索引檔案數: {len(files)}")
    print(f"📁 輸出路徑: {OUTPUT_FILE}")
    print(f"🔄 完成時間: {current_time}")

if __name__ == "__main__":
    main()

