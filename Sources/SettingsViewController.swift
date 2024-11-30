//
//  SettingsViewController.swift
//  WiFiLocationSwitcher
//
//  @description: 设置界面控制器,负责管理应用程序设置
//  @author: Your Name
//  @date: 2024-01-xx
//

import Cocoa

class SettingsViewController: NSViewController, NSTextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var configTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var importButton: NSButton!
    @IBOutlet weak var exportButton: NSButton!
    
    // 存储当前配置数据
    private var configurations: [(ssid: String, config: NetworkConfigurator.NetworkConfig)] = []
    
    // 在类的顶部添加一个属性来存储表单字段
    private var formFields: [String: NSTextField]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置代理和数据源
        configTableView.delegate = self
        configTableView.dataSource = self
        
        // 设置表格视图
        setupTableView()
        
        // 加载初始数据
        loadConfigurations()
    }
    
    private func setupTableView() {
        configTableView.delegate = self
        configTableView.dataSource = self
        
        // 清除现有列
        configTableView.tableColumns.forEach { configTableView.removeTableColumn($0) }
        
        // 添加所需的列
        let columns: [(id: String, title: String, width: CGFloat)] = [
            ("SSIDColumn", "WiFi名称", 120),
            ("LocationColumn", "位置", 100),
            ("IPColumn", "IP地址", 120),
            ("SubnetColumn", "子网掩码", 120),
            ("GatewayColumn", "网关", 120),
            ("DNSColumn", "DNS", 180)
        ]
        
        for column in columns {
            let tableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(column.id))
            tableColumn.title = column.title
            tableColumn.width = column.width
            tableColumn.headerCell.alignment = .center
            tableColumn.headerCell.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            configTableView.addTableColumn(tableColumn)
        }
        
        // 设置表格视图样式
        configTableView.style = .fullWidth  // 使用现代全宽样式
        configTableView.usesAlternatingRowBackgroundColors = true
        configTableView.backgroundColor = .controlBackgroundColor
        configTableView.gridStyleMask = [.solidHorizontalGridLineMask]
        configTableView.rowHeight = 30
        configTableView.intercellSpacing = NSSize(width: 10, height: 1)
        configTableView.selectionHighlightStyle = .regular
        configTableView.focusRingType = .none
        
        // 设置圆角和边框
        configTableView.wantsLayer = true
        configTableView.layer?.cornerRadius = 6
        configTableView.layer?.borderWidth = 1
        configTableView.layer?.borderColor = NSColor.separatorColor.cgColor
        configTableView.layer?.masksToBounds = true
        
        // 添加双击事件处理
        configTableView.target = self
        configTableView.doubleAction = #selector(tableViewDoubleClicked(_:))
    }
    
    private func loadConfigurations() {
        configurations = NetworkConfigurator.shared.configs.map { ($0.key, $0.value) }
        configTableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func addConfig(_ sender: Any) {
        print("添加配置按钮被点击")
        
        // 创建添加配置窗口
        let editVC = NSViewController()
        editVC.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        
        // 创建表单控件
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        editVC.view.addSubview(stackView)
        
        // 布局约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: editVC.view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: editVC.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: editVC.view.trailingAnchor, constant: -20)
        ])
        
        // SSID输入
        let ssidLabel = NSTextField(labelWithString: "WiFi名称:")
        let ssidField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        ssidField.placeholderString = "输入WiFi名称"
        ssidField.bezelStyle = .squareBezel
        ssidField.isBordered = true
        ssidField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: ssidLabel, field: ssidField))
        
        // 位置输入
        let locationLabel = NSTextField(labelWithString: "位置名称:")
        let locationField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        locationField.placeholderString = "输入位置名称"
        locationField.bezelStyle = .squareBezel
        locationField.isBordered = true
        locationField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: locationLabel, field: locationField))
        
        // IP地址输入
        let ipLabel = NSTextField(labelWithString: "IP地址:")
        let ipField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        ipField.placeholderString = "输入IP地址"
        ipField.bezelStyle = .squareBezel
        ipField.isBordered = true
        ipField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: ipLabel, field: ipField))
        
        // 子网掩码输入
        let subnetLabel = NSTextField(labelWithString: "子网掩码:")
        let subnetField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        subnetField.placeholderString = "输入子网掩码"
        subnetField.bezelStyle = .squareBezel
        subnetField.isBordered = true
        subnetField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: subnetLabel, field: subnetField))
        
        // 网关输入
        let gatewayLabel = NSTextField(labelWithString: "网关:")
        let gatewayField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        gatewayField.placeholderString = "输入网关地址"
        gatewayField.bezelStyle = .squareBezel
        gatewayField.isBordered = true
        gatewayField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: gatewayLabel, field: gatewayField))
        
        // DNS输入
        let dnsLabel = NSTextField(labelWithString: "DNS:")
        let dnsField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        dnsField.placeholderString = "输入DNS地址，多个地址用逗号分隔"
        dnsField.bezelStyle = .squareBezel
        dnsField.isBordered = true
        dnsField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: dnsLabel, field: dnsField))
        
        // 按钮容器
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        
        // 取消按钮
        let cancelButton = NSButton(title: "取消", target: self, action: #selector(cancelAdd(_:)))
        cancelButton.bezelStyle = .rounded
        
        // 保存按钮
        let saveButton = NSButton(title: "保存", target: self, action: #selector(saveNewConfig(_:)))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(buttonStack)
        
        // 存储字段引用
        self.formFields = [
            "ssid": ssidField,
            "location": locationField,
            "ip": ipField,
            "subnet": subnetField,
            "gateway": gatewayField,
            "dns": dnsField
        ]
        
        // 显示sheet
        print("准备显示配置窗口")
        self.presentAsSheet(editVC)
    }
    
    @IBAction func removeConfig(_ sender: Any) {
        guard let selectedRow = configTableView.selectedRow as? Int,
              selectedRow >= 0 && selectedRow < configurations.count else {
            showAlert(message: "请先选择要删除的配置")
            return
        }
        
        let config = configurations[selectedRow]
        
        // 显示确认对话框
        let alert = NSAlert()
        alert.messageText = "确认删除"
        alert.informativeText = "确定要删除 \(config.ssid) 的配置吗？"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "删除")
        alert.addButton(withTitle: "取消")
        
        alert.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                // 删除置
                NetworkConfigurator.shared.removeConfig(for: config.ssid)
                self.loadConfigurations()
            }
        }
    }
    
    @IBAction func importConfigs(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["json"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.beginSheetModal(for: self.view.window!) { response in
            if response == .OK {
                guard let url = openPanel.url else { return }
                
                do {
                    let data = try Data(contentsOf: url)
                    let configs = try JSONDecoder().decode([String: NetworkConfigurator.NetworkConfig].self, from: data)
                    
                    // 导入配置
                    for (ssid, config) in configs {
                        NetworkConfigurator.shared.addConfig(config, for: ssid)
                    }
                    
                    self.loadConfigurations()
                    self.showAlert(message: "配置导入成功")
                } catch {
                    self.showAlert(message: "配置导入失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func exportConfigs(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["json"]
        savePanel.nameFieldStringValue = "wifi_configs.json"
        
        savePanel.beginSheetModal(for: self.view.window!) { response in
            if response == .OK {
                guard let url = savePanel.url else { return }
                
                do {
                    let data = try JSONEncoder().encode(NetworkConfigurator.shared.configs)
                    try data.write(to: url)
                    self.showAlert(message: "配置导出成功")
                } catch {
                    self.showAlert(message: "配置导出失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func cancelAdd(_ sender: NSButton) {
        if let sheet = view.window?.attachedSheet {
            view.window?.endSheet(sheet)
            self.formFields = nil  // 清空字段引用
        }
    }
    
    @objc private func saveNewConfig(_ sender: NSButton) {
        print("保存按钮被点击")
        
        guard let fields = self.formFields else {
            print("无法获取表单字段")
            return
        }
        
        // 验证必填字段
        guard let ssid = fields["ssid"]?.stringValue, !ssid.isEmpty else {
            print("WiFi名称为空")
            showAlert(message: "请输入WiFi名称")
            return
        }
        
        guard let location = fields["location"]?.stringValue, !location.isEmpty else {
            showAlert(message: "请输入位置名称")
            return
        }
        
        guard let ip = fields["ip"]?.stringValue, !ip.isEmpty else {
            showAlert(message: "请输入IP地址")
            return
        }
        
        guard let subnet = fields["subnet"]?.stringValue, !subnet.isEmpty else {
            showAlert(message: "请输入子网掩码")
            return
        }
        
        guard let gateway = fields["gateway"]?.stringValue, !gateway.isEmpty else {
            showAlert(message: "请输入网关地址")
            return
        }
        
        // 验证IP格式
        guard isValidIP(ip) else {
            showAlert(message: "请输入有效的IP地址")
            return
        }
        
        // 验证子网掩码
        guard isValidSubnet(subnet) else {
            showAlert(message: "请输入有效的子网掩码")
            return
        }
        
        // 验证网关
        guard isValidIP(gateway) else {
            showAlert(message: "请输入有效的网关地址")
            return
        }
        
        // 验证DNS（如果有输入）
        let dnsServers = fields["dns"]?.stringValue
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []
        
        if !dnsServers.isEmpty {
            guard dnsServers.allSatisfy({ isValidIP($0) }) else {
                showAlert(message: "请输入有效的DNS地址")
                return
            }
        }
        
        print("创建新配置")
        // 创建新配置
        let newConfig = NetworkConfigurator.NetworkConfig(
            location: location,
            ip: ip,
            subnet: subnet,
            gateway: gateway,
            dns: dnsServers
        )
        
        print("添加配置到NetworkConfigurator")
        // 添加配置
        NetworkConfigurator.shared.addConfig(newConfig, for: ssid)
        
        print("刷新表格数据")
        // 刷新数据
        loadConfigurations()
        
        print("关闭配置窗口")
        // 关闭sheet
        if let sheet = view.window?.attachedSheet {
            view.window?.endSheet(sheet)
        }
        
        // 保存完成后清空字段引用
        self.formFields = nil
    }
    
    // 添加一个新的 showAlert 方法支持不同样式
    private func showAlert(title: String = "提示", message: String, style: NSAlert.Style = .warning) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: self.view.window!) { _ in }
    }
    
    // 编辑配置
    @objc func editConfiguration(_ sender: NSButton) {
        guard let row = configTableView.row(for: sender) as? Int,
              row >= 0 && row < configurations.count else { return }
        
        let config = configurations[row]
        
        // 创编辑窗口
        let editVC = NSViewController()
        editVC.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        
        // 创建表单控件
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        editVC.view.addSubview(stackView)
        
        // 布局约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: editVC.view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: editVC.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: editVC.view.trailingAnchor, constant: -20)
        ])
        
        // SSID显示(只读)
        let ssidLabel = NSTextField(labelWithString: "WiFi名称:")
        let ssidField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        ssidField.stringValue = config.ssid
        ssidField.bezelStyle = .squareBezel
        ssidField.isBordered = true
        ssidField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: ssidLabel, field: ssidField))
        
        // 位置输入
        let locationLabel = NSTextField(labelWithString: "位置名称:")
        let locationField = NSTextField(string: config.config.location)
        stackView.addArrangedSubview(createFormRow(label: locationLabel, field: locationField))
        
        // IP地址输入
        let ipLabel = NSTextField(labelWithString: "IP地址:")
        let ipField = NSTextField(string: config.config.ip)
        stackView.addArrangedSubview(createFormRow(label: ipLabel, field: ipField))
        
        // 子网掩码输入
        let subnetLabel = NSTextField(labelWithString: "子网掩码:")
        let subnetField = NSTextField(string: config.config.subnet)
        stackView.addArrangedSubview(createFormRow(label: subnetLabel, field: subnetField))
        
        // 网关输入
        let gatewayLabel = NSTextField(labelWithString: "网关:")
        let gatewayField = NSTextField(string: config.config.gateway)
        stackView.addArrangedSubview(createFormRow(label: gatewayLabel, field: gatewayField))
        
        // DNS输入
        let dnsLabel = NSTextField(labelWithString: "DNS:")
        let dnsField = NSTextField(string: config.config.dns.joined(separator: ","))
        stackView.addArrangedSubview(createFormRow(label: dnsLabel, field: dnsField))
        
        // 添加按钮容器
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        
        // 取消按钮
        let cancelButton = NSButton(title: "取消", target: self, action: #selector(cancelEdit(_:)))
        cancelButton.bezelStyle = .rounded
        
        // 保存按钮
        let saveButton = NSButton(title: "保存", target: self, action: #selector(saveConfiguration(_:)))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r" // 回车键触发保存
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(buttonStack)
        
        // 显示sheet
        self.presentAsSheet(editVC)
        
        // 存储临时数据用于保存
        saveButton.tag = row
        objc_setAssociatedObject(saveButton, "editFields", [
            "location": locationField,
            "ip": ipField,
            "subnet": subnetField,
            "gateway": gatewayField,
            "dns": dnsField
        ], .OBJC_ASSOCIATION_RETAIN)
    }
    
    private func createFormRow(label: NSTextField, field: NSTextField) -> NSStackView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 10
        row.distribution = .fill
        
        // 设置标签样式
        label.alignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // 设置输入框样式
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(field)
        
        return row
    }
    
    @objc func saveConfiguration(_ sender: NSButton) {
        guard let fields = self.formFields else { return }
        
        // 验证输入
        guard validateInput(fields) else { return }
        
        guard let row = sender.tag as? Int,
              row >= 0 && row < configurations.count else { return }
        
        let oldSSID = configurations[row].ssid
        let newSSID = fields["ssid"]?.stringValue ?? oldSSID
        
        // 创建新的配置
        let newConfig = NetworkConfigurator.NetworkConfig(
            location: fields["location"]?.stringValue ?? "",
            ip: fields["ip"]?.stringValue ?? "",
            subnet: fields["subnet"]?.stringValue ?? "",
            gateway: fields["gateway"]?.stringValue ?? "",
            dns: fields["dns"]?.stringValue.components(separatedBy: ",") ?? []
        )
        
        // 如果 SSID 改变了，先删除旧配置
        if oldSSID != newSSID {
            NetworkConfigurator.shared.removeConfig(for: oldSSID)
        }
        
        // 添加新配置
        NetworkConfigurator.shared.addConfig(newConfig, for: newSSID)
        
        // 刷新数据
        loadConfigurations()
        
        // 关闭sheet
        if let sheet = view.window?.attachedSheet {
            view.window?.endSheet(sheet)
        }
    }
    
    private func validateInput(_ fields: [String: NSTextField]) -> Bool {
        // IP地址验证
        guard let ip = fields["ip"]?.stringValue,
              isValidIP(ip) else {
            showAlert(message: "请输入有效的IP地址")
            return false
        }
        
        // 子网掩码验证
        guard let subnet = fields["subnet"]?.stringValue,
              isValidSubnet(subnet) else {
            showAlert(message: "请输入有效的子网掩码")
            return false
        }
        
        // 网关验证
        guard let gateway = fields["gateway"]?.stringValue,
              isValidIP(gateway) else {
            showAlert(message: "请输入有效的网关地址")
            return false
        }
        
        // DNS验证
        guard let dns = fields["dns"]?.stringValue.components(separatedBy: ","),
              dns.allSatisfy({ isValidIP($0) }) else {
            showAlert(message: "请输入有效的DNS地址")
            return false
        }
        
        return true
    }
    
    private func isValidIP(_ string: String) -> Bool {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 4 else { return false }
        
        return parts.allSatisfy { part in
            guard let number = Int(part),
                  number >= 0 && number <= 255 else {
                return false
            }
            return true
        }
    }
    
    private func isValidSubnet(_ string: String) -> Bool {
        // 简化的子网掩码验证
        let validSubnets = [
            "255.255.255.0",
            "255.255.0.0",
            "255.0.0.0"
        ]
        return validSubnets.contains(string)
    }
    
    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "输入错误"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: self.view.window!) { _ in }
    }
    
    @objc private func cancelEdit(_ sender: NSButton) {
        if let sheet = view.window?.attachedSheet {
            view.window?.endSheet(sheet)
        }
    }
    
    // 处理双击事件
    @objc private func tableViewDoubleClicked(_ sender: Any) {
        let clickedRow = configTableView.clickedRow
        let clickedColumn = configTableView.clickedColumn
        
        guard clickedRow >= 0, clickedRow < configurations.count,
              clickedColumn >= 0, clickedColumn < configTableView.tableColumns.count,
              let tableColumn = configTableView.tableColumns[safe: clickedColumn] else {
            return
        }
        
        if tableColumn.identifier.rawValue == "SSIDColumn" {
            return
        }
        
        let config = configurations[clickedRow]
        showEditSheet(for: config, row: clickedRow)
    }
    
    // 重命名原来的 editConfiguration 方法为 showEditSheet
    private func showEditSheet(for config: (ssid: String, config: NetworkConfigurator.NetworkConfig), row: Int) {
        let editVC = NSViewController()
        editVC.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        
        // 创建表单控件
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        editVC.view.addSubview(stackView)
        
        // 布局约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: editVC.view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: editVC.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: editVC.view.trailingAnchor, constant: -20)
        ])
        
        // SSID显示
        let ssidLabel = NSTextField(labelWithString: "WiFi名称:")
        let ssidField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        ssidField.stringValue = config.ssid
        ssidField.bezelStyle = .squareBezel
        ssidField.isBordered = true
        ssidField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: ssidLabel, field: ssidField))
        
        // 位置输入
        let locationLabel = NSTextField(labelWithString: "位置名称:")
        let locationField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        locationField.stringValue = config.config.location
        locationField.bezelStyle = .squareBezel
        locationField.isBordered = true
        locationField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: locationLabel, field: locationField))
        
        // IP地址输入
        let ipLabel = NSTextField(labelWithString: "IP地址:")
        let ipField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        ipField.stringValue = config.config.ip
        ipField.bezelStyle = .squareBezel
        ipField.isBordered = true
        ipField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: ipLabel, field: ipField))
        
        // 子网掩码输入
        let subnetLabel = NSTextField(labelWithString: "子网掩码:")
        let subnetField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        subnetField.stringValue = config.config.subnet
        subnetField.bezelStyle = .squareBezel
        subnetField.isBordered = true
        subnetField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: subnetLabel, field: subnetField))
        
        // 网关输入
        let gatewayLabel = NSTextField(labelWithString: "网关:")
        let gatewayField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        gatewayField.stringValue = config.config.gateway
        gatewayField.bezelStyle = .squareBezel
        gatewayField.isBordered = true
        gatewayField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: gatewayLabel, field: gatewayField))
        
        // DNS输入
        let dnsLabel = NSTextField(labelWithString: "DNS:")
        let dnsField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
        dnsField.stringValue = config.config.dns.joined(separator: ", ")
        dnsField.bezelStyle = .squareBezel
        dnsField.isBordered = true
        dnsField.drawsBackground = true
        stackView.addArrangedSubview(createFormRow(label: dnsLabel, field: dnsField))
        
        // 按钮容器
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        
        // 取消按钮
        let cancelButton = NSButton(title: "取消", target: self, action: #selector(cancelEdit(_:)))
        cancelButton.bezelStyle = .rounded
        
        // 保存按钮
        let saveButton = NSButton(title: "保存", target: self, action: #selector(saveConfiguration(_:)))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(buttonStack)
        
        // 存储临时数据用于保存
        saveButton.tag = row
        self.formFields = [
            "ssid": ssidField,
            "location": locationField,
            "ip": ipField,
            "subnet": subnetField,
            "gateway": gatewayField,
            "dns": dnsField
        ]
        
        // 显示sheet
        self.presentAsSheet(editVC)
    }
    
    // MARK: - NSTextFieldDelegate
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
              let cell = textField.superview as? NSTableCellView else {
            return
        }
        
        // 获取行和列索引
        let row = configTableView.row(for: cell)
        let column = configTableView.column(for: textField)
        
        // 验证行和列索引的有效性
        guard row >= 0, row < configurations.count,
              column >= 0, column < configTableView.tableColumns.count,
              let tableColumn = configTableView.tableColumns[safe: column] else {
            return
        }
        
        if tableColumn.identifier.rawValue == "SSIDColumn" {
            return
        }
        
        let config = configurations[row]
        var newConfig = config.config
        
        // 根据列更新相应的配置
        switch tableColumn.identifier.rawValue {
        case "LocationColumn":
            newConfig = NetworkConfigurator.NetworkConfig(
                location: textField.stringValue,
                ip: config.config.ip,
                subnet: config.config.subnet,
                gateway: config.config.gateway,
                dns: config.config.dns
            )
        case "IPColumn":
            if isValidIP(textField.stringValue) {
                newConfig = NetworkConfigurator.NetworkConfig(
                    location: config.config.location,
                    ip: textField.stringValue,
                    subnet: config.config.subnet,
                    gateway: config.config.gateway,
                    dns: config.config.dns
                )
            }
        case "SubnetColumn":
            if isValidSubnet(textField.stringValue) {
                newConfig = NetworkConfigurator.NetworkConfig(
                    location: config.config.location,
                    ip: config.config.ip,
                    subnet: textField.stringValue,
                    gateway: config.config.gateway,
                    dns: config.config.dns
                )
            }
        case "GatewayColumn":
            if isValidIP(textField.stringValue) {
                newConfig = NetworkConfigurator.NetworkConfig(
                    location: config.config.location,
                    ip: config.config.ip,
                    subnet: config.config.subnet,
                    gateway: textField.stringValue,
                    dns: config.config.dns
                )
            }
        case "DNSColumn":
            let dnsServers = textField.stringValue.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if dnsServers.allSatisfy({ isValidIP($0) }) {
                newConfig = NetworkConfigurator.NetworkConfig(
                    location: config.config.location,
                    ip: config.config.ip,
                    subnet: config.config.subnet,
                    gateway: config.config.gateway,
                    dns: dnsServers
                )
            }
        default:
            break
        }
        
        // 更新配置
        NetworkConfigurator.shared.updateConfig(newConfig, for: config.ssid)
        loadConfigurations()  // 刷新表格数据
    }
    
    // MARK: - Table View Delegate & DataSource
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < configurations.count else { return nil }
        
        let config = configurations[row]
        
        // 创建单元格视图
        let cell = NSTableCellView()
        let textField = NSTextField()
        cell.addSubview(textField)
        cell.textField = textField
        
        // 设置文本框样式
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = true
        textField.isSelectable = true
        textField.alignment = .center
        textField.font = NSFont.systemFont(ofSize: 13)
        textField.textColor = .labelColor
        
        // 创建一个容器视图来实现垂直居中
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(containerView)
        containerView.addSubview(textField)
        
        // 设置容器视图约束
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: cell.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
        ])
        
        // 设置文本框约束
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 17)  // 设置固定高度
        ])
        
        // 设置单元格属性
        if let textFieldCell = textField.cell as? NSTextFieldCell {
            textFieldCell.usesSingleLineMode = true
            textFieldCell.lineBreakMode = .byTruncatingTail
            textFieldCell.isScrollable = false
            textFieldCell.wraps = false
            textFieldCell.truncatesLastVisibleLine = true
        }
        
        // 设置内容
        switch tableColumn?.identifier.rawValue {
        case "SSIDColumn":
            textField.stringValue = config.ssid
            textField.isEditable = false
        case "LocationColumn":
            textField.stringValue = config.config.location
        case "IPColumn":
            textField.stringValue = config.config.ip
        case "SubnetColumn":
            textField.stringValue = config.config.subnet
        case "GatewayColumn":
            textField.stringValue = config.config.gateway
        case "DNSColumn":
            textField.stringValue = config.config.dns.joined(separator: ", ")
        default:
            break
        }
        
        textField.delegate = self
        return cell
    }
}

// MARK: - NSTableViewDelegate & NSTableViewDataSource
extension SettingsViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return configurations.count
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return tableColumn?.identifier.rawValue != "SSIDColumn"  // 除了SSID列外都可以编辑
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 
