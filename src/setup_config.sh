#!/bin/bash
# 设置 WtRunner 配置文件脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/../dist"
WTRUNNER_DIR="${DIST_DIR}/WtRunner"

echo "=========================================="
echo "设置 WtRunner 配置文件"
echo "=========================================="

# 检查目录是否存在
if [ ! -d "$WTRUNNER_DIR" ]; then
    echo "错误: WtRunner 目录不存在: $WTRUNNER_DIR"
    echo "请先运行部署脚本: ./deploy_to_dist.sh"
    exit 1
fi

# 复制配置文件
echo "复制配置文件..."
CONFIG_FILES=("tdparsers.yaml" "tdtraders.yaml" "executers.yaml" "actpolicy.yaml" "filters.yaml")

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "${DIST_DIR}/WtRunnerCta/$file" ]; then
        cp -v "${DIST_DIR}/WtRunnerCta/$file" "$WTRUNNER_DIR/"
        echo "  ✓ $file"
    else
        echo "  ⚠ $file 不存在，跳过"
    fi
done

# 检查是否需要创建 filters.yaml
if [ ! -f "$WTRUNNER_DIR/filters.yaml" ]; then
    echo "" > "$WTRUNNER_DIR/filters.yaml"
    echo "  ✓ 创建空的 filters.yaml"
fi

echo ""
echo "=========================================="
echo "配置文件设置完成！"
echo "=========================================="
echo ""
echo "请根据需要修改以下配置文件："
echo "  - tdparsers.yaml    # 行情解析器配置"
echo "  - tdtraders.yaml    # 交易通道配置"
echo "  - executers.yaml    # 执行器配置"
echo "  - actpolicy.yaml    # 开平策略配置"
echo "  - filters.yaml      # 过滤器配置（可选）"
echo ""
echo "配置文件位置: $WTRUNNER_DIR"






