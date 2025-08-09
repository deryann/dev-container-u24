#!/bin/bash

echo "測試 SSH 連線到容器..."
echo "用戶: developer"
echo "密碼: dev123456"
echo "端口: 2222"
echo ""

# 測試連線
ssh -v -o PreferredAuthentications=password -o PubkeyAuthentication=no -p 2222 developer@localhost whoami 2>&1 | head -20