# WonderTrader 量化开发学习指南

> 面向有后台开发经验的量化初学者

## 📚 目录

1. [系统架构概览](#系统架构概览)
2. [核心模块说明](#核心模块说明)
3. [数据流和运行流程](#数据流和运行流程)
4. [学习路径](#学习路径)
5. [关键代码位置](#关键代码位置)
6. [实践建议](#实践建议)

---

## 系统架构概览

### 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    WonderTrader 架构                     │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐         ┌──────────────┐              │
│  │ QuoteFactory │────────▶│  WtRunner    │              │
│  │  (行情接收)   │  UDP    │  (策略执行)   │              │
│  └──────────────┘         └──────────────┘              │
│         │                        │                        │
│         │                        │                        │
│    ┌────▼────┐              ┌───▼────┐                  │
│    │ Parser  │              │ Trader │                  │
│    │ (解析器) │              │(交易器) │                  │
│    └─────────┘              └────────┘                  │
│         │                        │                        │
│         │                        │                        │
│    ┌────▼────────────────────────▼────┐                 │
│    │      外部交易接口 (XTP/CTP等)      │                 │
│    └───────────────────────────────────┘                 │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### 核心组件

1. **QuoteFactory** - 行情数据接收和存储
2. **WtRunner** - 策略执行引擎
3. **Parser** - 行情解析器（对接各种行情源）
4. **Trader** - 交易接口（对接各种交易通道）
5. **Strategy** - 策略逻辑（CTA/HFT/UFT）

---

## 核心模块说明

### 1. 基础库 (BaseLibs)

#### Share - 基础数据结构
**位置**: `src/Share/`

**核心内容**:
- 基础数据结构定义
- 接口定义（IParserApi, ITraderApi等）
- 公共方法封装

**学习重点**:
- `Includes/` - 所有接口定义
- `Includes/WTSMarcos.h` - 宏定义和基础类型
- `Includes/IParserApi.h` - 行情解析器接口
- `Includes/ITraderApi.h` - 交易接口定义

**为什么重要**: 这是整个框架的基础，定义了所有组件的接口规范。

---

### 2. 数据组件 (DataKit)

#### QuoteFactory - 行情数据落地
**位置**: `src/QuoteFactory/`

**核心文件**:
- `main.cpp` - 程序入口
- `dtcfg.yaml` - 配置文件

**功能**:
- 从各种行情源接收数据（通过Parser）
- 将数据存储到文件
- 通过UDP广播行情数据

**学习重点**:
- 如何加载Parser
- 如何存储数据
- UDP广播机制

#### WtDtCore - 数据管理核心
**位置**: `src/WtDtCore/`

**功能**:
- 数据读取和管理
- K线合成
- Tick数据切片

---

### 3. 交易核心 (Product)

#### WtCore - 交易引擎核心 ⭐⭐⭐
**位置**: `src/WtCore/`

**这是最核心的模块！**

**核心类**:

1. **WtEngine** (`WtEngine.h/cpp`)
   - 所有引擎的基类
   - 管理持仓、资金、数据订阅
   - 处理行情推送

2. **WtCtaEngine** (`WtCtaEngine.h/cpp`) ⭐⭐⭐
   - CTA引擎实现
   - 策略调度和执行
   - 事件驱动（tick、bar、schedule）

3. **CtaStraContext** (`CtaStraContext.h/cpp`) ⭐⭐⭐
   - 策略上下文
   - 提供策略接口（下单、查询持仓等）
   - 数据访问接口

4. **TraderAdapter** (`TraderAdapter.h/cpp`) ⭐⭐
   - 交易接口适配器
   - 订单管理
   - 持仓同步

5. **ParserAdapter** (`ParserAdapter.h/cpp`) ⭐⭐
   - 行情解析器适配器
   - 行情数据转换
   - 订阅管理

**学习顺序**:
1. 先看 `WtEngine.h` - 理解引擎基类
2. 再看 `WtCtaEngine.h` - 理解CTA引擎
3. 然后看 `CtaStraContext.h` - 理解策略上下文接口
4. 最后看实现文件 `.cpp`

---

### 4. 策略插件 (Plugins)

#### WtCtaStraFact - CTA策略工厂 ⭐⭐⭐
**位置**: `src/WtCtaStraFact/`

**这是学习策略开发的最佳起点！**

**核心文件**:

1. **WtStraDualThrust** (`WtStraDualThrust.h/cpp`) ⭐⭐⭐
   - 示例策略：DualThrust
   - 展示了完整的策略开发流程
   - 包含所有策略接口的使用

2. **WtCtaStraFact** (`WtCtaStraFact.h/cpp`)
   - 策略工厂实现
   - 策略创建和管理

**策略接口** (`Includes/CtaStrategyDefs.h`):
```cpp
class CtaStrategy {
    // 初始化
    virtual void on_init(ICtaStraCtx* ctx);
    
    // 交易日开始/结束
    virtual void on_session_begin(ICtaStraCtx* ctx, uint32_t uTDate);
    virtual void on_session_end(ICtaStraCtx* ctx, uint32_t uTDate);
    
    // 行情事件
    virtual void on_tick(ICtaStraCtx* ctx, const char* stdCode, WTSTickData* newTick);
    virtual void on_bar(ICtaStraCtx* ctx, const char* stdCode, const char* period, WTSBarStruct* newBar);
    
    // 定时任务
    virtual void on_schedule(ICtaStraCtx* ctx, uint32_t uDate, uint32_t uTime);
};
```

**策略上下文接口** (`Includes/ICtaStraCtx.h`):
```cpp
class ICtaStraCtx {
    // 下单接口
    virtual void stra_enter_long(const char* stdCode, double qty, ...);
    virtual void stra_exit_long(const char* stdCode, double qty, ...);
    
    // 查询接口
    virtual double stra_get_position(const char* stdCode, ...);
    virtual double stra_get_price(const char* stdCode);
    
    // 数据接口
    virtual WTSKlineSlice* stra_get_bars(const char* stdCode, const char* period, uint32_t count);
    virtual WTSTickSlice* stra_get_ticks(const char* stdCode, uint32_t count);
};
```

---

### 5. 运行入口 (Product)

#### WtRunner - 实盘运行入口 ⭐⭐
**位置**: `src/WtRunner/`

**核心文件**:
- `WtRunner.h/cpp` - 主程序
- `config.yaml` - 配置文件

**功能**:
- 加载配置
- 初始化引擎
- 加载策略
- 启动运行

**关键流程** (`WtRunner.cpp`):
```cpp
1. config() - 加载配置文件
2. initTraders() - 初始化交易接口
3. initParsers() - 初始化行情解析器
4. initEngine() - 初始化引擎（CTA/HFT/SEL）
5. initCtaStrategies() - 加载策略
6. run() - 启动运行
```

---

### 6. 解析器和交易器

#### ParserXTP - XTP行情解析器 ⭐
**位置**: `src/ParserXTP/`

**学习重点**:
- 如何对接外部行情接口
- 如何转换数据格式
- 如何实现IParserApi接口

#### TraderXTP - XTP交易接口 ⭐
**位置**: `src/TraderXTP/`

**学习重点**:
- 如何对接外部交易接口
- 如何实现ITraderApi接口
- 订单管理和持仓同步

---

## 数据流和运行流程

### 数据流

```
外部行情源 (XTP/CTP等)
    ↓
ParserXTP/TraderXTP (解析器)
    ↓
ParserAdapter (适配器)
    ↓
QuoteFactory (存储 + UDP广播)
    ↓
ParserUDP (接收广播)
    ↓
ParserAdapter (适配器)
    ↓
WtCtaEngine (引擎)
    ↓
CtaStraContext (策略上下文)
    ↓
CtaStrategy (策略逻辑)
    ↓
TraderAdapter (交易适配器)
    ↓
TraderXTP (交易接口)
    ↓
外部交易通道 (XTP/CTP等)
```

### 运行流程

#### 1. 启动阶段

```
WtRunner::config()
    ├── 加载基础数据（合约、品种、交易时间等）
    ├── initTraders() - 加载交易接口
    ├── initParsers() - 加载行情解析器
    ├── initEngine() - 初始化引擎
    └── initCtaStrategies() - 加载策略
```

#### 2. 初始化阶段

```
WtCtaEngine::init()
    ├── 加载手续费配置
    ├── 初始化数据管理器
    └── 初始化风控模块

策略::on_init()
    └── 策略初始化逻辑
```

#### 3. 运行阶段

```
交易日开始
    └── 策略::on_session_begin()

收到Tick数据
    └── WtCtaEngine::on_tick()
        └── 策略::on_tick()

K线闭合
    └── WtCtaEngine::on_bar()
        └── 策略::on_bar()

定时任务
    └── WtCtaEngine::on_schedule()
        └── 策略::on_schedule()

交易日结束
    └── 策略::on_session_end()
```

---

## 学习路径

### 阶段1: 理解整体架构 (1-2周)

**目标**: 理解系统如何工作

**步骤**:

1. **阅读配置文件**
   - `dist/WtRunner/config.yaml` - 理解配置结构
   - `dist/QuoteFactory/dtcfg.yaml` - 理解数据配置

2. **跟踪程序启动流程**
   - `src/WtRunner/WtRunner.cpp::config()` - 配置加载
   - `src/WtRunner/WtRunner.cpp::initEngine()` - 引擎初始化
   - `src/WtCore/WtCtaEngine.cpp::init()` - CTA引擎初始化

3. **理解数据流**
   - `src/QuoteFactory/main.cpp` - QuoteFactory如何工作
   - `src/ParserXTP/ParserXTP.cpp` - 如何接收行情
   - `src/WtCore/ParserAdapter.cpp` - 如何转换数据

**推荐阅读顺序**:
```
1. src/WtRunner/WtRunner.cpp (主程序入口)
2. src/WtCore/WtCtaEngine.h (引擎接口)
3. src/WtCore/WtEngine.h (引擎基类)
4. src/QuoteFactory/main.cpp (数据组件)
```

---

### 阶段2: 理解策略开发 (2-3周)

**目标**: 学会开发自己的策略

**步骤**:

1. **深入理解策略接口**
   - `src/Includes/CtaStrategyDefs.h` - 策略基类定义
   - `src/Includes/ICtaStraCtx.h` - 策略上下文接口

2. **学习示例策略**
   - `src/WtCtaStraFact/WtStraDualThrust.h` - 策略头文件
   - `src/WtCtaStraFact/WtStraDualThrust.cpp` - 策略实现 ⭐⭐⭐
   
   **重点理解**:
   - 如何获取K线数据
   - 如何计算指标
   - 如何下单
   - 如何管理持仓

3. **理解策略上下文**
   - `src/WtCore/CtaStraContext.h` - 上下文接口
   - `src/WtCore/CtaStraContext.cpp` - 上下文实现

**实践任务**:
- 修改DualThrust策略的参数
- 添加新的指标计算
- 实现简单的均线策略

**推荐阅读顺序**:
```
1. src/Includes/CtaStrategyDefs.h (策略接口定义)
2. src/Includes/ICtaStraCtx.h (上下文接口)
3. src/WtCtaStraFact/WtStraDualThrust.cpp (示例策略) ⭐⭐⭐
4. src/WtCore/CtaStraContext.cpp (上下文实现)
```

---

### 阶段3: 理解引擎核心 (3-4周)

**目标**: 深入理解引擎如何工作

**步骤**:

1. **理解引擎基类**
   - `src/WtCore/WtEngine.h` - 引擎基类
   - `src/WtCore/WtEngine.cpp` - 引擎实现
   
   **重点理解**:
   - 持仓管理
   - 资金管理
   - 数据订阅机制
   - 信号处理

2. **理解CTA引擎**
   - `src/WtCore/WtCtaEngine.h` - CTA引擎接口
   - `src/WtCore/WtCtaEngine.cpp` - CTA引擎实现 ⭐⭐⭐
   
   **重点理解**:
   - 事件驱动机制
   - 策略调度
   - 定时任务处理

3. **理解数据管理**
   - `src/WtCore/WtDtMgr.h` - 数据管理器
   - K线合成逻辑
   - Tick数据切片

**推荐阅读顺序**:
```
1. src/WtCore/WtEngine.h (引擎基类)
2. src/WtCore/WtCtaEngine.h (CTA引擎)
3. src/WtCore/WtCtaEngine.cpp (CTA引擎实现) ⭐⭐⭐
4. src/WtCore/CtaStraContext.cpp (策略上下文)
```

---

### 阶段4: 理解交易和行情接口 (2-3周)

**目标**: 理解如何对接外部接口

**步骤**:

1. **理解交易接口**
   - `src/Includes/ITraderApi.h` - 交易接口定义
   - `src/WtCore/TraderAdapter.h` - 交易适配器
   - `src/TraderXTP/TraderXTP.cpp` - XTP交易实现

2. **理解行情接口**
   - `src/Includes/IParserApi.h` - 行情接口定义
   - `src/WtCore/ParserAdapter.h` - 行情适配器
   - `src/ParserXTP/ParserXTP.cpp` - XTP行情实现

**推荐阅读顺序**:
```
1. src/Includes/ITraderApi.h (交易接口定义)
2. src/WtCore/TraderAdapter.h (交易适配器)
3. src/TraderXTP/TraderXTP.cpp (XTP交易实现)
4. src/Includes/IParserApi.h (行情接口定义)
5. src/WtCore/ParserAdapter.h (行情适配器)
6. src/ParserXTP/ParserXTP.cpp (XTP行情实现)
```

---

### 阶段5: 高级主题 (持续学习)

**目标**: 深入理解高级特性

**主题**:

1. **执行器 (Executer)**
   - `src/WtCore/WtExecMgr.h` - 执行器管理
   - `src/WtExeFact/` - 执行器工厂

2. **风控 (Risk Monitor)**
   - `src/WtCore/WtRiskMonitor.h` - 风控接口
   - `src/WtRiskMonFact/` - 风控工厂

3. **回测引擎**
   - `src/WtBtCore/` - 回测核心
   - `src/WtBtRunner/` - 回测运行器

4. **高频引擎 (HFT)**
   - `src/WtCore/WtHftEngine.h` - HFT引擎

5. **超高频引擎 (UFT)**
   - `src/WtUftCore/` - UFT核心

---

## 关键代码位置

### 核心文件清单

#### ⭐⭐⭐ 必读（理解系统核心）

1. **策略开发**
   - `src/WtCtaStraFact/WtStraDualThrust.cpp` - 策略示例
   - `src/Includes/CtaStrategyDefs.h` - 策略接口定义
   - `src/Includes/ICtaStraCtx.h` - 策略上下文接口

2. **引擎核心**
   - `src/WtCore/WtCtaEngine.h/cpp` - CTA引擎
   - `src/WtCore/WtEngine.h/cpp` - 引擎基类
   - `src/WtCore/CtaStraContext.h/cpp` - 策略上下文

3. **程序入口**
   - `src/WtRunner/WtRunner.cpp` - 主程序
   - `src/WtRunner/WtRunner.h` - 主程序头文件

#### ⭐⭐ 重要（理解数据流）

4. **数据管理**
   - `src/WtCore/WtDtMgr.h` - 数据管理器
   - `src/WtCore/ParserAdapter.h/cpp` - 行情适配器
   - `src/WtCore/TraderAdapter.h/cpp` - 交易适配器

5. **数据组件**
   - `src/QuoteFactory/main.cpp` - QuoteFactory入口
   - `src/WtDtCore/` - 数据核心

#### ⭐ 参考（理解接口对接）

6. **接口实现**
   - `src/ParserXTP/ParserXTP.cpp` - XTP行情解析器
   - `src/TraderXTP/TraderXTP.cpp` - XTP交易接口
   - `src/Includes/IParserApi.h` - 行情接口定义
   - `src/Includes/ITraderApi.h` - 交易接口定义

---

### 代码阅读技巧

1. **从接口开始**
   - 先看 `.h` 文件，理解接口定义
   - 再看 `.cpp` 文件，理解实现细节

2. **跟踪调用链**
   - 从 `WtRunner::config()` 开始
   - 跟踪初始化流程
   - 跟踪事件处理流程

3. **理解设计模式**
   - 适配器模式：`ParserAdapter`, `TraderAdapter`
   - 工厂模式：`WtCtaStraFact`
   - 策略模式：`CtaStrategy`

4. **使用调试工具**
   - 设置断点跟踪执行流程
   - 查看日志理解运行过程
   - 使用 `gdb` 调试（Linux）

---

## 实践建议

### 1. 环境准备

```bash
# 1. 确保程序能正常运行
cd /data/yidan.wang/wondertrader/dist
./run_background.sh all

# 2. 查看日志
tail -f WtRunner/Logs/Runner_*.log
tail -f QuoteFactory/DtLogs/QuoteFact_*.log

# 3. 理解配置
cat WtRunner/config.yaml
cat QuoteFactory/dtcfg.yaml
```

### 2. 第一个任务：修改策略参数

**目标**: 理解策略如何工作

**步骤**:
1. 找到 `src/WtCtaStraFact/WtStraDualThrust.cpp`
2. 修改策略参数（k1, k2等）
3. 重新编译
4. 运行并观察效果

### 3. 第二个任务：添加日志

**目标**: 理解策略执行流程

**步骤**:
1. 在策略的关键位置添加日志
2. 观察日志输出
3. 理解执行顺序

### 4. 第三个任务：实现简单策略

**目标**: 学会开发策略

**步骤**:
1. 复制 `WtStraDualThrust` 创建新策略
2. 实现简单的均线策略
3. 测试运行

### 5. 第四个任务：理解数据流

**目标**: 理解数据如何流转

**步骤**:
1. 在 `ParserXTP` 添加日志，观察行情接收
2. 在 `WtCtaEngine` 添加日志，观察数据处理
3. 在策略中添加日志，观察策略执行

### 6. 进阶任务

1. **实现新的Parser**
   - 参考 `ParserXTP` 实现新的行情解析器

2. **实现新的Trader**
   - 参考 `TraderXTP` 实现新的交易接口

3. **优化策略性能**
   - 理解性能瓶颈
   - 优化数据访问

4. **实现回测**
   - 学习回测引擎
   - 实现策略回测

---

## 常见问题

### Q1: 策略如何获取K线数据？

**A**: 通过策略上下文接口
```cpp
// 在策略中
WTSKlineSlice* bars = ctx->stra_get_bars("SSE.600000", "m1", 50);
```

### Q2: 策略如何下单？

**A**: 通过策略上下文接口
```cpp
// 做多
ctx->stra_enter_long("SSE.600000", 100);

// 平多
ctx->stra_exit_long("SSE.600000", 100);
```

### Q3: 策略如何查询持仓？

**A**: 通过策略上下文接口
```cpp
double pos = ctx->stra_get_position("SSE.600000");
```

### Q4: 如何调试策略？

**A**: 
1. 使用日志：`ctx->stra_log_info("message")`
2. 使用gdb调试
3. 查看日志文件

### Q5: 如何添加新的策略？

**A**:
1. 继承 `CtaStrategy` 类
2. 实现策略接口
3. 在工厂中注册
4. 在配置文件中配置

---

## 学习资源

### 官方文档
- `README.md` - 项目说明
- `src/README.md` - 源码说明
- `RUN.md` - 运行说明

### 代码示例
- `src/WtCtaStraFact/WtStraDualThrust.cpp` - CTA策略示例
- `src/WtHftStraFact/` - HFT策略示例
- `src/WtSelStraFact/` - SEL策略示例

### 配置文件
- `dist/WtRunner/config.yaml` - 运行配置
- `dist/QuoteFactory/dtcfg.yaml` - 数据配置

---

## 总结

### 核心学习路径

```
1. 理解配置和启动流程 (WtRunner)
   ↓
2. 理解策略开发 (WtCtaStraFact)
   ↓
3. 理解引擎核心 (WtCtaEngine)
   ↓
4. 理解数据流 (ParserAdapter, TraderAdapter)
   ↓
5. 理解接口对接 (ParserXTP, TraderXTP)
```

### 关键文件优先级

**第一优先级**（必须理解）:
- `src/WtCtaStraFact/WtStraDualThrust.cpp` - 策略示例
- `src/WtCore/WtCtaEngine.h/cpp` - CTA引擎
- `src/Includes/ICtaStraCtx.h` - 策略上下文接口

**第二优先级**（重要理解）:
- `src/WtRunner/WtRunner.cpp` - 主程序
- `src/WtCore/WtEngine.h/cpp` - 引擎基类
- `src/WtCore/CtaStraContext.cpp` - 策略上下文实现

**第三优先级**（参考理解）:
- `src/ParserXTP/ParserXTP.cpp` - 行情解析器
- `src/TraderXTP/TraderXTP.cpp` - 交易接口
- `src/QuoteFactory/main.cpp` - 数据组件

---

## 下一步行动

1. ✅ **立即开始**: 阅读 `src/WtCtaStraFact/WtStraDualThrust.cpp`
2. ✅ **理解接口**: 阅读 `src/Includes/ICtaStraCtx.h`
3. ✅ **跟踪流程**: 在关键位置添加日志
4. ✅ **实践开发**: 实现一个简单策略

**记住**: 量化开发是一个实践性很强的领域，多写代码、多调试、多思考！

---

**祝你学习顺利，早日成为量化开发专家！** 🚀

