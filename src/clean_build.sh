#!/bin/bash

# 清理 CMake 构建产物脚本

echo "开始清理构建产物..."

# 清理 build_debug 目录
if [ -d "./build_debug" ]; then
    echo "删除 build_debug 目录..."
    rm -rf ./build_debug
    echo "✓ build_debug 已清理"
else
    echo "build_debug 目录不存在，跳过"
fi

# 清理 build_all 目录（Release 构建）
if [ -d "./build_all" ]; then
    echo "删除 build_all 目录..."
    rm -rf ./build_all
    echo "✓ build_all 已清理"
else
    echo "build_all 目录不存在，跳过"
fi

# 清理 build_for_clangd 目录
if [ -d "./build_for_clangd" ]; then
    echo "删除 build_for_clangd 目录..."
    rm -rf ./build_for_clangd
    echo "✓ build_for_clangd 已清理"
else
    echo "build_for_clangd 目录不存在，跳过"
fi

# 清理 CMake 缓存文件（如果存在）
if [ -f "./CMakeCache.txt" ]; then
    echo "删除 CMakeCache.txt..."
    rm -f ./CMakeCache.txt
    echo "✓ CMakeCache.txt 已清理"
fi

# 清理 CMakeFiles 目录（如果存在）
if [ -d "./CMakeFiles" ]; then
    echo "删除 CMakeFiles 目录..."
    rm -rf ./CMakeFiles
    echo "✓ CMakeFiles 已清理"
fi

# 清理 Makefile（如果存在）
if [ -f "./Makefile" ]; then
    echo "删除 Makefile..."
    rm -f ./Makefile
    echo "✓ Makefile 已清理"
fi

echo ""
echo "清理完成！"

