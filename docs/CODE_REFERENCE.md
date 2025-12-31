# WonderTrader 代码快速参考

> 关键代码文件位置和说明

## 📁 核心文件路径

### ⭐⭐⭐ 策略开发（必读）

| 文件 | 说明 | 重要性 |
|------|------|--------|
| [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) | DualThrust策略实现（最佳学习示例） | ⭐⭐⭐ |
| [`src/WtCtaStraFact/WtStraDualThrust.h`](../src/WtCtaStraFact/WtStraDualThrust.h) | DualThrust策略头文件 | ⭐⭐⭐ |
| [`src/Includes/CtaStrategyDefs.h`](../src/Includes/CtaStrategyDefs.h) | CTA策略基类定义 | ⭐⭐⭐ |
| [`src/Includes/ICtaStraCtx.h`](../src/Includes/ICtaStraCtx.h) | 策略上下文接口（策略可用的所有接口） | ⭐⭐⭐ |

### ⭐⭐⭐ 引擎核心（必读）

| 文件 | 说明 | 重要性 |
|------|------|--------|
| [`src/WtCore/WtCtaEngine.h`](../src/WtCore/WtCtaEngine.h) | CTA引擎接口定义 | ⭐⭐⭐ |
| [`src/WtCore/WtCtaEngine.cpp`](../src/WtCore/WtCtaEngine.cpp) | CTA引擎实现（事件驱动、策略调度） | ⭐⭐⭐ |
| [`src/WtCore/WtEngine.h`](../src/WtCore/WtEngine.h) | 引擎基类（持仓、资金、数据管理） | ⭐⭐⭐ |
| [`src/WtCore/WtEngine.cpp`](../src/WtCore/WtEngine.cpp) | 引擎基类实现 | ⭐⭐⭐ |
| [`src/WtCore/CtaStraContext.h`](../src/WtCore/CtaStraContext.h) | 策略上下文头文件 | ⭐⭐⭐ |
| [`src/WtCore/CtaStraContext.cpp`](../src/WtCore/CtaStraContext.cpp) | 策略上下文实现（下单、查询接口） | ⭐⭐⭐ |

### ⭐⭐ 程序入口（重要）

| 文件 | 说明 | 重要性 |
|------|------|--------|
| [`src/WtRunner/WtRunner.h`](../src/WtRunner/WtRunner.h) | 主程序头文件 | ⭐⭐ |
| [`src/WtRunner/WtRunner.cpp`](../src/WtRunner/WtRunner.cpp) | 主程序实现（初始化流程） | ⭐⭐ |
| [`dist/WtRunner/config.yaml`](../dist/WtRunner/config.yaml) | 运行配置文件 | ⭐⭐ |

### ⭐⭐ 数据流（重要）

| 文件 | 说明 | 重要性 |
|------|------|--------|
| [`src/WtCore/ParserAdapter.h`](../src/WtCore/ParserAdapter.h) | 行情解析器适配器 | ⭐⭐ |
| [`src/WtCore/ParserAdapter.cpp`](../src/WtCore/ParserAdapter.cpp) | 行情适配器实现 | ⭐⭐ |
| [`src/WtCore/TraderAdapter.h`](../src/WtCore/TraderAdapter.h) | 交易接口适配器 | ⭐⭐ |
| [`src/WtCore/TraderAdapter.cpp`](../src/WtCore/TraderAdapter.cpp) | 交易适配器实现 | ⭐⭐ |
| [`src/WtCore/WtDtMgr.h`](../src/WtCore/WtDtMgr.h) | 数据管理器 | ⭐⭐ |
| [`src/QuoteFactory/main.cpp`](../src/QuoteFactory/main.cpp) | QuoteFactory主程序 | ⭐⭐ |

### ⭐ 接口实现（参考）

| 文件 | 说明 | 重要性 |
|------|------|--------|
| [`src/ParserXTP/ParserXTP.cpp`](../src/ParserXTP/ParserXTP.cpp) | XTP行情解析器实现 | ⭐ |
| [`src/TraderXTP/TraderXTP.cpp`](../src/TraderXTP/TraderXTP.cpp) | XTP交易接口实现 | ⭐ |
| [`src/Includes/IParserApi.h`](../src/Includes/IParserApi.h) | 行情接口定义 | ⭐ |
| [`src/Includes/ITraderApi.h`](../src/Includes/ITraderApi.h) | 交易接口定义 | ⭐ |

---

## 🔍 关键代码片段位置

### 1. 策略开发示例

**文件**: [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)

**关键函数**:
- `on_init()` - 策略初始化（第19行）
- `on_schedule()` - 定时任务（第73行）
- `on_tick()` - Tick数据处理（第21行）
- `on_session_begin()` - 交易日开始（第53行）

**学习重点**:
```cpp
// 获取K线数据
WTSKlineSlice *kline = ctx->stra_get_bars(code.c_str(), _period.c_str(), _count, true);

// 下单
ctx->stra_enter_long(code.c_str(), qty);
ctx->stra_exit_long(code.c_str(), qty);

// 查询持仓
double pos = ctx->stra_get_position(code.c_str());
```

---

### 2. 引擎初始化流程

**文件**: [`src/WtRunner/WtRunner.cpp`](../src/WtRunner/WtRunner.cpp)

**关键函数**:
- `config()` - 配置加载（第71行）
- `initEngine()` - 引擎初始化（第368行）
- `initCtaStrategies()` - 策略加载（约第200行）

**调用链**:
```
WtRunner::config()
  ├── initTraders()      - 初始化交易接口
  ├── initParsers()      - 初始化行情解析器
  ├── initEngine()       - 初始化引擎
  └── initCtaStrategies() - 加载策略
```

---

### 3. CTA引擎事件处理

**文件**: [`src/WtCore/WtCtaEngine.cpp`](../src/WtCore/WtCtaEngine.cpp)

**关键函数**:
- `on_tick()` - Tick事件处理
- `on_bar()` - K线闭合事件处理
- `on_schedule()` - 定时任务处理
- `handle_push_quote()` - 行情推送处理

**事件流程**:
```
收到行情
  ↓
WtCtaEngine::handle_push_quote()
  ↓
WtCtaEngine::on_tick()
  ↓
策略::on_tick()
```

---

### 4. 策略上下文实现

**文件**: `src/WtCore/CtaStraContext.cpp`

**关键函数**:
- `stra_enter_long()` - 做多
- `stra_exit_long()` - 平多
- `stra_get_position()` - 查询持仓
- `stra_get_bars()` - 获取K线数据

**下单流程**:
```
策略调用 stra_enter_long()
  ↓
CtaStraContext::stra_enter_long()
  ↓
WtCtaEngine::append_signal()
  ↓
TraderAdapter::doOrder()
```

---

### 5. QuoteFactory 主程序

**文件**: [`src/QuoteFactory/main.cpp`](../src/QuoteFactory/main.cpp)

**功能概述**:
QuoteFactory 是行情数据接收和存储的核心组件，负责从各种行情源接收数据、解析、存储并广播给 WtRunner。

**关键函数**:
- `main()` - 程序入口（第261行）
- `initialize()` - 初始化流程（第96行）
- `initDataMgr()` - 初始化数据管理器（第64行）
- `initParsers()` - 初始化行情解析器（第70行）
- `getBinDir()` - 获取可执行文件目录（第50行）

**初始化流程**:
```
main()
  ├── 加载日志配置 (logcfgdt.yaml)
  ├── 安装信号处理钩子
  └── initialize()
      ├── 加载基础数据
      │   ├── 交易时间模板 (sessions)
      │   ├── 品种信息 (commodity)
      │   ├── 合约信息 (contract)
      │   ├── 节假日信息 (holiday)
      │   └── 主力合约规则 (hot/second/rules)
      ├── 初始化广播器
      │   ├── ShmCaster (共享内存广播)
      │   └── UDPCaster (UDP广播)
      ├── 初始化状态机 (非全天候模式)
      ├── 初始化数据管理器 (DataManager)
      ├── 初始化指数工厂 (IndexFactory, 可选)
      └── 初始化解析器 (ParserAdapter)
          └── g_parsers.run() - 启动所有解析器
```

**核心全局对象**:
- `g_baseDataMgr` - 基础数据管理器（交易时间、合约信息等）
- `g_dataMgr` - 数据管理器（行情数据存储和管理）
- `g_parsers` - 解析器管理器（管理所有行情解析器）
- `g_stateMon` - 状态监控器（交易时间状态管理）
- `g_udpCaster` - UDP广播器（向WtRunner广播行情）
- `g_shmCaster` - 共享内存广播器（高性能本地广播）
- `g_hotMgr` - 主力合约管理器
- `g_idxFactory` - 指数工厂（计算自定义指数）

**运行模式**:
- **标准模式**: 使用状态机管理交易时间，只在交易时间内处理行情
- **全天候模式** (`allday: true`): 不使用状态机，24小时处理行情数据

**命令行参数**:
- `-c, --config`: 配置文件路径（默认: `./dtcfg.yaml`）
- `-l, --logcfg`: 日志配置文件路径（默认: `./logcfgdt.yaml`）
- `-h, --help`: 显示帮助信息

**配置文件结构**:
```yaml
basefiles:
  session: sessions.json      # 交易时间模板
  commodity: commodities.json # 品种信息
  contract: contracts.json    # 合约信息
  holiday: holidays.json      # 节假日信息
  hot: hot.json              # 主力合约规则
  second: second.json        # 次主力合约规则
  rules:                     # 自定义规则
    custom: custom_rules.json

shmcaster:                   # 共享内存广播配置（可选）
  ...

broadcaster:                 # UDP广播配置（可选）
  ...

statemonitor: statemon.yaml  # 状态机配置（标准模式）
writer:                      # 数据写入配置
  ...

index: index.yaml            # 指数配置（可选）
parsers: mdparsers.yaml      # 解析器配置（或直接配置数组）
allday: false                # 是否全天候模式
```

**关键代码位置**:
- 配置加载: 
```96:105:src/QuoteFactory/main.cpp
void initialize(const std::string& filename)
{
	WtHelper::set_module_dir(getBinDir());

	WTSVariant* config = WTSCfgLoader::load_from_file(filename.c_str());
	if(config == NULL)
	{
		WTSLogger::error("Loading config file {} failed", filename);
		return;
	}
```
- 解析器初始化: 
```70:94:src/QuoteFactory/main.cpp
void initParsers(WTSVariant* cfg)
{
	for (uint32_t idx = 0; idx < cfg->size(); idx++)
	{
		WTSVariant* cfgItem = cfg->get(idx);
		if (!cfgItem->getBoolean("active"))
			continue;

		const char* id = cfgItem->getCString("id");
		// By Wesley @ 2021.12.14
		// 如果id为空，则生成自动id
		std::string realid = id;
		if (realid.empty())
		{
			static uint32_t auto_parserid = 1000;
			realid = StrUtil::printf("auto_parser_%u", auto_parserid++);
		}

		ParserAdapterPtr adapter(new ParserAdapter(&g_baseDataMgr, &g_dataMgr, &g_idxFactory));
		adapter->init(realid.c_str(), cfgItem);
		g_parsers.addAdapter(realid.c_str(), adapter);
	}

	WTSLogger::info("{} market data parsers loaded in total", g_parsers.size());
}
```
- 主循环: 
```321:324:src/QuoteFactory/main.cpp
	while (!bExit)
	{
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
```

**数据流向**:
```
行情源 (XTP/CTP等)
  ↓
ParserAdapter (解析器)
  ↓
DataManager (数据管理)
  ├── 存储到本地文件
  ├── UDPCaster → WtRunner (UDP广播)
  └── ShmCaster → WtRunner (共享内存)
```

---

## 📖 接口定义位置

### 策略接口

| 接口文件 | 说明 |
|---------|------|
| `src/Includes/CtaStrategyDefs.h` | CTA策略基类定义 |
| `src/Includes/ICtaStraCtx.h` | 策略上下文接口（策略可用的所有方法） |
| `src/Includes/HftStrategyDefs.h` | HFT策略接口定义 |
| `src/Includes/SelStrategyDefs.h` | SEL策略接口定义 |

### 引擎接口

| 接口文件 | 说明 |
|---------|------|
| `src/WtCore/WtEngine.h` | 引擎基类接口 |
| `src/WtCore/WtCtaEngine.h` | CTA引擎接口 |
| `src/WtCore/WtHftEngine.h` | HFT引擎接口 |

### 适配器接口

| 接口文件 | 说明 |
|---------|------|
| `src/WtCore/ParserAdapter.h` | 行情解析器适配器 |
| `src/WtCore/TraderAdapter.h` | 交易接口适配器 |
| `src/Includes/IParserApi.h` | 行情接口定义 |
| `src/Includes/ITraderApi.h` | 交易接口定义 |

---

## 🗂️ 目录结构说明

```
src/
├── Includes/              # 接口定义（所有接口都在这里）
│   ├── CtaStrategyDefs.h  # CTA策略接口
│   ├── ICtaStraCtx.h      # 策略上下文接口 ⭐⭐⭐
│   ├── IParserApi.h       # 行情接口
│   └── ITraderApi.h       # 交易接口
│
├── WtCore/                # 交易引擎核心 ⭐⭐⭐
│   ├── WtEngine.h/cpp     # 引擎基类
│   ├── WtCtaEngine.h/cpp  # CTA引擎
│   ├── CtaStraContext.h/cpp # 策略上下文
│   ├── ParserAdapter.h/cpp  # 行情适配器
│   └── TraderAdapter.h/cpp  # 交易适配器
│
├── WtCtaStraFact/         # CTA策略工厂 ⭐⭐⭐
│   ├── WtStraDualThrust.h/cpp # 示例策略
│   └── WtCtaStraFact.h/cpp    # 策略工厂
│
├── WtRunner/              # 运行入口 ⭐⭐
│   └── WtRunner.h/cpp     # 主程序
│
├── QuoteFactory/          # 数据组件 ⭐⭐
│   └── main.cpp           # QuoteFactory入口
│
├── ParserXTP/             # XTP行情解析器 ⭐
│   └── ParserXTP.cpp      # 实现
│
└── TraderXTP/            # XTP交易接口 ⭐
    └── TraderXTP.cpp      # 实现
```

---

## 🎯 学习路径对应的代码文件

### 阶段1: 理解整体架构

**阅读顺序**:
1. [`src/WtRunner/WtRunner.cpp`](../src/WtRunner/WtRunner.cpp) - 主程序入口
2. [`src/WtCore/WtCtaEngine.h`](../src/WtCore/WtCtaEngine.h) - CTA引擎接口
3. [`src/WtCore/WtEngine.h`](../src/WtCore/WtEngine.h) - 引擎基类
4. [`src/QuoteFactory/main.cpp`](../src/QuoteFactory/main.cpp) - 数据组件

### 阶段2: 理解策略开发

**阅读顺序**:
1. [`src/Includes/CtaStrategyDefs.h`](../src/Includes/CtaStrategyDefs.h) - 策略接口定义
2. [`src/Includes/ICtaStraCtx.h`](../src/Includes/ICtaStraCtx.h) - 策略上下文接口
3. [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) - 示例策略 ⭐⭐⭐
4. [`src/WtCore/CtaStraContext.cpp`](../src/WtCore/CtaStraContext.cpp) - 上下文实现

### 阶段3: 理解引擎核心

**阅读顺序**:
1. [`src/WtCore/WtEngine.h`](../src/WtCore/WtEngine.h) - 引擎基类
2. [`src/WtCore/WtCtaEngine.h`](../src/WtCore/WtCtaEngine.h) - CTA引擎
3. [`src/WtCore/WtCtaEngine.cpp`](../src/WtCore/WtCtaEngine.cpp) - CTA引擎实现 ⭐⭐⭐
4. [`src/WtCore/CtaStraContext.cpp`](../src/WtCore/CtaStraContext.cpp) - 策略上下文

### 阶段4: 理解接口对接

**阅读顺序**:
1. [`src/Includes/ITraderApi.h`](../src/Includes/ITraderApi.h) - 交易接口定义
2. [`src/WtCore/TraderAdapter.h`](../src/WtCore/TraderAdapter.h) - 交易适配器
3. [`src/TraderXTP/TraderXTP.cpp`](../src/TraderXTP/TraderXTP.cpp) - XTP交易实现
4. [`src/Includes/IParserApi.h`](../src/Includes/IParserApi.h) - 行情接口定义
5. [`src/WtCore/ParserAdapter.h`](../src/WtCore/ParserAdapter.h) - 行情适配器
6. [`src/ParserXTP/ParserXTP.cpp`](../src/ParserXTP/ParserXTP.cpp) - XTP行情实现

---

## 🔧 常用操作对应的代码位置

### 如何添加新策略？

1. **创建策略类**
   - 参考: [`src/WtCtaStraFact/WtStraDualThrust.h`](../src/WtCtaStraFact/WtStraDualThrust.h) / [`cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)
   - 继承: `CtaStrategy`
   - 实现: [`CtaStrategyDefs.h`](../src/Includes/CtaStrategyDefs.h) 中定义的接口

2. **注册到工厂**
   - 文件: [`src/WtCtaStraFact/WtCtaStraFact.cpp`](../src/WtCtaStraFact/WtCtaStraFact.cpp)
   - 参考: `createStrategy()` 函数

3. **配置策略**
   - 文件: [`dist/WtRunner/config.yaml`](../dist/WtRunner/config.yaml)
   - 位置: `strategies.cta` 配置项

### 如何获取K线数据？

**代码位置**: [`src/WtCtaStraFact/WtStraDualThrust.cpp:77`](../src/WtCtaStraFact/WtStraDualThrust.cpp#L77)

```cpp
WTSKlineSlice *kline = ctx->stra_get_bars(code.c_str(), _period.c_str(), _count, true);
```

**接口定义**: [`src/Includes/ICtaStraCtx.h:116`](../src/Includes/ICtaStraCtx.h#L116)

### 如何下单？

**代码位置**: [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) (查找 `stra_enter_long`)

**接口定义**: [`src/Includes/ICtaStraCtx.h:65-68`](../src/Includes/ICtaStraCtx.h#L65-L68)

**实现位置**: [`src/WtCore/CtaStraContext.cpp`](../src/WtCore/CtaStraContext.cpp) (查找 `stra_enter_long`)

### 如何查询持仓？

**代码位置**: [`src/WtCtaStraFact/WtStraDualThrust.cpp:60`](../src/WtCtaStraFact/WtStraDualThrust.cpp#L60)

```cpp
double pos = ctx->stra_get_position(code.c_str());
```

**接口定义**: [`src/Includes/ICtaStraCtx.h:76`](../src/Includes/ICtaStraCtx.h#L76)

### 如何处理Tick数据？

**代码位置**: [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) (查找 `on_tick`)

**接口定义**: [`src/Includes/CtaStrategyDefs.h:78`](../src/Includes/CtaStrategyDefs.h#L78)

**调用链**: [`src/WtCore/WtCtaEngine.cpp::on_tick()`](../src/WtCore/WtCtaEngine.cpp)

### 如何处理K线闭合？

**代码位置**: [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) (查找 `on_bar`)

**接口定义**: [`src/Includes/CtaStrategyDefs.h:83`](../src/Includes/CtaStrategyDefs.h#L83)

**调用链**: [`src/WtCore/WtCtaEngine.cpp::on_bar()`](../src/WtCore/WtCtaEngine.cpp)

---

## 📝 配置文件位置

| 配置文件 | 说明 |
|---------|------|
| [`dist/WtRunner/config.yaml`](../dist/WtRunner/config.yaml) | WtRunner主配置 |
| [`dist/WtRunner/tdparsers.yaml`](../dist/WtRunner/tdparsers.yaml) | 行情解析器配置 |
| [`dist/WtRunner/tdtraders.yaml`](../dist/WtRunner/tdtraders.yaml) | 交易接口配置 |
| [`dist/QuoteFactory/dtcfg.yaml`](../dist/QuoteFactory/dtcfg.yaml) | QuoteFactory配置 |
| [`dist/QuoteFactory/mdparsers.yaml`](../dist/QuoteFactory/mdparsers.yaml) | 行情解析器配置 |
| [`dist/common/stocks.json`](../dist/common/stocks.json) | 股票合约列表 |
| [`dist/common/contracts.json`](../dist/common/contracts.json) | 期货合约列表 |
| [`dist/common/sessions.json`](../dist/common/sessions.json) | 交易时间模板 |

---

## 🐛 调试技巧

### 1. 添加日志

**策略中**:
```cpp
ctx->stra_log_info("message");
ctx->stra_log_debug("message");
ctx->stra_log_error("message");
```

**引擎中**:
```cpp
WTSLogger::info("message");
WTSLogger::debug("message");
WTSLogger::error("message");
```

### 2. 查看日志文件

```bash
# WtRunner日志
tail -f dist/WtRunner/Logs/Runner_*.log

# QuoteFactory日志
tail -f dist/QuoteFactory/DtLogs/QuoteFact_*.log

# 策略日志
tail -f dist/WtRunner/Logs/Strategy/*.log
```

### 3. 使用GDB调试

```bash
# 编译Debug版本
cd src
./build_debug.sh

# 启动GDB
gdb build_debug/build_x64/Debug/bin/WtRunner/WtRunner

# 设置断点
(gdb) break WtStraDualThrust::on_schedule
(gdb) break WtCtaEngine::on_tick

# 运行
(gdb) run -c config.yaml -l logcfg.yaml
```

---

## 📚 相关文档

- [LEARNING_GUIDE.md](./LEARNING_GUIDE.md) - 完整学习指南
- [README.md](./README.md) - 项目说明
- [`src/README.md`](../src/README.md) - 源码说明

---

**快速开始**: 先阅读 [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)，这是最好的学习起点！

