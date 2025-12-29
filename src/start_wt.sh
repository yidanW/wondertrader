#!/bin/bash
# WonderTrader 快速启动脚本

# 设置动态库路径（包括编译目录和系统依赖库）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/build_debug/build_x64/Debug/bin"
export LD_LIBRARY_PATH="${BIN_DIR}/WtRunner:${BIN_DIR}/WtRunner/parsers:${BIN_DIR}/WtRunner/traders:${BIN_DIR}/WtRunner/executer:/home/mydeps/lib:$LD_LIBRARY_PATH"

# 检查程序类型
PROGRAM_TYPE=${1:-WtRunner}
shift

# 配置文件目录（优先使用 dist 目录，如果没有则使用当前目录）
DIST_DIR="${SCRIPT_DIR}/../dist"
CONFIG_DIR=""

case $PROGRAM_TYPE in
    bt|backtest)
        cd "${BIN_DIR}/WtBtRunner"
        # 检查配置文件是否存在，如果不存在则从 dist 目录复制
        if [ ! -f "configbt.yaml" ] && [ -f "${DIST_DIR}/WtBtRunner/configbt.yaml" ]; then
            cp "${DIST_DIR}/WtBtRunner/configbt.yaml" .
            echo "已从 dist 目录复制 configbt.yaml"
        fi
        if [ ! -f "logcfgbt.yaml" ] && [ -f "${DIST_DIR}/WtBtRunner/logcfgbt.yaml" ]; then
            cp "${DIST_DIR}/WtBtRunner/logcfgbt.yaml" .
            echo "已从 dist 目录复制 logcfgbt.yaml"
        fi
        ./WtBtRunner -c configbt.yaml -l logcfgbt.yaml "$@"
        ;;
    uft|ultra)
        cd "${BIN_DIR}/WtUftRunner"
        # 设置 UFT 相关的库路径
        export LD_LIBRARY_PATH="${BIN_DIR}/WtUftRunner:${BIN_DIR}/WtUftRunner/parsers:${BIN_DIR}/WtUftRunner/traders:${BIN_DIR}/WtUftRunner/uft:$LD_LIBRARY_PATH"
        # 检查配置文件是否存在
        if [ ! -f "config.yaml" ] && [ -f "${DIST_DIR}/WtUftRunner/config.yaml" ]; then
            cp "${DIST_DIR}/WtUftRunner/config.yaml" .
            echo "已从 dist 目录复制 config.yaml"
        fi
        if [ ! -f "logcfg.yaml" ] && [ -f "${DIST_DIR}/WtUftRunner/logcfg.yaml" ]; then
            cp "${DIST_DIR}/WtUftRunner/logcfg.yaml" .
            echo "已从 dist 目录复制 logcfg.yaml"
        fi
        ./WtUftRunner -c config.yaml -l logcfg.yaml "$@"
        ;;
    quote|data)
        cd "${BIN_DIR}/QuoteFactory"
        # 设置 QuoteFactory 相关的库路径
        export LD_LIBRARY_PATH="${BIN_DIR}/QuoteFactory:${BIN_DIR}/QuoteFactory/parsers:$LD_LIBRARY_PATH"
        # 检查配置文件是否存在
        if [ ! -f "dtcfg.yaml" ] && [ -f "${DIST_DIR}/QuoteFactory/dtcfg.yaml" ]; then
            cp "${DIST_DIR}/QuoteFactory/dtcfg.yaml" .
            echo "已从 dist 目录复制 dtcfg.yaml"
        fi
        if [ ! -f "logcfgdt.yaml" ] && [ -f "${DIST_DIR}/QuoteFactory/logcfgdt.yaml" ]; then
            cp "${DIST_DIR}/QuoteFactory/logcfgdt.yaml" .
            echo "已从 dist 目录复制 logcfgdt.yaml"
        fi
        ./QuoteFactory -c dtcfg.yaml -l logcfgdt.yaml "$@"
        ;;
    *)
        cd "${BIN_DIR}/WtRunner"
        # 检查配置文件是否存在，如果不存在则从 dist 目录复制
        if [ ! -f "config.yaml" ]; then
            if [ -f "${DIST_DIR}/WtRunnerCta/config.yaml" ]; then
                cp "${DIST_DIR}/WtRunnerCta/config.yaml" .
                echo "已从 dist 目录复制 config.yaml（来自 WtRunnerCta）"
            elif [ -f "${DIST_DIR}/WtRunnerHft/config.yaml" ]; then
                cp "${DIST_DIR}/WtRunnerHft/config.yaml" .
                echo "已从 dist 目录复制 config.yaml（来自 WtRunnerHft）"
            else
                echo "警告: 未找到 config.yaml，程序可能无法正常运行"
            fi
        fi
        if [ ! -f "logcfg.yaml" ]; then
            if [ -f "${DIST_DIR}/WtRunnerCta/logcfg.yaml" ]; then
                cp "${DIST_DIR}/WtRunnerCta/logcfg.yaml" .
                echo "已从 dist 目录复制 logcfg.yaml（来自 WtRunnerCta）"
            elif [ -f "${DIST_DIR}/WtRunnerHft/logcfg.yaml" ]; then
                cp "${DIST_DIR}/WtRunnerHft/logcfg.yaml" .
                echo "已从 dist 目录复制 logcfg.yaml（来自 WtRunnerHft）"
            else
                echo "警告: 未找到 logcfg.yaml，将使用默认日志配置"
            fi
        fi
        ./WtRunner -c config.yaml -l logcfg.yaml "$@"
        ;;
esac

