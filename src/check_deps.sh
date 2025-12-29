#!/bin/bash
# 检查动态库依赖脚本

echo "=========================================="
echo "检查 WonderTrader 动态库依赖"
echo "=========================================="

BIN_DIR="./build_debug/build_x64/Debug/bin"
DEPS_LIB="/home/mydeps/lib"

# 检查依赖库目录
echo "1. 检查依赖库目录..."
if [ -d "$DEPS_LIB" ]; then
    echo "   ✓ 依赖库目录存在: $DEPS_LIB"
else
    echo "   ✗ 依赖库目录不存在: $DEPS_LIB"
    exit 1
fi

# 检查 Boost 库
echo ""
echo "2. 检查 Boost 库..."
BOOST_LIBS=("libboost_filesystem.so.1.72.0" "libboost_thread.so.1.72.0" "libboost_system.so.1.72.0")
for lib in "${BOOST_LIBS[@]}"; do
    if [ -f "$DEPS_LIB/$lib" ] || [ -L "$DEPS_LIB/$lib" ]; then
        echo "   ✓ $lib"
    else
        echo "   ✗ $lib 未找到"
    fi
done

# 检查 nanomsg 库
echo ""
echo "3. 检查 nanomsg 库..."
if [ -f "$DEPS_LIB/libnanomsg.so" ] || [ -L "$DEPS_LIB/libnanomsg.so" ]; then
    echo "   ✓ libnanomsg.so"
else
    echo "   ✗ libnanomsg.so 未找到"
fi

# 检查可执行文件
echo ""
echo "4. 检查可执行文件..."
if [ -f "$BIN_DIR/WtRunner/WtRunner" ]; then
    echo "   ✓ WtRunner"
    
    # 检查动态库依赖
    echo ""
    echo "5. 检查 WtRunner 的动态库依赖..."
    MISSING=$(ldd "$BIN_DIR/WtRunner/WtRunner" 2>/dev/null | grep "not found" || echo "")
    if [ -z "$MISSING" ]; then
        echo "   ✓ 所有动态库都能找到"
    else
        echo "   ✗ 以下库未找到："
        echo "$MISSING" | sed 's/^/      /'
        echo ""
        echo "   解决方案："
        echo "   export LD_LIBRARY_PATH=$DEPS_LIB:\$LD_LIBRARY_PATH"
    fi
else
    echo "   ✗ WtRunner 未找到，请先编译项目"
fi

echo ""
echo "=========================================="
