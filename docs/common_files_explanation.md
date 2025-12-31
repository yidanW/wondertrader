# Common 目录配置文件说明

本文档详细说明 `dist/common/` 目录下各个配置文件的用途、结构和示例。

## 目录

- [contracts.json](#contractsjson) - 期货合约信息
- [commodities.json](#commoditiesjson) - 期货品种信息
- [sessions.json](#sessionsjson) - 交易时段配置
- [holidays.json](#holidaysjson) - 节假日配置
- [fees.json](#feesjson) - 期货手续费配置
- [fees_stk.json](#fees_stkjson) - 股票手续费配置
- [hots.json](#hotsjson) - 主力合约切换记录
- [stocks.json](#stocksjson) - 股票信息
- [stk_comms.json](#stk_commsjson) - 股票品种信息

---

## contracts.json

### 用途
存储所有期货合约的详细信息，包括合约代码、名称、交易所、品种、限仓等信息。

### 文件结构
```json
{
    "交易所代码": {
        "合约代码": {
            "name": "合约中文名称",
            "code": "合约代码",
            "exchg": "交易所代码",
            "product": "品种代码",
            "maxlimitqty": 限价单最大手数,
            "maxmarketqty": 市价单最大手数
        }
    }
}
```

### 示例
```json
{
    "CFFEX": {
        "IC2204": {
            "name": "中证2204",
            "code": "IC2204",
            "exchg": "CFFEX",
            "product": "IC",
            "maxlimitqty": 20,
            "maxmarketqty": 10
        }
    },
    "DCE": {
        "a2205": {
            "name": "豆一2205",
            "code": "a2205",
            "exchg": "DCE",
            "product": "a",
            "maxlimitqty": 1000,
            "maxmarketqty": 1000
        }
    }
}
```

### 字段说明
- `name`: 合约的中文名称，如"中证2204"、"豆一2205"
- `code`: 合约代码，如"IC2204"、"a2205"
- `exchg`: 交易所代码（CFFEX=中金所、DCE=大商所、CZCE=郑商所、SHFE=上期所、INE=上期能源）
- `product`: 品种代码，如"IC"、"a"
- `maxlimitqty`: 限价单最大持仓手数
- `maxmarketqty`: 市价单最大持仓手数

---

## commodities.json

### 用途
存储期货品种的基础信息，包括价格精度、最小变动价位、交易时段、节假日等。

### 文件结构
```json
{
    "交易所代码": {
        "品种代码": {
            "name": "品种中文名称",
            "exchg": "交易所代码",
            "session": "交易时段代码",
            "holiday": "节假日组",
            "category": 合约类别,
            "precision": 价格小数位数,
            "pricetick": 最小变动价位,
            "volscale": 交易单位,
            "covermode": 平仓模式,
            "pricemode": 价格模式
        }
    }
}
```

### 示例
```json
{
    "CFFEX": {
        "IC": {
            "name": "中证500",
            "exchg": "CFFEX",
            "session": "SD0930",
            "holiday": "CHINA",
            "category": 1,
            "precision": 1,
            "pricetick": 0.2,
            "volscale": 200,
            "covermode": 0,
            "pricemode": 0
        },
        "IF": {
            "name": "沪深300",
            "exchg": "CFFEX",
            "session": "SD0930",
            "holiday": "CHINA",
            "category": 1,
            "precision": 1,
            "pricetick": 0.2,
            "volscale": 300,
            "covermode": 0,
            "pricemode": 0
        }
    }
}
```

### 字段说明
- `name`: 品种中文名称
- `exchg`: 交易所代码
- `session`: 交易时段代码（参考 sessions.json）
- `holiday`: 节假日组名称（参考 holidays.json）
- `category`: 合约类别（0=股票、1=期货、2=期权等）
- `precision`: 价格显示的小数位数
- `pricetick`: 最小价格变动单位
- `volscale`: 交易单位（每手对应的数量）
- `covermode`: 平仓模式（0=先开先平、1=先开后平等）
- `pricemode`: 价格模式（0=限价、1=市价等）

---

## sessions.json

### 用途
定义交易时段配置，包括日盘、夜盘的交易时间段、集合竞价时间等。

### 文件结构
```json
{
    "时段代码": {
        "name": "时段名称",
        "offset": 时区偏移（分钟）,
        "auction": {
            "from": 集合竞价开始时间（HHMM格式）,
            "to": 集合竞价结束时间（HHMM格式）
        },
        "sections": [
            {
                "from": 交易开始时间（HHMM格式）,
                "to": 交易结束时间（HHMM格式）
            }
        ]
    }
}
```

### 示例
```json
{
    "SD0930": {
        "name": "股票交易0930",
        "offset": 0,
        "auction": {
            "from": 929,
            "to": 930
        },
        "sections": [
            {
                "from": 930,
                "to": 1130
            },
            {
                "from": 1300,
                "to": 1500
            }
        ]
    },
    "FN0100": {
        "name": "期货夜盘0100",
        "offset": 300,
        "auction": {
            "from": 2059,
            "to": 2100
        },
        "sections": [
            {
                "from": 2100,
                "to": 100
            },
            {
                "from": 900,
                "to": 1015
            },
            {
                "from": 1030,
                "to": 1130
            },
            {
                "from": 1330,
                "to": 1500
            }
        ]
    }
}
```

### 字段说明
- `name`: 时段的中文名称
- `offset`: 时区偏移量（分钟），用于夜盘跨日计算
- `auction`: 集合竞价时间段
  - `from`: 开始时间（HHMM格式，如929表示9:29）
  - `to`: 结束时间（HHMM格式）
- `sections`: 连续交易时间段数组
  - `from`: 开始时间（HHMM格式）
  - `to`: 结束时间（HHMM格式，夜盘可能跨日，如100表示次日1:00）

### 常见时段代码
- `SD0930`: 股票交易时段（9:30-11:30, 13:00-15:00）
- `FD0915`: 期货日盘（9:15-11:30, 13:00-15:15）
- `FD0900`: 期货日盘（9:00-11:30, 13:30-15:00）
- `FN0100`: 期货夜盘（21:00-次日1:00 + 日盘）
- `FN0230`: 期货夜盘（21:00-次日2:30 + 日盘）
- `FN2300`: 期货夜盘（21:00-23:00 + 日盘）
- `FN2330`: 期货夜盘（21:00-23:30 + 日盘）
- `TRADING`: 全天交易（21:00-次日2:30 + 日盘）

---

## holidays.json

### 用途
存储节假日配置，用于判断交易日和非交易日。

### 文件结构
```json
{
    "节假日组名称": [
        "日期1（YYYYMMDD格式）",
        "日期2",
        ...
    ]
}
```

### 示例
```json
{
    "CHINA": [
        "20080101",
        "20080206",
        "20080207",
        "20080208",
        "20080211",
        "20080212",
        "20080404",
        "20080501",
        "20080502",
        "20080609",
        "20080915",
        "20080929",
        "20080930",
        "20081001",
        "20081002",
        "20081003"
    ]
}
```

### 字段说明
- 键名：节假日组名称，如"CHINA"表示中国节假日
- 值：日期数组，格式为 YYYYMMDD（8位数字），如"20080101"表示2008年1月1日

---

## fees.json

### 用途
配置期货合约的手续费标准，包括开仓、平仓、平今手续费，以及是否按成交量计算。

### 文件结构
```json
{
    "交易所代码.品种代码": {
        "open": 开仓手续费率,
        "close": 平仓手续费率,
        "closetoday": 平今手续费率,
        "byvolume": 是否按成交量计算（true/false）
    }
}
```

### 示例
```json
{
    "CFFEX.IF": {
        "open": 0.000023,
        "close": 0.000023,
        "closetoday": 0.000023,
        "byvolume": false
    },
    "DCE.a": {
        "open": 2.0,
        "close": 2.0,
        "closetoday": 0.0,
        "byvolume": true
    },
    "DCE.cs": {
        "open": 1.5,
        "close": 1.5,
        "closetoday": 0.0,
        "byvolume": true
    }
}
```

### 字段说明
- `open`: 开仓手续费率（按比例）或固定金额（按手数）
- `close`: 平仓手续费率（按比例）或固定金额（按手数）
- `closetoday`: 平今手续费率（按比例）或固定金额（按手数）
- `byvolume`: 
  - `false`: 手续费按成交金额的比例计算（如0.000023表示成交金额的0.0023%）
  - `true`: 手续费按每手固定金额计算（如2.0表示每手2元）

### 计算说明
- 当 `byvolume = false` 时：手续费 = 成交金额 × 手续费率
- 当 `byvolume = true` 时：手续费 = 成交手数 × 固定金额

---

## fees_stk.json

### 用途
配置股票交易的手续费标准。

### 文件结构
```json
{
    "交易所代码.产品类型": {
        "open": 买入手续费率,
        "close": 卖出手续费率,
        "closetoday": 当日卖出手续费率（通常为0）,
        "byvolume": 是否按成交量计算（通常为false）
    }
}
```

### 示例
```json
{
    "SSE.STK": {
        "open": 0.001,
        "close": 0.0012,
        "closetoday": 0.0,
        "byvolume": false
    },
    "SZSE.STK": {
        "open": 0.001,
        "close": 0.0012,
        "closetoday": 0.0,
        "byvolume": false
    }
}
```

### 字段说明
- `open`: 买入手续费率（按成交金额的比例）
- `close`: 卖出手续费率（按成交金额的比例，通常包含印花税）
- `closetoday`: 当日卖出手续费率（通常为0，因为股票T+1交易）
- `byvolume`: 通常为 `false`，表示按成交金额的比例计算

### 产品类型
- `STK`: 股票
- `IDX`: 指数（通常不交易，手续费配置可能不适用）

---

## hots.json

### 用途
记录主力合约的切换历史，用于回测和数据分析时确定某个日期的主力合约。

### 文件结构
```json
{
    "交易所代码": {
        "品种代码": [
            {
                "date": 切换日期（YYYYMMDD格式）,
                "from": "旧主力合约代码",
                "to": "新主力合约代码",
                "oldclose": 旧合约收盘价,
                "newclose": 新合约收盘价
            }
        ]
    }
}
```

### 示例
```json
{
    "CFFEX": {
        "IC": [
            {
                "date": 20190102,
                "from": "",
                "newclose": 4096.8,
                "oldclose": 0.0,
                "to": "IC1901"
            },
            {
                "date": 20190117,
                "from": "IC1901",
                "newclose": 4325.2,
                "oldclose": 4341.0,
                "to": "IC1902"
            },
            {
                "date": 20190214,
                "from": "IC1902",
                "newclose": 4509.8,
                "oldclose": 4512.0,
                "to": "IC1903"
            }
        ]
    }
}
```

### 字段说明
- `date`: 主力合约切换日期（YYYYMMDD格式）
- `from`: 切换前的主力合约代码（首次切换时为空字符串）
- `to`: 切换后的主力合约代码
- `oldclose`: 旧主力合约的收盘价
- `newclose`: 新主力合约的收盘价

### 使用场景
- 回测时根据日期查找对应的主力合约
- 计算主力合约切换时的价差
- 生成连续的主力合约价格序列

---

## stocks.json

### 用途
存储所有股票和指数的基础信息，包括代码、名称、交易所、产品类型等。

### 文件结构
```json
{
    "交易所代码": {
        "股票代码": {
            "code": "股票代码",
            "exchg": "交易所代码",
            "name": "股票中文名称",
            "product": "产品类型"
        }
    }
}
```

### 示例
```json
{
    "SSE": {
        "000001": {
            "code": "000001",
            "exchg": "SSE",
            "name": "上证综指",
            "product": "IDX"
        },
        "000002": {
            "code": "000002",
            "exchg": "SSE",
            "name": "上证A指",
            "product": "IDX"
        },
        "600000": {
            "code": "600000",
            "exchg": "SSE",
            "name": "浦发银行",
            "product": "STK"
        }
    },
    "SZSE": {
        "000001": {
            "code": "000001",
            "exchg": "SZSE",
            "name": "平安银行",
            "product": "STK"
        },
        "399001": {
            "code": "399001",
            "exchg": "SZSE",
            "name": "深证成指",
            "product": "IDX"
        }
    }
}
```

### 字段说明
- `code`: 股票或指数代码
- `exchg`: 交易所代码（SSE=上交所、SZSE=深交所）
- `name`: 股票或指数的中文名称
- `product`: 产品类型
  - `STK`: 股票
  - `IDX`: 指数

### 交易所代码
- `SSE`: 上海证券交易所（Shanghai Stock Exchange）
- `SZSE`: 深圳证券交易所（Shenzhen Stock Exchange）

---

## stk_comms.json

### 用途
配置股票品种的基础信息，包括价格精度、最小变动价位、交易时段等。

### 文件结构
```json
{
    "交易所代码": {
        "产品类型": {
            "category": 合约类别,
            "covermode": 平仓模式,
            "exchg": "交易所代码",
            "holiday": "节假日组",
            "name": "品种中文名称",
            "precision": 价格小数位数,
            "pricemode": 价格模式,
            "pricetick": 最小变动价位,
            "session": "交易时段代码",
            "volscale": 交易单位
        }
    }
}
```

### 示例
```json
{
    "SSE": {
        "STK": {
            "category": 0,
            "covermode": 0,
            "exchg": "SSE",
            "holiday": "CHINA",
            "name": "上交所股票",
            "precision": 2,
            "pricemode": 1,
            "pricetick": 0.01,
            "session": "SD0930",
            "volscale": 1
        },
        "IDX": {
            "category": 0,
            "covermode": 0,
            "exchg": "SSE",
            "holiday": "CHINA",
            "name": "上交所指数",
            "precision": 2,
            "pricemode": 1,
            "pricetick": 0.01,
            "session": "SD0930",
            "volscale": 1
        }
    },
    "SZSE": {
        "STK": {
            "category": 0,
            "covermode": 0,
            "exchg": "SZSE",
            "holiday": "CHINA",
            "name": "深交所股票",
            "precision": 2,
            "pricemode": 1,
            "pricetick": 0.01,
            "session": "SD0930",
            "volscale": 1
        },
        "IDX": {
            "category": 0,
            "covermode": 0,
            "exchg": "SZSE",
            "holiday": "CHINA",
            "name": "深交所指数",
            "precision": 2,
            "pricemode": 1,
            "pricetick": 0.01,
            "session": "SD0930",
            "volscale": 1
        }
    }
}
```

### 字段说明
- `name`: 品种的中文名称
- `exchg`: 交易所代码
- `session`: 交易时段代码（参考 sessions.json）
- `holiday`: 节假日组名称（参考 holidays.json）
- `category`: 合约类别（0=股票）
- `precision`: 价格显示的小数位数（股票通常为2）
- `pricetick`: 最小价格变动单位（股票通常为0.01元）
- `volscale`: 交易单位（股票通常为1，表示1股）
- `covermode`: 平仓模式（股票通常为0）
- `pricemode`: 价格模式（1通常表示支持市价单）

---

## 文件关系图

```
commodities.json (品种信息)
    ↓
contracts.json (合约信息) ──→ sessions.json (交易时段)
    ↓                              ↓
fees.json (手续费)              holidays.json (节假日)
    ↓
hots.json (主力合约切换)

stk_comms.json (股票品种信息)
    ↓
stocks.json (股票信息) ──→ sessions.json (交易时段)
    ↓                              ↓
fees_stk.json (股票手续费)      holidays.json (节假日)
```

---

## 使用建议

1. **修改配置前备份**：这些文件是系统运行的基础配置，修改前请先备份。

2. **编码格式**：所有文件应使用 UTF-8 编码，确保中文显示正常。

3. **数据一致性**：
   - `contracts.json` 中的 `product` 字段应能在 `commodities.json` 中找到对应品种
   - `commodities.json` 和 `stk_comms.json` 中的 `session` 字段应能在 `sessions.json` 中找到
   - `commodities.json` 和 `stk_comms.json` 中的 `holiday` 字段应能在 `holidays.json` 中找到

4. **手续费配置**：
   - 期货手续费参考交易所公告，定期更新
   - 股票手续费包含佣金和印花税，需根据实际费率调整

5. **主力合约切换**：
   - `hots.json` 需要定期更新，记录最新的主力合约切换信息
   - 切换日期通常为合约到期前1-2周

---

## 更新日志

- 2025-12-31: 初始文档创建，修复了 contracts.json、sessions.json、stk_comms.json 的乱码问题

