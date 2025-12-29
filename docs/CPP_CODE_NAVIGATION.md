# C++ 代码跳转配置指南

## 问题
在 Cursor/VS Code 中无法跳转到 C++ 函数定义。

## 解决方案

### 方法1：使用 clangd（推荐）

#### 1. 安装 clangd

**步骤1：安装系统 clangd（如果插件安装失败）**

如果遇到 "Failed to install clangd language server" 错误，需要手动安装：

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y clangd

# 验证安装
clangd --version
```

**步骤2：安装 clangd 插件**

在 Cursor/VS Code 中：
1. 打开扩展市场（`Ctrl+Shift+X` 或 `Cmd+Shift+X`）
2. 搜索并安装 **"clangd"**（由 LLVM 开发）
3. 如果已安装 Microsoft 的 "C/C++" 扩展，建议禁用它（两者会冲突）

**步骤3：配置插件使用系统 clangd（可选）**

如果插件仍然无法找到 clangd，可以在 Cursor/VS Code 设置中配置：

1. 打开设置（`Ctrl+,` 或 `Cmd+,`）
2. 搜索 "clangd.path"
3. 设置为系统 clangd 路径：`/usr/bin/clangd`

或者在 `.vscode/settings.json` 中添加：

```json
{
    "clangd.path": "/usr/bin/clangd"
}
```

#### 2. 生成编译数据库

项目使用 CMake，需要生成 `compile_commands.json`：

```bash
cd /data/yidan.wang/wondertrader/src

# 方法1：使用现有的构建目录（如果已编译过）
cd build_debug
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
# 将 compile_commands.json 复制到项目根目录
cp compile_commands.json ../

# 方法2：创建新的构建目录专门用于生成编译数据库
cd /data/yidan.wang/wondertrader/src
mkdir -p build_for_clangd
cd build_for_clangd
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
cp compile_commands.json ../
```

#### 3. 配置 clangd

在项目根目录创建 `.clangd` 配置文件（可选）：

```yaml
CompileFlags:
  Add: 
    - -I/home/mydeps/include
    - -std=c++11
Diagnostics:
  UnusedIncludes: None
  MissingIncludes: None
```

### 方法2：使用 Microsoft C/C++ 扩展

#### 1. 安装扩展

1. 打开扩展市场
2. 搜索并安装 **"C/C++"**（由 Microsoft 开发）
3. 安装 **"C/C++ Extension Pack"**（包含更多工具）

#### 2. 配置 c_cpp_properties.json

在项目根目录创建 `.vscode/c_cpp_properties.json`：

```json
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/src/**",
                "${workspaceFolder}/src/Includes",
                "/home/mydeps/include"
            ],
            "defines": [],
            "compilerPath": "/usr/bin/g++",
            "cStandard": "c11",
            "cppStandard": "c++11",
            "intelliSenseMode": "linux-gcc-x64",
            "compileCommands": "${workspaceFolder}/src/compile_commands.json"
        }
    ],
    "version": 4
}
```

### 快速检查

安装插件后，重启 Cursor/VS Code，然后：
1. 打开任意 `.cpp` 或 `.h` 文件
2. 按住 `Ctrl`（Mac 上是 `Cmd`）并点击函数名
3. 应该能看到跳转到定义的选项

### 故障排除

1. **如果仍然无法跳转**：
   - 确保 `compile_commands.json` 在 `src/` 目录下
   - 重启 Cursor/VS Code
   - 检查 clangd 输出日志（查看 -> 输出 -> 选择 "clangd"）

2. **如果 clangd 报错**：
   - 检查依赖路径是否正确（`/home/mydeps/include`）
   - 确保项目已成功编译过至少一次

3. **性能问题**：
   - clangd 首次索引可能需要几分钟
   - 可以在设置中调整 clangd 的索引范围

### 推荐配置

**推荐使用 clangd**，因为：
- 更快的索引速度
- 更好的代码补全
- 更准确的错误检测
- 支持更多 C++ 标准



