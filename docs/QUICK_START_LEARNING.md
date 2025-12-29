# WonderTrader 量化开发快速开始

> 给量化初学者的3分钟快速指南

## 🎯 你现在的位置

✅ 你已经能让程序跑起来了  
✅ 你已经配置好了XTP交易接口  
✅ 你已经理解了基本架构（QuoteFactory + WtRunner）

## 🚀 下一步：从哪里开始？

### 第一步：阅读策略示例代码（今天就开始！）

**文件**: [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)

**为什么从这里开始？**
- 这是最完整的策略示例
- 包含了所有策略开发的核心概念
- 代码清晰易懂

**花30分钟阅读这个文件，理解**:
1. 策略如何初始化（`on_init`）
2. 策略如何获取数据（`stra_get_bars`）
3. 策略如何下单（`stra_enter_long`）
4. 策略如何查询持仓（`stra_get_position`）

### 第二步：理解策略接口（明天）

**文件**: [`src/Includes/ICtaStraCtx.h`](../src/Includes/ICtaStraCtx.h)

**这是策略可用的所有接口！**

**重点理解**:
- 数据接口：`stra_get_bars()`, `stra_get_ticks()`, `stra_get_price()`
- 交易接口：`stra_enter_long()`, `stra_exit_long()`, `stra_set_position()`
- 查询接口：`stra_get_position()`, `stra_get_fund_data()`

### 第三步：理解引擎如何工作（本周）

**文件**: [`src/WtCore/WtCtaEngine.cpp`](../src/WtCore/WtCtaEngine.cpp)

**理解**:
- 引擎如何接收行情
- 引擎如何调用策略
- 引擎如何执行交易

---

## 📚 完整学习文档

### 1. 学习指南（详细版）
📄 **文件**: [LEARNING_GUIDE.md](./LEARNING_GUIDE.md)

**包含**:
- 系统架构详解
- 核心模块说明
- 完整学习路径（5个阶段）
- 实践建议
- 常见问题

### 2. 代码参考（快速查找）
📄 **文件**: [CODE_REFERENCE.md](./CODE_REFERENCE.md)

**包含**:
- 所有关键代码文件位置
- 代码片段位置
- 接口定义位置
- 调试技巧

---

## 🎓 推荐学习顺序

### 第1周：理解策略开发

**目标**: 学会开发自己的策略

**任务**:
1. ✅ 阅读 `WtStraDualThrust.cpp`（策略示例）
2. ✅ 阅读 `ICtaStraCtx.h`（策略接口）
3. ✅ 修改DualThrust参数，观察效果
4. ✅ 实现一个简单的均线策略

**关键文件**:
- [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp) ⭐⭐⭐
- [`src/Includes/ICtaStraCtx.h`](../src/Includes/ICtaStraCtx.h) ⭐⭐⭐
- [`src/Includes/CtaStrategyDefs.h`](../src/Includes/CtaStrategyDefs.h) ⭐⭐

### 第2-3周：理解引擎核心

**目标**: 理解引擎如何工作

**任务**:
1. ✅ 阅读 `WtCtaEngine.cpp`（CTA引擎）
2. ✅ 阅读 `WtEngine.cpp`（引擎基类）
3. ✅ 理解事件驱动机制
4. ✅ 理解数据流

**关键文件**:
- [`src/WtCore/WtCtaEngine.cpp`](../src/WtCore/WtCtaEngine.cpp) ⭐⭐⭐
- [`src/WtCore/WtEngine.cpp`](../src/WtCore/WtEngine.cpp) ⭐⭐⭐
- [`src/WtCore/CtaStraContext.cpp`](../src/WtCore/CtaStraContext.cpp) ⭐⭐

### 第4周：理解数据流

**目标**: 理解数据如何流转

**任务**:
1. ✅ 阅读 `ParserAdapter.cpp`（行情适配器）
2. ✅ 阅读 `TraderAdapter.cpp`（交易适配器）
3. ✅ 理解UDP广播机制
4. ✅ 跟踪一次完整的交易流程

**关键文件**:
- [`src/WtCore/ParserAdapter.cpp`](../src/WtCore/ParserAdapter.cpp) ⭐⭐
- [`src/WtCore/TraderAdapter.cpp`](../src/WtCore/TraderAdapter.cpp) ⭐⭐
- [`src/QuoteFactory/main.cpp`](../src/QuoteFactory/main.cpp) ⭐

---

## 💡 实践建议

### 1. 边学边做

**不要只看代码，要动手！**

```bash
# 1. 修改策略参数
vim src/WtCtaStraFact/WtStraDualThrust.cpp

# 2. 重新编译
cd src
./build_debug.sh

# 3. 运行观察效果
cd ../dist
./run_background.sh wt
```

### 2. 添加日志

**在关键位置添加日志，理解执行流程**

```cpp
// 在策略中
ctx->stra_log_info("策略执行，当前持仓: %f", pos);

// 在引擎中
WTSLogger::info("收到Tick数据: {}", stdCode);
```

### 3. 使用调试器

**使用GDB跟踪执行流程**

```bash
gdb dist/WtRunner/WtRunner
(gdb) break WtStraDualThrust::on_schedule
(gdb) run -c config.yaml -l logcfg.yaml
```

### 4. 阅读日志

**日志是最好的老师**

```bash
# 实时查看日志
tail -f dist/WtRunner/Logs/Runner_*.log
tail -f dist/WtRunner/Logs/Strategy/*.log
```

---

## 🔥 核心概念速查

### 策略开发

```cpp
// 1. 获取K线数据
WTSKlineSlice* bars = ctx->stra_get_bars("SSE.600000", "m1", 50);

// 2. 计算指标
double ma = bars->average(KFT_CLOSE, 20);

// 3. 查询持仓
double pos = ctx->stra_get_position("SSE.600000");

// 4. 下单
if (条件满足) {
    ctx->stra_enter_long("SSE.600000", 100);
}
```

### 事件回调

```cpp
// 初始化
void on_init(ICtaStraCtx* ctx) { }

// 交易日开始
void on_session_begin(ICtaStraCtx* ctx, uint32_t uTDate) { }

// Tick数据
void on_tick(ICtaStraCtx* ctx, const char* stdCode, WTSTickData* newTick) { }

// K线闭合
void on_bar(ICtaStraCtx* ctx, const char* stdCode, const char* period, WTSBarStruct* newBar) { }

// 定时任务
void on_schedule(ICtaStraCtx* ctx, uint32_t curDate, uint32_t curTime) { }
```

---

## 📖 推荐阅读顺序

### 今天（1小时）

1. ✅ 阅读 [LEARNING_GUIDE.md](./LEARNING_GUIDE.md) 的"阶段2: 理解策略开发"
2. ✅ 阅读 [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)
3. ✅ 阅读 [`src/Includes/ICtaStraCtx.h`](../src/Includes/ICtaStraCtx.h)

### 本周（每天1-2小时）

1. ✅ 理解策略示例代码
2. ✅ 修改策略参数
3. ✅ 实现简单策略
4. ✅ 阅读引擎核心代码

### 本月（持续学习）

1. ✅ 深入理解引擎机制
2. ✅ 理解数据流
3. ✅ 理解接口对接
4. ✅ 实现复杂策略

---

## 🎯 学习目标

### 短期目标（1个月）

- [ ] 理解策略开发流程
- [ ] 能开发简单的CTA策略
- [ ] 理解引擎工作原理
- [ ] 能调试和优化策略

### 中期目标（3个月）

- [ ] 深入理解引擎核心
- [ ] 能开发复杂策略
- [ ] 理解数据流和接口对接
- [ ] 能优化系统性能

### 长期目标（6个月+）

- [ ] 完全掌握WonderTrader架构
- [ ] 能开发新的Parser/Trader
- [ ] 能优化引擎性能
- [ ] 成为量化开发专家

---

## 📞 需要帮助？

### 查看文档

1. **学习指南**: [LEARNING_GUIDE.md](./LEARNING_GUIDE.md) - 完整的学习路径
2. **代码参考**: [CODE_REFERENCE.md](./CODE_REFERENCE.md) - 快速查找代码位置
3. **项目文档**: [README.md](./README.md) - 项目说明

### 调试技巧

1. **查看日志**: `tail -f dist/WtRunner/Logs/*.log`
2. **使用GDB**: 设置断点跟踪执行
3. **添加日志**: 在关键位置添加日志输出

### 常见问题

查看 [LEARNING_GUIDE.md](./LEARNING_GUIDE.md) 的"常见问题"章节

---

## ✨ 开始你的量化之旅！

**第一步**: 打开 [`src/WtCtaStraFact/WtStraDualThrust.cpp`](../src/WtCtaStraFact/WtStraDualThrust.cpp)，开始阅读！

**记住**: 
- 💪 多动手，少空想
- 🔍 多调试，多思考
- 📚 多阅读，多实践

**祝你学习顺利！** 🚀

