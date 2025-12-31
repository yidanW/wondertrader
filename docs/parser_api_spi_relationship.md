# IParserApi 和 IParserSpi 关系说明

## 1. 接口关系

### IParserApi（解析器接口）
- **作用**：定义解析器的功能接口，如连接、订阅、初始化等
- **实现类**：`ParserXTP`、`ParserCTP`、`ParserUDP` 等具体解析器
- **职责**：负责与行情服务器通信，接收原始行情数据

### IParserSpi（回调接口）
- **作用**：定义数据接收的回调接口，用于接收解析器产生的数据
- **实现类**：`ParserAdapter`（适配器类）
- **职责**：接收解析器产生的数据，进行进一步处理（写入数据库、更新索引等）

### 关系图

```
┌─────────────────┐
│   IParserApi    │  ← 解析器接口（被调用方）
│  (ParserXTP)    │
└────────┬────────┘
         │ 通过 registerSpi() 注册
         │
         ▼
┌─────────────────┐
│   IParserSpi    │  ← 回调接口（调用方）
│ (ParserAdapter) │
└─────────────────┘
```

**关系说明**：
- `IParserApi` 是**被观察者**（Subject），产生数据
- `IParserSpi` 是**观察者**（Observer），接收数据
- 通过 `registerSpi()` 方法建立连接
- 这是**观察者模式**（Observer Pattern）的实现

---

## 2. m_sink 初始化流程

### 完整调用栈

```
main()                                    [QuoteFactory/main.cpp:261]
  │
  ├─> initialize()                        [QuoteFactory/main.cpp:96]
  │     │
  │     └─> initParsers()                 [QuoteFactory/main.cpp:70]
  │           │
  │           ├─> new ParserAdapter()     [创建适配器对象]
  │           │
  │           └─> ParserAdapter::init()   [WtDtCore/ParserAdapter.cpp:84]
  │                 │
  │                 ├─> DLLHelper::load_library()  [加载解析器动态库]
  │                 │
  │                 ├─> createParser()     [从动态库获取创建函数]
  │                 │     │
  │                 │     └─> new ParserXTP()  [创建解析器实例]
  │                 │
  │                 └─> _parser_api->registerSpi(this)  [关键步骤！]
  │                       │
  │                       └─> ParserXTP::registerSpi()  [ParserXTP.cpp:686]
  │                             │
  │                             └─> m_sink = listener  [m_sink 被赋值！]
  │                                   │
  │                                   └─> m_pBaseDataMgr = m_sink->getBaseDataMgr()
```

### 详细代码流程

#### 步骤1：程序入口

```cpp
// QuoteFactory/main.cpp:261
int main(int argc, char* argv[])
{
    // ...
    initialize(filename);  // 初始化系统
    // ...
}
```

#### 步骤2：初始化系统

```cpp
// QuoteFactory/main.cpp:96
void initialize(const std::string& filename)
{
    // ... 加载配置、基础数据等 ...
    
    // 初始化解析器
    WTSVariant* cfgParser = config->get("parsers");
    if (cfgParser) {
        initParsers(var->get("parsers"));  // 调用初始化解析器
    }
    
    g_parsers.run();  // 启动所有解析器
}
```

#### 步骤3：初始化解析器列表

```cpp
// QuoteFactory/main.cpp:70
void initParsers(WTSVariant* cfg)
{
    for (uint32_t idx = 0; idx < cfg->size(); idx++)
    {
        WTSVariant* cfgItem = cfg->get(idx);
        if (!cfgItem->getBoolean("active"))
            continue;

        const char* id = cfgItem->getCString("id");
        
        // 创建适配器对象
        ParserAdapterPtr adapter(new ParserAdapter(&g_baseDataMgr, &g_dataMgr, &g_idxFactory));
        
        // 初始化适配器（这里会创建解析器并注册回调）
        adapter->init(realid.c_str(), cfgItem);
        
        // 添加到管理器
        g_parsers.addAdapter(realid.c_str(), adapter);
    }
}
```

#### 步骤4：适配器初始化（关键步骤）

```cpp
// WtDtCore/ParserAdapter.cpp:84
bool ParserAdapter::init(const char* id, WTSVariant* cfg)
{
    // 1. 加载动态库
    std::string module = DLLHelper::wrap_module(cfg->getCString("module"), "lib");
    DllHandle hInst = DLLHelper::load_library(module.c_str());
    
    // 2. 获取创建函数
    FuncCreateParser pFuncCreateParser = (FuncCreateParser)DLLHelper::get_symbol(hInst, "createParser");
    
    // 3. 创建解析器实例（如 ParserXTP）
    _parser_api = pFuncCreateParser();  // 调用 createParser()，返回 ParserXTP*
    
    // 4. 注册回调接口（关键！）
    if (_parser_api)
    {
        _parser_api->registerSpi(this);  // this 是 ParserAdapter 对象
        // ...
    }
}
```

#### 步骤5：解析器注册回调（m_sink 被赋值）

```cpp
// ParserXTP/ParserXTP.cpp:686
void ParserXTP::registerSpi(IParserSpi* listener)
{
    m_sink = listener;  // ✅ m_sink 在这里被初始化！
    
    if(m_sink)
        m_pBaseDataMgr = m_sink->getBaseDataMgr();
}
```

---

## 3. 数据流向

### 完整数据流

```
XTP 行情服务器
    │
    │ 推送行情数据
    ▼
ParserXTP::OnDepthMarketData()  [接收原始数据]
    │
    │ 转换数据格式
    ▼
ParserXTP::OnDepthMarketData()  [创建 WTSTickData]
    │
    │ if (m_sink)  [检查回调是否存在]
    │   m_sink->handleQuote(tick, 1)
    ▼
ParserAdapter::handleQuote()  [实现 IParserSpi 接口]
    │
    │ 进一步处理
    ▼
DataManager::writeTick()  [写入数据库]
    │
    └─> IndexFactory::handle_quote()  [更新索引]
```

### 关键代码位置

#### 解析器接收数据并回调

```cpp
// ParserXTP/ParserXTP.cpp:352
void ParserXTP::OnDepthMarketData(XTPMD *market_data, ...)
{
    // ... 转换数据 ...
    
    if(m_sink)  // 检查 m_sink 是否存在
        m_sink->handleQuote(tick, 1);  // 调用回调接口
}
```

#### 适配器处理数据

```cpp
// WtDtCore/ParserAdapter.cpp:335
void ParserAdapter::handleQuote(WTSTickData *quote, uint32_t procFlag)
{
    // ... 验证数据 ...
    
    // 写入数据库
    _dt_mgr->writeTick(quote, procFlag);
    
    // 更新索引
    if (_idx_fact)
        _idx_fact->handle_quote(quote);
}
```

---

## 4. 类图关系

```
┌─────────────────────────────────────────┐
│           IParserApi                    │
│  (接口：解析器功能)                      │
├─────────────────────────────────────────┤
│ + init()                                 │
│ + connect()                              │
│ + subscribe()                            │
│ + registerSpi(IParserSpi*)              │ ← 注册回调接口
└──────────────┬──────────────────────────┘
               │ 实现
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────┐         ┌──────▼─────┐
│ParserXTP│         │ParserCTP   │
│        │         │            │
│m_sink  │         │m_sink      │  ← 存储回调接口指针
└───┬────┘         └──────┬─────┘
    │                     │
    │ 调用                │
    │ m_sink->handleQuote()│
    │                     │
    └──────────┬──────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│           IParserSpi                    │
│  (接口：数据接收回调)                    │
├─────────────────────────────────────────┤
│ + handleQuote()                         │
│ + handleEvent()                          │
│ + handleOrderQueue()                     │
│ + getBaseDataMgr()                      │
└──────────────┬──────────────────────────┘
               │ 实现
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼──────────┐  ┌──────▼──────┐
│ParserAdapter│  │其他实现类    │
│             │  │             │
│_parser_api  │  │             │  ← 持有解析器指针
└─────────────┘  └──────────────┘
```

---

## 5. 关键点总结

### m_sink 的作用
- **类型**：`IParserSpi*`（回调接口指针）
- **初始化位置**：`ParserXTP::registerSpi()` 方法中
- **初始化时机**：`ParserAdapter::init()` 调用 `_parser_api->registerSpi(this)` 时
- **作用**：解析器通过 `m_sink` 将数据传递给上层处理者

### IParserApi 和 IParserSpi 的关系
- **IParserApi**：解析器接口，负责接收行情数据
- **IParserSpi**：回调接口，负责接收解析器产生的数据
- **关系**：通过 `registerSpi()` 建立连接，实现观察者模式
- **数据流**：`IParserApi` → `m_sink` → `IParserSpi`

### 设计模式
- **观察者模式**（Observer Pattern）
  - Subject（被观察者）：`IParserApi`（如 `ParserXTP`）
  - Observer（观察者）：`IParserSpi`（如 `ParserAdapter`）
  - 通过 `registerSpi()` 注册观察者

### 调用时机
1. **初始化阶段**：`ParserAdapter::init()` → `registerSpi(this)` → `m_sink = listener`
2. **运行阶段**：解析器收到数据 → `m_sink->handleQuote()` → 适配器处理数据

---

## 6. 示例：完整调用流程

```cpp
// 1. 程序启动
main()
  └─> initialize()
        └─> initParsers()
              └─> new ParserAdapter()
                    └─> adapter->init()
                          ├─> 加载动态库
                          ├─> createParser() → new ParserXTP()
                          └─> parser->registerSpi(adapter)  ← m_sink 被赋值

// 2. 解析器运行
ParserXTP::connect()
  └─> DoLogin()
        └─> m_pUserAPI->Login()

// 3. 收到行情数据
XTP API 回调
  └─> ParserXTP::OnDepthMarketData()
        └─> if (m_sink)  ← 检查回调是否存在
              └─> m_sink->handleQuote(tick, 1)  ← 调用回调
                    └─> ParserAdapter::handleQuote()
                          └─> DataManager::writeTick()
```

---

## 7. 为什么需要这种设计？

### 优点
1. **解耦**：解析器和数据处理逻辑分离
2. **可扩展**：可以轻松添加新的解析器或数据处理方式
3. **可测试**：可以模拟 `IParserSpi` 进行单元测试
4. **灵活性**：一个解析器可以注册多个回调（虽然当前实现只支持一个）

### 设计原则
- **单一职责**：解析器只负责接收数据，适配器负责处理数据
- **依赖倒置**：解析器依赖抽象接口 `IParserSpi`，而不是具体实现
- **开闭原则**：可以添加新的解析器或适配器，而不修改现有代码

