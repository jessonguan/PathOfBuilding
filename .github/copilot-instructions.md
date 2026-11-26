# PathOfBuilding 工作区 AI 规则

## 验证策略：只做语法检查与静态核对

在本仓库中，除非用户当次明确要求，否则**不要执行**以下操作：

- 不运行、不构建、不启动 PoB 本体（`runtime/Path of Building.exe`、`HeadlessWrapper.lua`）。
- 不运行 `busted` 测试，也不为了跑测试去安装 lua / luajit / luarocks。
- 不通过 `uv` / `pip` / `npm` 安装任何包，不拉取或运行 docker 镜像（本项目测试镜像在 CI 里用）。
- 不为了验证而临时搭建运行时（例如用 Python 的 lupa 内嵌 Lua 执行代码）。

允许的验证手段：

- **语法检查**：只做解析/结构核对——块配平、`end` 配对、字符串与括号闭合，或用现成的只读检查工具（如已安装的 `luacheck`）。
- **静态核对**：阅读代码确认数据流、路径拼接、字段名、调用方、与 `manifest.cfg` / `manifest.xml` 的覆盖关系是否一致。
- **数据核对**：只读读取仓库内文件（如 `src/Data/**`）做统计与字段确认，不执行被修改的程序逻辑。

测试执行归属：`.github/workflows/test.yml` 中的 `busted --lua=luajit`（CI），或用户本地自行执行。新增的 spec 只需保证语法合法、断言与代码实际行为相符。

交付时必须明确区分「已验证项（语法/静态）」与「未验证项（依赖 CI 或用户执行）」。

## 环境事实（解释上面限制的原因）

- 平台为 Windows，shell 是 Windows PowerShell 5.1 兼容语法（不支持 `&&`、`||`）。
- `python` 指向 Windows Store 占位符，直接调用会以 9009 退出；`py` 不存在。
- 本机没有 lua / luajit / busted / docker。
- PowerShell 的 `Get-Content` 默认按 ANSI 解码，读 UTF-8 文件会出现乱码；查看中文内容用 `view` 工具或显式指定 `-Encoding UTF8`。

## 改动范围

- 用户明确要求的范围内做完整、可用的改动；发现紧耦合的既有缺陷要先说明再改，不要自行扩大范围。
