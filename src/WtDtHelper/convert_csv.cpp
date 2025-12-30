/*!
 * CSV转.dsb格式的转换工具
 * 使用WtDtHelper库将CSV格式的K线数据转换为.dsb格式
 */

#include "WtDtHelper.h"
#include <iostream>
#include <cstring>

// 日志回调函数
void on_log(const char* message)
{
    std::cout << message << std::endl;
}

int main(int argc, char* argv[])
{
    if (argc < 4)
    {
        std::cout << "用法: " << argv[0] << " <csv文件夹> <dsb输出文件夹> <周期>" << std::endl;
        std::cout << "示例: " << argv[0] << " /path/to/csv /path/to/dsb m1" << std::endl;
        std::cout << "周期: m1=1分钟, m5=5分钟, d=日线" << std::endl;
        return 1;
    }

    const char* csvFolder = argv[1];
    const char* dsbFolder = argv[2];
    const char* period = argv[3];

    std::cout << "========================================" << std::endl;
    std::cout << "CSV转.dsb格式转换工具" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "CSV文件夹: " << csvFolder << std::endl;
    std::cout << "DSB输出文件夹: " << dsbFolder << std::endl;
    std::cout << "周期: " << period << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << std::endl;

    // 调用WtDtHelper的trans_csv_bars函数
    trans_csv_bars(csvFolder, dsbFolder, period, on_log);

    std::cout << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "转换完成！" << std::endl;
    std::cout << "========================================" << std::endl;

    return 0;
}

