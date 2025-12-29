# wt > src
这是wondertrader的C++底层源码

## 快速开始

### 编译完成后运行

1. **设置动态库路径**：
   ```bash
   export LD_LIBRARY_PATH=/home/mydeps/lib:$LD_LIBRARY_PATH
   ```

2. **运行程序**：
   ```bash
   cd build_debug/build_x64/Debug/bin/WtRunner
   ./WtRunner -c config.yaml -l logcfg.yaml
   ```

3. **或使用快速启动脚本**：
   ```bash
   ./start_wt.sh          # 运行实盘程序
   ./start_wt.sh bt       # 运行回测程序
   ./start_wt.sh uft      # 运行超高频程序
   ```

详细运行说明请参考 [RUN.md](RUN.md)

## 开发环境
+ Windows	
	> `Visual Studio 2017` + `Windows 10`
+ Linux	
	> `Gcc v8.4.0` + `cmake 3.17.5`
	
	### 使用 apt 安装开发环境
	
	#### 安装 GCC 8.4.0
	```bash
	# 添加 GCC 8 的软件源（Ubuntu 18.04/20.04）
	sudo apt update
	sudo apt install -y gcc-8 g++-8
	
	# 设置 GCC 8 为默认版本（可选）
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800
	sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 800
	
	# 验证版本
	gcc --version
	g++ --version
	```
	
	#### 安装 cmake 3.17.5
	```bash
	# 方法1: 从 Kitware 官方仓库安装（推荐）
	sudo apt remove --purge --auto-remove cmake
	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
	sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main'
	sudo apt update
	sudo apt install -y cmake=3.17.5-0kitware1 cmake-data=3.17.5-0kitware1
	
	# 方法2: 如果方法1不可用，可以从源码编译
	# wget https://github.com/Kitware/CMake/releases/download/v3.17.5/cmake-3.17.5.tar.gz
	# tar -xzf cmake-3.17.5.tar.gz
	# cd cmake-3.17.5
	# ./bootstrap && make && sudo make install
	
	# 验证版本
	cmake --version
	```

## 依赖库
+ [boost 1.72](https://www.boost.org/)
+ [rapidjson 1.1.0](https://github.com/Tencent/rapidjson) (代码需要 GetObject/GetArray API，1.0.2 不支持)
+ [spdlog 1.9.2](https://github.com/gabime/spdlog)
+ [nanomsg 1.1.5](https://github.com/nanomsg/nanomsg)

### 使用 apt 安装依赖库

**快速安装（推荐）**：使用提供的安装脚本一键安装所有依赖：
```bash
sudo ./install_deps.sh
```

**手动安装**：如果需要自定义安装路径或版本，可以按照以下步骤手动安装：

#### 安装 Boost 1.72
```bash
# 注意：Ubuntu/Debian 默认仓库可能没有 Boost 1.72，需要从源码编译安装
# 项目期望 Boost 安装在 /home/mydeps 目录

# 1. 创建依赖目录
sudo mkdir -p /home/mydeps/{include,lib}

# 2. 下载并编译 Boost 1.72
cd /tmp
wget https://archives.boost.io/release/1.72.0/source/boost_1_72_0.tar.gz
tar -xzf boost_1_72_0.tar.gz
cd boost_1_72_0

# 3. 配置并编译（只编译需要的组件）
./bootstrap.sh --prefix=/home/mydeps
./b2 --prefix=/home/mydeps \
     --with-filesystem \
     --with-thread \
     --with-system \
     --with-date_time \
     --with-regex \
     --with-serialization \
     --with-iostreams \
     --with-chrono \
     --with-atomic \
     -j$(nproc) \
     install

# 4. 验证安装
ls -la /home/mydeps/include/boost/smart_ptr/detail/spinlock.hpp
ls -la /home/mydeps/lib/libboost_*

# 5. 如果使用非标准路径，可以设置环境变量或修改 CMakeLists.txt
# export MyDeps="/your/custom/path"
```

#### 安装其他依赖库
```bash
# rapidjson（仅头文件库，需要移动头文件到正确位置）
# 注意：代码使用了 GetObject()/GetArray()，需要 1.1.0+ 版本
cd /home/mydeps/include
git clone --branch v1.1.0 --depth 1 https://github.com/Tencent/rapidjson.git rapidjson_temp
mv rapidjson_temp/include/rapidjson rapidjson
rm -rf rapidjson_temp

# spdlog（仅头文件库，需要包含 fmt 子模块）
cd /home/mydeps/include
git clone --branch v1.9.2 --recursive --depth 1 https://github.com/gabime/spdlog.git spdlog_temp
mv spdlog_temp/include/spdlog spdlog
rm -rf spdlog_temp

# nanomsg（需要编译）
cd /tmp
git clone --branch 1.1.5 https://github.com/nanomsg/nanomsg.git
cd nanomsg
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/home/mydeps
make -j$(nproc)
sudo make install
```

## 解决方案结构
+ ***Backtest***
	backtest包含了回测相关的项目
	- WtBtCore		回测框架核心代码
	- WtBtPorter	回测框架C接口导出模块
	- WtBtRunner	回测框架纯C++环境运行入口程序
	- TestBtPorter	C接口导出模块（*WtBtPorer*）的测试程序，方便在C++环境调试
+ ***BaseLibs***
	BaseLibs包含了整个解决方案的基础库
	- Share			包含了整个框架的基础数据结构、基础对象以及所有接口的定义，也包含了一些公共方法的封装
	- WTSUtilsLib	包含了整个框架用到的第三方组件，如*pugixml*、*zstdlib*、*base64*、*md5*等
	- WTSToolsLib	框架的通用工具库，很多基础工具都在该项目里定义，如日志模块*WTSLogger*、基础数据模模块*WTSBaseDataMgr*等
+ ***DataKit***
	数据组件包含了数据接入以及落地的项目代码
	- WtDtCore		数据组件核心库，包含了整个数据接入落地的核心逻辑
	- WtDtPorter	数据组件C接口导出库，主要用于跨语言调用
	- QuoteFactory	这是一个C++可执行程序，作为C++环境的数据落地程序的入口
	- WtDataStorage	数据读取组件，用于读取WT自有格式的行情数据
	- WtDataStorageAD	数据落地组件，用于将行情数据落地到文件中
	- WtDtHelper	数据辅助工具，用于提供将数据转换成wt标准数据的接口
	- WtDtServo		数据伺服器，用于提供实时的数据随机访问接口
+ ***Parsers***
	Parsers包含了所有的行情解析器模块代码
	- ParserCTP		(期)对接CTP行情通道的行情解析器
	- ParserCTPMini	(期)对接CTPMini行情通道的行情解析器
	- ParserFemas	(期)对接飞马行情通道的行情解析器
	- ParserYD		(期)对接易达期货行情通道的行情解析器
	- ParserXeleSkt	(期)对接艾克朗科组播行情通道的行情解析器	
	- ParserCTPOpt	(权)对接CTPOpt期权行情通道的行情解析器
	- ParserMA		(权)对接金证期权maOpt期权行情通道的行情解析器
	- ParserAres	(权)对接QWIN期权行情通道的行情解析器
	- ParserHuax	(股)对接华鑫证券奇点行情接口的行情解析器
	- ParserXTP		(股)对接XTP行情通道的行情解析器
	- ParserOES		(股)对接宽睿行情通道的行情解析器
	- ParserUDP		对接数据组件*UDP*广播的行情数据通道的解析器
+ ***Plugins***
	Plugins包含了交易框架外部插件的项目代码
	- WtExeFact		内置的执行器工厂，提供了一个简单的执行单元
	- WtRiskMonFact	内置的风控单元工厂，提供了一个简单的组合盘资金风控的风控单元
	- WtCtaStraFact	一个示例的CTA策略工厂，内置一个C++版本的DualThrust策略
	- WtHftStraFact	一个示例的HFT策略工厂
	- WtSelStraFact 一个示例的SEL策略工厂
+ ***Product***
	Porter包含了实盘的核心项目，是整个解决方案的核心
	- WtCore		实盘交易核心库，包含了整个交易框架的核心逻辑
	- WtPorter		交易框架C接口导出库，主要用于跨语言调用
	- WtExecMon		独立执行器C接口导出库，作为独立执行器的入口
	- WtRunner		同*WtBtRunner*，实盘框架纯C++环境运行的入口
+ ***Traders***
	Traders包含了所有的交易通道的模块代码
	- TraderCTP		(期)CTP柜台交易通道对接模块
	- TraderCTPMini	(期)CTPMini柜台交易通道对接模块
	- TraderFemas	(期)飞马柜台交易通道对接模块
	- TraderYD		(期)易达柜台交易通道对接模块
	- TraderCTPOpt	(权)CTPOpt交易通道对接模块
	- TraderAresClt	(权)QWIN交易通道对接模块
	- TraderMAOpt	(权)金证期权maOpt交易通道对接模块
	- TraderXTP		(股)XTP柜台交易通道对接模块
	- TraderXTPXAlgo	(股)XTP算法交易通道对接模块
	- TraderATP		(股)华锐交易通道对接模块
	- TraderOES		(股)宽睿交易通道对接模块
	- TraderHuaX	(股)华鑫奇点交易通道对接模块
	- TraderMocker	纯本地仿真撮合模块，广泛适用于各种品种的仿真交易，减少对仿真环境的依赖，只需要接入行情就可以进行仿真交易测试
+ ***UltraFT***
	- WtUftCore		超高频引擎核心模块
	- WtUftStraFact	超高频引起示例策略工厂
	- WtUftRunner	超高频引擎实盘运行入口程序
+ ***Tools***
	- CTPLoader		CTP合约加载模块
	- MiniLoader	CTPMini合约加载模块
	- CTPOptLoader	CTPOpt合约加载模块
	- LoaderRunner	合约加载器模块运行入口程序
	- TraderDumper	交易数据落地模块，主要用于实时转储交易接口的数据
	- WtMsgQue		消息队列MQ模块，将nanomsg封装成了C接口，便于调用