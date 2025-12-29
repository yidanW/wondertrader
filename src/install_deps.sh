#!/bin/bash
# WonderTrader 依赖库安装脚本
# 用于安装 Boost 1.72 和其他依赖库到 /home/mydeps

set -e  # 遇到错误立即退出

DEPS_DIR="/home/mydeps"
BOOST_VERSION="1.72.0"
BOOST_DIR="boost_1_72_0"

echo "=========================================="
echo "WonderTrader 依赖库安装脚本"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "错误: 请使用 sudo 运行此脚本"
    exit 1
fi

# 创建依赖目录
echo "创建依赖目录: $DEPS_DIR"
mkdir -p ${DEPS_DIR}/{include,lib}

# 安装编译依赖
echo "安装编译依赖..."
apt-get update
apt-get install -y \
    build-essential \
    wget \
    git \
    cmake \
    libtool \
    autoconf \
    automake

# 安装 Boost 1.72
echo "=========================================="
echo "安装 Boost ${BOOST_VERSION}..."
echo "=========================================="

cd /tmp

if [ ! -f "${BOOST_DIR}.tar.gz" ]; then
    echo "下载 Boost ${BOOST_VERSION}..."
    wget https://archives.boost.io/release/${BOOST_VERSION}/source/${BOOST_DIR}.tar.gz
fi

if [ ! -d "${BOOST_DIR}" ]; then
    echo "解压 Boost..."
    tar -xzf ${BOOST_DIR}.tar.gz
fi

cd ${BOOST_DIR}

echo "配置 Boost..."
./bootstrap.sh --prefix=${DEPS_DIR}

# 应用补丁修复 GCC 13 和 glibc 2.34+ 兼容性问题
echo "应用 Boost 兼容性补丁..."
PATCH_FILE="$(dirname $0)/boost_thread_fix.patch"
if [ -f "${PATCH_FILE}" ] && [ -f "boost/thread/pthread/thread_data.hpp" ]; then
    patch -p1 < "${PATCH_FILE}" || {
        echo "补丁应用失败，尝试手动修复..."
        # 手动修复：替换 PTHREAD_STACK_MIN 检查
        sed -i '60s/#if PTHREAD_STACK_MIN > 0/#ifdef PTHREAD_STACK_MIN/' boost/thread/pthread/thread_data.hpp 2>/dev/null
        sed -i '60s/#if defined(PTHREAD_STACK_MIN) && PTHREAD_STACK_MIN > 0/#ifdef PTHREAD_STACK_MIN/' boost/thread/pthread/thread_data.hpp 2>/dev/null
        # 添加 else 分支
        if ! grep -q "sysconf(_SC_THREAD_STACK_MIN)" boost/thread/pthread/thread_data.hpp; then
            sed -i '/#ifdef PTHREAD_STACK_MIN/a\#else\n          // PTHREAD_STACK_MIN may be a function in newer glibc\n          long min_stack = sysconf(_SC_THREAD_STACK_MIN);\n          if (min_stack > 0 && size < static_cast<std::size_t>(min_stack)) {\n              size = static_cast<std::size_t>(min_stack);\n          }' boost/thread/pthread/thread_data.hpp
        fi
    }
fi

echo "编译并安装 Boost（这可能需要较长时间）..."
./b2 --prefix=${DEPS_DIR} \
     --with-filesystem \
     --with-thread \
     --with-system \
     --with-date_time \
     --with-regex \
     --with-serialization \
     --with-iostreams \
     --with-chrono \
     --with-atomic \
     cxxflags="-std=c++14 -Wno-error -Wno-nonnull -Wno-deprecated-declarations" \
     -j$(nproc) \
     install

# 验证 Boost 安装
if [ -f "${DEPS_DIR}/include/boost/smart_ptr/detail/spinlock.hpp" ]; then
    echo "✓ Boost 安装成功"
else
    echo "✗ Boost 安装失败：找不到 spinlock.hpp"
    exit 1
fi

# 安装 rapidjson
echo "=========================================="
echo "安装 rapidjson 1.1.0（代码需要 GetObject/GetArray API）..."
echo "=========================================="
cd ${DEPS_DIR}/include
if [ ! -d "rapidjson" ]; then
    # 克隆 rapidjson（仅头文件库）
    # 注意：代码使用了 GetObject()/GetArray()，这些 API 在 1.1.0+ 才支持
    git clone --branch v1.1.0 --depth 1 https://github.com/Tencent/rapidjson.git rapidjson_temp
    # 移动头文件到正确位置
    mv rapidjson_temp/include/rapidjson rapidjson
    rm -rf rapidjson_temp
    echo "✓ rapidjson 安装成功"
else
    echo "✓ rapidjson 已存在，跳过"
fi

# 验证 rapidjson 路径
if [ ! -f "${DEPS_DIR}/include/rapidjson/document.h" ]; then
    echo "警告: rapidjson 路径可能不正确，尝试修复..."
    if [ -d "${DEPS_DIR}/include/rapidjson/include/rapidjson" ]; then
        cd ${DEPS_DIR}/include
        mv rapidjson rapidjson_backup
        mv rapidjson_backup/include/rapidjson rapidjson
        rm -rf rapidjson_backup
        echo "✓ rapidjson 路径已修复"
    fi
fi

# 安装 spdlog
echo "=========================================="
echo "安装 spdlog 1.9.2..."
echo "=========================================="
cd ${DEPS_DIR}/include
if [ ! -d "spdlog" ]; then
    # 克隆 spdlog（包含子模块）
    git clone --branch v1.9.2 --depth 1 --recursive https://github.com/gabime/spdlog.git spdlog_temp
    # 移动头文件到正确位置
    mv spdlog_temp/include/spdlog spdlog
    rm -rf spdlog_temp
    echo "✓ spdlog 安装成功"
else
    echo "✓ spdlog 已存在，跳过"
fi

# 验证 spdlog fmt 路径
if [ ! -f "${DEPS_DIR}/include/spdlog/fmt/bundled/format.h" ]; then
    echo "警告: spdlog fmt 路径可能不正确，尝试修复..."
    if [ -d "${DEPS_DIR}/include/spdlog/include/spdlog" ]; then
        cd ${DEPS_DIR}/include
        mv spdlog spdlog_backup
        mv spdlog_backup/include/spdlog spdlog
        rm -rf spdlog_backup
        echo "✓ spdlog 路径已修复"
    fi
fi

# 安装 nanomsg
echo "=========================================="
echo "安装 nanomsg 1.1.5..."
echo "=========================================="
cd /tmp
if [ ! -d "nanomsg" ]; then
    git clone --branch 1.1.5 --depth 1 https://github.com/nanomsg/nanomsg.git
fi

cd nanomsg
if [ ! -d "build" ]; then
    mkdir build
fi
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=${DEPS_DIR}
make -j$(nproc)
make install

if [ -f "${DEPS_DIR}/lib/libnanomsg.so" ] || [ -f "${DEPS_DIR}/lib/libnanomsg.a" ]; then
    echo "✓ nanomsg 安装成功"
else
    echo "✗ nanomsg 安装失败"
    exit 1
fi

echo "=========================================="
echo "所有依赖库安装完成！"
echo "=========================================="
echo "安装目录: ${DEPS_DIR}"
echo ""
echo "验证安装:"
echo "  Boost:     ls ${DEPS_DIR}/include/boost/smart_ptr/detail/spinlock.hpp"
echo "  rapidjson: ls ${DEPS_DIR}/include/rapidjson"
echo "  spdlog:    ls ${DEPS_DIR}/include/spdlog"
echo "  nanomsg:   ls ${DEPS_DIR}/lib/libnanomsg.*"
echo ""
echo "现在可以运行构建脚本:"
echo "  cd /data/yidan.wang/wondertrader/src"
echo "  ./build_debug.sh"

