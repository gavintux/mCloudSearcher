```dataviewjs
// ================= 設定區 =================
const indexFiles = [
    "/Drive_Index/Drive_Index_gavin49.md",
    "/Drive_Index/Drive_Index_93.md",
    "/Drive_Index/Drive_Index_tmail.md",
    "/Drive_Index/Drive_Index_iCloud.md",
    "/Drive_Index/Drive_Index_Senior.md",
    "/Drive_Index/Drive_Index_pCloud.md",
    "/Drive_Index/Drive_Index_Dropbox.md",
];
// ==========================================

const container = this.container;
container.innerHTML = "";
container.style.fontFamily = "var(--font-interface)";

// 1. 讀取並合併所有索引檔
let merged = await loadAllIndexes(indexFiles);

if (!merged || merged.files.length === 0) {
    container.createEl("div", { 
        text: `⚠️ 無法讀取任何索引檔，請確認四個帳號的 GAS 腳本已執行，且檔案已同步到 /Drive_Index/ 資料夾。`, 
        attr: { style: "color: var(--text-error); padding: 20px; border: 1px dashed red;" } 
    });
} else {
    const { files, rootFolders, updateTimeText } = merged;

    // 2. 標題列（顯示多帳號 & 最後更新時間摘要）
    const headerEl = container.createEl("div", { 
        attr: { 
            style: "display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 15px; border-bottom: 2px solid var(--interactive-accent); padding-bottom: 5px;" 
        } 
    });
    headerEl.createEl("h2", { text: "🔍 多帳號 Drive 檔案搜尋儀表板", attr: { style: "margin: 0;" } });
    headerEl.createEl("span", { text: `📅 資料時間: ${updateTimeText}`, attr: { style: "font-size: 0.8em; color: var(--text-muted); text-align: right;" } });

    // 3. 搜尋框
    const inputEl = container.createEl("input", {
        type: "text",
        placeholder: "輸入關鍵字... (支援: 南澳 預算 | pdf -2023 [gavin49])",
        attr: { 
            style: "width: 100%; padding: 10px; font-size: 1.1em; border: 1px solid var(--background-modifier-border); border-radius: 5px; background: var(--background-primary); margin-bottom: 10px;" 
        }
    });

    const resultsEl = container.createEl("div");

    // 初始化顯示 (目錄樹)
    renderView("");

    // 監聽輸入
    inputEl.addEventListener("input", (e) => {
        renderView(e.target.value);
    });

    // --- 渲染控制 ---
    function renderView(keyword) {
        resultsEl.innerHTML = "";
        if (!keyword || keyword.trim() === "") {
            renderTreeMode();
        } else {
            renderSearchMode(keyword);
        }
    }

    // --- 模式 A: 搜尋清單 ---
    function renderSearchMode(keyword) {
        const rawTerms = keyword.toLowerCase().split(" ");
        const matched = files.filter(f => {
            const text = `[${f.account}] ` + (f.name + " " + f.fullPath).toLowerCase();
            return rawTerms.every(term => {
                if (!term) return true;
                if (term.startsWith("-")) return !text.includes(term.substring(1));  // 排除
                if (term.includes("|")) return term.split("|").some(t => text.includes(t)); // OR
                return text.includes(term); // AND
            });
        });

        if (matched.length === 0) {
            resultsEl.createEl("div", { text: "❌ 找不到符合條件的檔案", attr: { style: "padding: 10px; color: var(--text-muted);" } });
            return;
        }

        resultsEl.createEl("div", { 
            text: `📊 找到 ${matched.length} 筆資料（來自 ${new Set(matched.map(m => m.account)).size} 個帳號）`, 
            attr: { style: "font-weight: bold; margin-bottom: 5px; color: var(--text-accent);" } 
        });

        const limit = 200; // 顯示限制
        const listEl = resultsEl.createEl("div");
        
matched.slice(0, limit).forEach(f => {
    const row = listEl.createEl("div", { attr: { style: "padding: 5px 0; border-bottom: 1px solid var(--background-modifier-border);" } });
    const icon = getIcon(f.name);
    
    // 判斷是否為本機檔案
    const isLocal = f.url && f.url.startsWith('file://');
    
    // 建立第一行
    const firstLine = row.createEl("div");
    firstLine.innerHTML = `${icon} <span style="font-size:0.8em; color:var(--text-muted);">[${f.account}]</span> `;
    
    if (isLocal) {
        // 本機檔案：顯示檔名 + 複製路徑按鈕
        firstLine.innerHTML += `<span style="font-weight: 500; font-size: 1.05em; color: var(--text-normal);">${f.name}</span>`;
        
        const copyBtn = firstLine.createEl("button", { 
            text: "📋 複製路徑",
            attr: { 
                style: "margin-left: 8px; padding: 2px 8px; font-size: 0.8em; border-radius: 3px; border: 1px solid var(--background-modifier-border); background: var(--interactive-accent); color: white; cursor: pointer;"
            }
        });
        
        copyBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            // 解碼 URL（把 %20 等轉回正常字元）
            const filePath = decodeURIComponent(f.url.replace('file://', ''));
            
            try {
                // 複製到剪貼簿
                await navigator.clipboard.writeText(filePath);
                
                // 顯示成功提示
                new Notice('✅ 已複製路徑！\n\n開啟方式：\n1. 按 Cmd+Space 開啟 Spotlight\n2. 輸入 "Finder" 並按 Enter\n3. 按 Cmd+Shift+G\n4. 按 Cmd+V 貼上路徑\n5. 按 Enter 開啟檔案', 8000);
                
                // 改變按鈕狀態
                copyBtn.textContent = '✅ 已複製';
                copyBtn.style.background = 'green';
                setTimeout(() => {
                    copyBtn.textContent = '📋 複製路徑';
                    copyBtn.style.background = 'var(--interactive-accent)';
                }, 2000);
            } catch (err) {
                new Notice('❌ 複製失敗：' + err.message);
            }
        });
        
        // 加一個「在 Finder 顯示」的輔助提示
        const hintSpan = firstLine.createEl("span", {
            text: "💡",
            attr: {
                style: "margin-left: 5px; font-size: 0.8em; cursor: help;",
                title: "點擊「複製路徑」後，按 Cmd+Space → Finder → Cmd+Shift+G → Cmd+V → Enter"
            }
        });
        
    } else {
        // Google Drive 檔案：用超連結
        firstLine.innerHTML += `<a href="${f.url}" target="_blank" style="font-weight: 500; font-size: 1.05em;">${f.name}</a>`;
    }
    
    // 建立第二行：路徑
    row.createEl("div", { 
        text: f.fullPath, 
        attr: { style: "font-size: 0.8em; color: var(--text-muted); margin-left: 22px;" } 
    });
});

        
        if (matched.length > limit) {
            resultsEl.createEl("div", { text: `(還有 ${matched.length - limit} 筆未顯示...)`, attr: { style: "color: var(--text-muted); font-style: italic; margin-top: 5px;" } });
        }
    }

    // --- 模式 B: 目錄樹 ---
    function renderTreeMode() {
        // 顯示統計資訊
        const rootList = Array.from(rootFolders).sort().join(", ");
        const accountList = Array.from(new Set(files.map(f => f.account))).sort().join(", ");
        resultsEl.createEl("div", { 
            text: `🗂️ 索引範圍：帳號 [${accountList}]，根目錄 [${rootList}] 等共 ${files.length} 個檔案`, 
            attr: { style: "font-size: 0.85em; color: var(--text-muted); margin-bottom: 10px; border-bottom: 1px dashed var(--background-modifier-border); padding-bottom: 5px;" } 
        });

        const root = { _sub: {}, _files: [], _count: 0 };
        for (const f of files) {
            let curr = root;
            // 把帳號當成最外層
            const allParts = [ `[${f.account}]`, ...f.parts ];
            for (const folder of allParts) {
                if (!curr._sub[folder]) curr._sub[folder] = { _sub: {}, _files: [], _count: 0 };
                curr = curr._sub[folder];
                curr._count++;
            }
            curr._files.push(f);
        }

        let html = "";
        for (const key of Object.keys(root._sub).sort()) {
            html += renderNode(root._sub[key], key, 1);
        }
        
        const treeContent = resultsEl.createEl("div");
        treeContent.innerHTML = html || "<p style='padding:10px;'>沒有資料，請確認索引檔內容。</p>";
    }

    function renderNode(node, name, depth) {
        // 第一層強制展開
        const openAttr = depth < 2 ? "open" : "";
        
        let summaryStyle = "cursor: pointer; font-weight: 600; color: var(--text-accent); padding: 4px 8px;";
        let borderStyle = "1px solid rgba(130,130,130,0.2)";
        
        if (depth === 1) {
             borderStyle = "3px solid var(--interactive-accent)";
             summaryStyle += " font-size: 1.1em;";
        }

        const count = node._count > 0 ? `<span style="font-size:0.8em; color:gray; margin-left:5px;">(${node._count})</span>` : "";
        
        let html = `<details ${openAttr} style="margin-left: 10px; border-left: ${borderStyle}; margin-bottom: 2px;">
            <summary style="${summaryStyle}">📂 ${name} ${count}</summary>`;

        for (const sub of Object.keys(node._sub).sort()) {
            html += renderNode(node._sub[sub], sub, depth + 1);
        }

        if (node._files.length > 0) {
            html += `<div style="margin-left: 24px; padding: 2px 0;">`;
            for (const f of node._files) {
                html += `<div style="padding: 2px 0;">${getIcon(f.name)} <a href="${f.url}" target="_blank" style="text-decoration: none; color: var(--text-normal);">${f.name}</a></div>`;
            }
            html += `</div>`;
        }
        return html + "</details>";
    }

    function getIcon(n) {
        if (n.endsWith(".pdf")) return "📕";
        if (n.match(/\.(doc|docx)$/i)) return "📝";
        if (n.match(/\.(xls|xlsx|csv)$/i)) return "📊";
        if (n.match(/\.(ppt|pptx)$/i)) return "📢";
        if (n.match(/\.(jpg|png|jpeg|gif)$/i)) return "🖼️";
        if (n.match(/\.(mp4|mov)$/i)) return "🎬";
        if (n.match(/\.(zip|rar|7z)$/i)) return "📦";
        return "📄";
    }
}

// ====== 輔助：讀取多個索引檔並合併 ======
async function loadAllIndexes(indexFiles) {
    const files = [];
    const rootFolders = new Set();
    const updateTimes = [];

    for (const path of indexFiles) {
        let content;
        try {
            content = await dv.io.load(path);
        } catch (e) {
            continue; // 有檔沒同步到就略過
        }
        if (!content) continue;

        // 從檔案路徑推回帳號名稱（你現在的命名規則）
        let account = "unknown";
        const m = path.match(/Drive_Index_(.+)\.md$/);
        if (m) account = m[1];

        // 抓 header 的最後同步時間（格式依你 GAS 的輸出）
        const timeMatch = content.match(/🔄 最後同步時間：(.*)/);
        if (timeMatch) updateTimes.push(timeMatch[1].trim());

        const regex = /file_name: (.*)\nurl: (.*)\npath: (.*)/g;
        let match;
        while ((match = regex.exec(content)) !== null) {
            const fName = match[1].trim();
            const fUrl = match[2].trim();
            const fPath = match[3].trim();

            const parts = fPath.split("/").filter(p => p && p.trim() !== "");
            if (parts.length > 0) rootFolders.add(parts[0]);

            files.push({
                name: fName,
                url: fUrl,
                parts: parts,
                fullPath: fPath,
                account: account,
            });
        }
    }

    // 簡單處理 updateTimeText：把各檔案時間串起來
    const updateTimeText = updateTimes.length > 0 ? updateTimes.join(" / ") : "未知";

    return { files, rootFolders, updateTimeText };
}
```