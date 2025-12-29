# WonderTrader 运行指南

## 一、动态链接库配置

编译好的程序需要找到以下动态链接库：

### 1. Boost 库（必需）
- `libboost_filesystem.so.1.72.0`
- `libboost_thread.so.1.72.0`
- `libboost_system.so.1.72.0`
- `libboost_date_time.so.1.72.0`
- `libboost_regex.so.1.72.0`
- `libboost_serialization.so.1.72.0`
- `libboost_iostreams.so.1.72.0`
- `libboost_chrono.so.1.72.0`
- `libboost_atomic.so.1.72.0`

### 2. nanomsg 库（必需）
- `libnanomsg.so`

### 3. 系统库（通常已安装）
- `libstdc++.so.6`
- `libgcc_s.so.1`
- `libc.so.6`
- `libm.so.6`
- `libpthread.so.0`
- `libdl.so.2`

## 二、设置库路径

### 方法1：使用 LD_LIBRARY_PATH 环境变量（推荐）

```bash
# 临时设置（当前终端有效）
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH

# 永久设置（添加到 ~/.bashrc 或 ~/.profile）
echo 'export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### 方法2：创建系统配置文件

```bash
# 创建库配置文件
sudo bash -c 'echo "/home/mydeps/lib" > /etc/ld.so.conf.d/wondertrader.conf'

# 更新动态链接库缓存
sudo ldconfig

# 验证库是否可以被找到
ldconfig -p | grep boost
```

### 方法3：在运行脚本中设置

创建一个运行脚本 `run.sh`：

```bash
#!/bin/bash
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH
cd /data/yidan.wang/wondertrader/src/build_debug/build_x64/Debug/bin
# 运行你的程序
./WtRunner/WtRunner "$@"
```

## 三、主要可执行程序

### 1. 回测程序
- **WtBtRunner**: 回测运行器
  ```bash
  cd build_x64/Debug/bin/WtBtRunner
  ./WtBtRunner -c configbt.yaml -l logcfgbt.yaml
  ```

### 2. 实盘交易程序
- **WtRunner**: 实盘交易运行器
  ```bash
  cd build_x64/Debug/bin/WtRunner
  ./WtRunner -c config.yaml -l logcfg.yaml
  ```

### 3. 超高频程序
- **WtUftRunner**: 超高频交易运行器
  ```bash
  cd build_x64/Debug/bin/WtUftRunner
  ./WtUftRunner -c config.yaml -l logcfg.yaml
  ```

### 4. 数据组件
- **QuoteFactory**: 行情数据落地程序
  ```bash
  cd build_x64/Debug/bin/QuoteFactory
  ./QuoteFactory -c dtcfg.yaml -l logcfgdt.yaml
  ```

### 5. 测试程序
- **TestPorter**: 测试程序
- **TestBtPorter**: 回测测试程序
- **TestDtPorter**: 数据组件测试程序
- **TestTrader**: 交易接口测试程序

## 四、运行前检查清单

1. **检查库路径**
   ```bash
   ldd build_x64/Debug/bin/WtRunner/WtRunner | grep "not found"
   ```
   如果没有输出，说明所有库都能找到。

2. **检查配置文件**
   - 确保配置文件存在（如 `config.yaml`, `logcfg.yaml` 等）
   - 配置文件路径相对于可执行文件所在目录

3. **检查权限**
   ```bash
   chmod +x build_x64/Debug/bin/*/*/WtRunner
   ```

## 五、常见问题

### 问题1：找不到动态库
```
error while loading shared libraries: libboost_filesystem.so.1.72.0: cannot open shared object file
```

**解决方案**：
```bash
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH
# 或使用 ldconfig（需要 root 权限）
sudo ldconfig
```

### 问题2：配置文件不存在
```
confiture ./config.yaml not exists
```

**解决方案**：
- 创建配置文件或使用 `-c` 参数指定配置文件路径
- 配置文件格式参考项目文档

### 问题3：权限不足
```
Permission denied
```

**解决方案**：
```bash
chmod +x build_x64/Debug/bin/*/WtRunner
```

## 六、快速启动脚本示例

创建 `start_wt.sh`：

```bash
#!/bin/bash

# 设置库路径
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH

# 进入可执行文件目录
cd /data/yidan.wang/wondertrader/src/build_debug/build_x64/Debug/bin/WtRunner

# 运行程序
./WtRunner -c config.yaml -l logcfg.yaml "$@"
```

使用：
```bash
chmod +x start_wt.sh
./start_wt.sh
```

## 七、部署到 dist 目录（可选）

项目提供了 `dist` 目录用于部署和分发编译好的文件。将编译好的文件部署到 dist 目录有以下优点：

1. **目录结构清晰**：dist 目录包含所有运行所需的文件和配置
2. **便于分发**：可以将整个 dist 目录打包分发
3. **配置集中**：配置文件集中在 dist 目录下

### 部署步骤

```bash
cd /data/yidan.wang/wondertrader/src
./deploy_to_dist.sh
```

部署脚本会自动：
- 将编译好的可执行文件复制到 dist 目录
- 复制所有必需的动态库文件
- 设置可执行权限
- 保持目录结构

### 在 dist 目录下运行

部署完成后，可以在 dist 目录下运行：

```bash
cd /data/yidan.wang/wondertrader/dist

# 设置库路径
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH

# 运行程序
./run_wt.sh          # 运行实盘程序
./run_wt.sh bt       # 运行回测程序
./run_wt.sh uft      # 运行超高频程序
./run_wt.sh quote    # 运行数据组件
```

或者直接进入对应目录运行：

```bash
cd /data/yidan.wang/wondertrader/dist/WtRunner
export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH
./WtRunner -c config.yaml -l logcfg.yaml
```

## 八、验证安装

运行以下命令验证所有依赖库是否正确安装：

```bash
# 检查 Boost 库
ls -la /home/mydeps/lib/libboost_*.so* | head -10

# 检查 nanomsg 库
ls -la /home/mydeps/lib/libnanomsg.so*

# 检查程序依赖
ldd build_x64/Debug/bin/WtRunner/WtRunner | grep -E "boost|nanomsg"
```

如果所有库都能找到，就可以正常运行程序了！

