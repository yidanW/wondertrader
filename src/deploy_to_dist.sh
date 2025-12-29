#!/bin/bash
# 将编译好的文件部署到 dist 目录

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$SCRIPT_DIR"
DIST_DIR="$PROJECT_ROOT/dist"
BUILD_DIR="$SRC_DIR/build_debug/build_x64/Debug/bin"

echo "=========================================="
echo "部署编译文件到 dist 目录"
echo "=========================================="
echo "源目录: $BUILD_DIR"
echo "目标目录: $DIST_DIR"
echo ""

# 检查源目录是否存在
if [ ! -d "$BUILD_DIR" ]; then
    echo "错误: 编译目录不存在: $BUILD_DIR"
    echo "请先运行 ./build_debug.sh 编译项目"
    exit 1
fi

# 创建 dist 目录结构
echo "创建 dist 目录结构..."
mkdir -p "$DIST_DIR/WtRunner"
mkdir -p "$DIST_DIR/WtRunner/parsers"
mkdir -p "$DIST_DIR/WtRunner/traders"
mkdir -p "$DIST_DIR/WtRunner/executer"
mkdir -p "$DIST_DIR/WtBtRunner"
mkdir -p "$DIST_DIR/WtUftRunner"
mkdir -p "$DIST_DIR/WtUftRunner/parsers"
mkdir -p "$DIST_DIR/WtUftRunner/traders"
mkdir -p "$DIST_DIR/WtUftRunner/uft"
mkdir -p "$DIST_DIR/QuoteFactory"
mkdir -p "$DIST_DIR/QuoteFactory/parsers"
mkdir -p "$DIST_DIR/LoaderRunner"

# 部署 WtRunner
echo ""
echo "部署 WtRunner..."
if [ -f "$BUILD_DIR/WtRunner/WtRunner" ]; then
    cp -v "$BUILD_DIR/WtRunner/WtRunner" "$DIST_DIR/WtRunner/"
    echo "  ✓ WtRunner 可执行文件"
    
    # 复制库文件
    if [ -d "$BUILD_DIR/WtRunner/parsers" ]; then
        cp -rv "$BUILD_DIR/WtRunner/parsers"/*.so "$DIST_DIR/WtRunner/parsers/" 2>/dev/null || true
        echo "  ✓ parsers 库文件"
    fi
    
    if [ -d "$BUILD_DIR/WtRunner/traders" ]; then
        cp -rv "$BUILD_DIR/WtRunner/traders"/*.so "$DIST_DIR/WtRunner/traders/" 2>/dev/null || true
        echo "  ✓ traders 库文件"
    fi
    
    if [ -d "$BUILD_DIR/WtRunner/executer" ]; then
        cp -rv "$BUILD_DIR/WtRunner/executer"/*.so "$DIST_DIR/WtRunner/executer/" 2>/dev/null || true
        echo "  ✓ executer 库文件"
    fi
    
    # 复制其他库文件
    for lib in libWtDataStorage.so libWtDataStorageAD.so libWtMsgQue.so libWtRiskMonFact.so; do
        if [ -f "$BUILD_DIR/WtRunner/$lib" ]; then
            cp -v "$BUILD_DIR/WtRunner/$lib" "$DIST_DIR/WtRunner/"
        fi
    done
    
    # 创建并复制 CTA 策略库
    mkdir -p "$DIST_DIR/WtRunner/cta"
    STRATEGY_LIB="$BUILD_DIR/build_x64/Debug/bin/libWtCtaStraFact.so"
    if [ -f "$STRATEGY_LIB" ]; then
        cp -v "$STRATEGY_LIB" "$DIST_DIR/WtRunner/cta/"
        echo "  ✓ CTA 策略库已部署"
    else
        echo "  ⚠ CTA 策略库未找到: $STRATEGY_LIB"
    fi
else
    echo "  ✗ WtRunner 未找到"
fi

# 部署 WtBtRunner
echo ""
echo "部署 WtBtRunner..."
if [ -f "$BUILD_DIR/WtBtRunner/WtBtRunner" ]; then
    cp -v "$BUILD_DIR/WtBtRunner/WtBtRunner" "$DIST_DIR/WtBtRunner/"
    echo "  ✓ WtBtRunner 可执行文件"
    
    # 复制策略工厂库
    for lib in libWtCtaStraFact.so libWtHftStraFact.so libWtUftStraFact.so libWtSelStraFact.so; do
        if [ -f "$BUILD_DIR/WtBtRunner/$lib" ]; then
            cp -v "$BUILD_DIR/WtBtRunner/$lib" "$DIST_DIR/WtBtRunner/"
        fi
    done
else
    echo "  ✗ WtBtRunner 未找到"
fi

# 部署 WtUftRunner
echo ""
echo "部署 WtUftRunner..."
if [ -f "$BUILD_DIR/WtUftRunner/WtUftRunner" ]; then
    cp -v "$BUILD_DIR/WtUftRunner/WtUftRunner" "$DIST_DIR/WtUftRunner/"
    echo "  ✓ WtUftRunner 可执行文件"
    
    if [ -d "$BUILD_DIR/WtUftRunner/parsers" ]; then
        cp -rv "$BUILD_DIR/WtUftRunner/parsers"/*.so "$DIST_DIR/WtUftRunner/parsers/" 2>/dev/null || true
        echo "  ✓ parsers 库文件"
    fi
    
    if [ -d "$BUILD_DIR/WtUftRunner/traders" ]; then
        cp -rv "$BUILD_DIR/WtUftRunner/traders"/*.so "$DIST_DIR/WtUftRunner/traders/" 2>/dev/null || true
        echo "  ✓ traders 库文件"
    fi
    
    if [ -d "$BUILD_DIR/WtUftRunner/uft" ]; then
        cp -rv "$BUILD_DIR/WtUftRunner/uft"/*.so "$DIST_DIR/WtUftRunner/uft/" 2>/dev/null || true
        echo "  ✓ uft 库文件"
    fi
else
    echo "  ✗ WtUftRunner 未找到"
fi

# 部署 QuoteFactory
echo ""
echo "部署 QuoteFactory..."
if [ -f "$BUILD_DIR/QuoteFactory/QuoteFactory" ]; then
    cp -v "$BUILD_DIR/QuoteFactory/QuoteFactory" "$DIST_DIR/QuoteFactory/"
    echo "  ✓ QuoteFactory 可执行文件"
    
    if [ -d "$BUILD_DIR/QuoteFactory/parsers" ]; then
        cp -rv "$BUILD_DIR/QuoteFactory/parsers"/*.so "$DIST_DIR/QuoteFactory/parsers/" 2>/dev/null || true
        echo "  ✓ parsers 库文件"
    fi
    
    if [ -f "$BUILD_DIR/QuoteFactory/libWtDataStorage.so" ]; then
        cp -v "$BUILD_DIR/QuoteFactory/libWtDataStorage.so" "$DIST_DIR/QuoteFactory/"
    fi
else
    echo "  ✗ QuoteFactory 未找到"
fi

# 部署 LoaderRunner
echo ""
echo "部署 LoaderRunner..."
if [ -f "$BUILD_DIR/Loader/LoaderRunner" ]; then
    cp -v "$BUILD_DIR/Loader/LoaderRunner" "$DIST_DIR/LoaderRunner/"
    echo "  ✓ LoaderRunner 可执行文件"
    
    if [ -d "$BUILD_DIR/Loader" ]; then
        cp -rv "$BUILD_DIR/Loader"/*.so "$DIST_DIR/LoaderRunner/" 2>/dev/null || true
        echo "  ✓ Loader 库文件"
    fi
else
    echo "  ✗ LoaderRunner 未找到"
fi

# 设置可执行权限
echo ""
echo "设置可执行权限..."
find "$DIST_DIR" -type f -name "WtRunner" -o -name "WtBtRunner" -o -name "WtUftRunner" -o -name "QuoteFactory" -o -name "LoaderRunner" | while read file; do
    chmod +x "$file"
    echo "  ✓ $(basename $file)"
done

echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo ""
echo "部署位置: $DIST_DIR"
echo ""
echo "运行方法："
echo "  cd $DIST_DIR/WtRunner"
echo "  export LD_LIBRARY_PATH=/home/mydeps/lib:\$LD_LIBRARY_PATH"
echo "  ./WtRunner -c config.yaml -l logcfg.yaml"
echo ""
echo "或使用 dist 目录下的启动脚本（如果存在）"

