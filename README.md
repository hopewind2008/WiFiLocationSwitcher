# WiFiLocationSwitcher

WiFiLocationSwitcher 是一个 macOS 状态栏应用程序，可以根据不同的 WiFi 网络自动切换网络配置。当你在不同场所（如公司、家里）切换 WiFi 时，它会自动应用预设的 IP、子网掩码、网关和 DNS 设置。

## 功能特点

- 自动检测 WiFi 网络变化
- 根据 WiFi SSID 自动切换网络配置
- 支持配置 IP 地址、子网掩码、网关和 DNS
- 状态栏快速访问
- 配置导入导出功能
- 失败时自动重试
- 系统通知提醒
- 开机自动启动功能

## 系统要求

- macOS 11.0 或更高版本
- 需要管理员权限以修改网络设置

## 安装

1. 下载最新版本的 WiFiLocationSwitcher.app
2. 将应用程序移动到 Applications 文件夹
3. 首次运行时需要授予管理员权限

## 使用方法

1. 启动应用程序，状态栏会出现一个 📡 图标
2. 点击图标，选择"设置..."打开配置窗口
3. 点击"+"按钮添加新的网络配置：
   - WiFi名称：要匹配的 WiFi SSID
   - 位置：方便识别的位置名称（如公司、家里、宿舍）
   - IP地址：要设置的静态 IP
   - 子网掩码：通常是 255.255.255.0
   - 网关：路由器地址
   - DNS：DNS 服务器地址（多个地址用逗号分隔）
4. 连接到配置过的 WiFi 网络时，应用会自动应用对应的网络设置

### 状态图标说明

- 📡：正常运行
- ⏳：正在配置网络
- ⚠️：配置失败

### 快捷键

- `,`：打开设置窗口
- `r`：重试上次配置
- `q`：退出应用程序

### 开机启动

- 点击状态栏菜单中的"开机启动"选项可以启用/禁用开机自动启动
- 启用后，系统启动时会自动运行应用程序
- 需要系统授权才能修改开机启动设置

## 配置导入导出

- 在设置窗口中使用"导出"按钮可以将当前配置保存为 JSON 文件
- 使用"导入"按钮可以从之前导出的 JSON 文件中恢复配置

## 故障排除

1. 如果配置失败：
   - 检查是否授予了管理员权限
   - 确认输入的网络配置是否正确
   - 使用"重试上次配置"选项
   - 查看系统日志获取详细错误信息

2. 如果没有自动切换：
   - 确认 WiFi SSID 是否完全匹配
   - 检查应用程序是否正在运行
   - 尝试重新连接 WiFi 网络

## 更新日志

### v1.1 (2024-03-xx)
- 优化了表格显示效果
- 改进了网络配置编辑功能
- 修复了设置窗口的显示问题
- 提升了应用稳定性

## 开发

### 构建要求

- Xcode 14.0 或更高版本
- Swift 5.0
- macOS 11.0 SDK

### 项目结构

WiFiLocationSwitcher/
├── Sources/
│   ├── AppDelegate.swift        # 应用程序主入口
│   ├── NetworkConfigurator.swift # 网络配置管理
│   ├── WiFiMonitor.swift        # WiFi 监控
│   └── SettingsViewController.swift # 设置界面控制
├── Resources/
│   ├── Settings.xib             # 设置界面布局
│   └── AppIcon.svg              # 应用图标
└── Supporting Files/
    ├── Info.plist               # 应用配置
    └── WiFiLocationSwitcher.entitlements # 权限配置
