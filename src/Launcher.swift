import AppKit
import Foundation

struct GameChoice {
 let id: String
 let title: String
}

final class Launcher: NSObject, NSApplicationDelegate, NSWindowDelegate {
 let games = [GameChoice(id: "kof94", title: "拳皇 94"), GameChoice(id: "kof95", title: "拳皇 95"),
              GameChoice(id: "kof96", title: "拳皇 96"), GameChoice(id: "kof97", title: "拳皇 97"),
              GameChoice(id: "kof98x", title: "拳皇 98"), GameChoice(id: "kof99x", title: "拳皇 99"),
              GameChoice(id: "kof00x", title: "拳皇 2000"), GameChoice(id: "kof01x", title: "拳皇 2001"),
              GameChoice(id: "kof02x", title: "拳皇 2002"), GameChoice(id: "kof03x", title: "拳皇 2003")]
 let support = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support").appendingPathComponent((Bundle.main.object(forInfoDictionaryKey: "KOFSupportDirectoryName") as? String) ?? "KOF10Mac")
 var task: Process?
 var window: NSWindow?
 var timer: Timer?
 var statusLabel: NSTextField?
 var progress: NSProgressIndicator?
 var currentGame = "kof02x"
 var pendingGame: String?
 var isQuitting = false
 var libraryVisible = false
 var preparing = false

 func applicationDidFinishLaunching(_ notification: Notification) {
  let menu = NSMenu()
  let item = NSMenuItem(); menu.addItem(item)
  let submenu = NSMenu(); item.submenu = submenu
  let choose = submenu.addItem(withTitle: "换一款游戏…", action: #selector(showLibrary), keyEquivalent: "g")
  choose.keyEquivalentModifierMask = [.command, .shift]
  submenu.addItem(withTitle: "打开存档目录", action: #selector(openSaves), keyEquivalent: "")
  submenu.addItem(withTitle: "打开运行日志", action: #selector(openLogs), keyEquivalent: "")
  submenu.addItem(NSMenuItem.separator())
  submenu.addItem(withTitle: "退出拳皇十周年", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
  NSApp.mainMenu = menu
  let saved = try? String(contentsOf: support.appendingPathComponent("selected-game"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
  if let saved = saved, games.contains(where: { $0.id == saved }) { currentGame = saved }
  startGame()
 }

 func makeWindow(width: CGFloat, height: CGFloat) -> NSView {
  if window == nil {
   window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: height), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
   window?.isReleasedWhenClosed = false
   window?.delegate = self
   window?.title = "拳皇十周年 Mac"
  }
  let view = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
  window?.contentView = view
  window?.setContentSize(NSSize(width: width, height: height))
  window?.center()
  window?.makeKeyAndOrderFront(nil)
  NSApp.activate(ignoringOtherApps: true)
  return view
 }

 @discardableResult
 func label(_ text: String, frame: NSRect, size: CGFloat = 14, bold: Bool = false, in view: NSView) -> NSTextField {
  let field = NSTextField(labelWithString: text)
  field.frame = frame
  field.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
  view.addSubview(field)
  return field
 }

 func showPreparation() {
  libraryVisible = false
  preparing = true
  let view = makeWindow(width: 520, height: 270)
  let icon = NSImageView(frame: NSRect(x: 30, y: 175, width: 64, height: 64))
  icon.image = NSApp.applicationIconImage; view.addSubview(icon)
  let title = games.first(where: { $0.id == (pendingGame ?? currentGame) })?.title ?? "拳皇 2002"
  label("正在打开\(title)", frame: NSRect(x: 112, y: 194, width: 375, height: 32), size: 23, bold: true, in: view)
  label("准备完成后自动进入游戏", frame: NSRect(x: 112, y: 168, width: 375, height: 24), in: view)
  statusLabel = label("正在准备，请稍等…", frame: NSRect(x: 32, y: 124, width: 456, height: 26), in: view)
  let bar = NSProgressIndicator(frame: NSRect(x: 32, y: 98, width: 456, height: 14))
  bar.style = .bar; bar.isIndeterminate = true; bar.startAnimation(nil); view.addSubview(bar); progress = bar
  label("键盘：2 投币 → 1 开始  ·  WASD 移动  ·  J K U I 攻击", frame: NSRect(x: 32, y: 52, width: 470, height: 24), size: 13, in: view)
  let hint = label("换游戏：点 Dock 中的地球图标，选择想玩的版本", frame: NSRect(x: 32, y: 23, width: 470, height: 24), size: 12, in: view)
  hint.textColor = .secondaryLabelColor
 }

 func startGame() {
  timer?.invalidate()
  showPreparation()
  do {
   try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
   try Data("\(currentGame)\n".utf8).write(to: support.appendingPathComponent("selected-game"), options: .atomic)
   try Data("preparing\n".utf8).write(to: support.appendingPathComponent("run.state"), options: .atomic)
   let p = Process()
   p.executableURL = URL(fileURLWithPath: "/bin/bash")
   p.arguments = [Bundle.main.resourceURL!.appendingPathComponent("launch.sh").path]
   var environment = ProcessInfo.processInfo.environment
   environment["KOF_SUPPORT_DIR"] = support.path
   environment["KOF_GAME_ID"] = currentGame
   p.environment = environment
   p.terminationHandler = { [weak self] process in
    DispatchQueue.main.async { self?.gameStopped(status: process.terminationStatus) }
   }
   task = p
   try p.run()
   timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in self?.updatePreparation() }
  } catch {
   task = nil; preparing = false
   showFailure(message: "暂时无法准备游戏，请重试。", details: error.localizedDescription)
  }
 }

 func updatePreparation() {
  let state = try? String(contentsOf: support.appendingPathComponent("run.state"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
  if state == "downloading" {
   let path = support.appendingPathComponent("Downloads/wine-stable-11.0_1-osx64.tar.xz.part").path
   let attributes = try? FileManager.default.attributesOfItem(atPath: path)
   let bytes = (attributes?[.size] as? NSNumber)?.doubleValue ?? 0
   let percent = min(99, max(0, bytes / 185303032.0 * 100))
   progress?.isIndeterminate = false; progress?.doubleValue = percent
   statusLabel?.stringValue = "第一次打开，正在自动准备 · \(Int(percent))%"
  } else if state == "preparing" {
   if progress?.isIndeterminate == false { progress?.isIndeterminate = true; progress?.startAnimation(nil) }
   statusLabel?.stringValue = "正在准备游戏，请稍等…"
  } else if state == "ready" {
   preparing = false
   window?.orderOut(nil)
   timer?.invalidate()
  }
 }

 func gameStopped(status: Int32) {
  timer?.invalidate(); task = nil; preparing = false
  guard !isQuitting else { return }
  if let next = pendingGame {
   pendingGame = nil; currentGame = next; startGame(); return
  }
  if status == 10 { offerRosetta(); return }
  if status != 0 {
   let downloadFailure = [20, 21, 22].contains(status)
   showFailure(message: downloadFailure ? "首次准备还未完成" : "游戏暂时没能打开", details: downloadFailure ? "请确认 Mac 已联网，然后点“重试”。已完成的下载会保留。" : "可以重试，或打开日志查看详情。")
  } else if libraryVisible {
   showLibrary()
  } else {
   NSApp.terminate(nil)
  }
 }

 func showFailure(message: String, details: String) {
  window?.orderOut(nil)
  let alert = NSAlert(); alert.messageText = message; alert.informativeText = details
  alert.addButton(withTitle: "重试"); alert.addButton(withTitle: "退出"); alert.addButton(withTitle: "查看日志")
  NSApp.activate(ignoringOtherApps: true)
  switch alert.runModal() {
   case .alertFirstButtonReturn: startGame()
   case .alertThirdButtonReturn: openLogs(); showLibrary()
   default: NSApp.terminate(nil)
  }
 }

 func offerRosetta() {
  window?.orderOut(nil)
  let alert = NSAlert(); alert.messageText = "Mac 需要 Apple 的兼容组件"
  alert.informativeText = "点下方按钮打开 Apple 安装窗口，按系统提示完成安装。完成后游戏会自动继续。"
  alert.addButton(withTitle: "打开 Apple 安装窗口"); alert.addButton(withTitle: "退出")
  NSApp.activate(ignoringOtherApps: true)
  guard alert.runModal() == .alertFirstButtonReturn else { NSApp.terminate(nil); return }
  let updater = URL(fileURLWithPath: "/System/Library/CoreServices/Rosetta 2 Updater.app")
  guard FileManager.default.fileExists(atPath: updater.path), NSWorkspace.shared.open(updater) else {
   showFailure(message: "需要先安装 Rosetta", details: "Apple 安装窗口无法打开。请按安装说明完成 Rosetta 安装，再点重试。"); return
  }
  showPreparation()
  statusLabel?.stringValue = "请在 Apple 安装窗口完成操作，游戏会自动继续"
  timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
   guard let self = self else { return }
   let check = Process(); check.executableURL = URL(fileURLWithPath: "/usr/bin/arch"); check.arguments = ["-x86_64", "/usr/bin/true"]
   check.standardOutput = FileHandle.nullDevice; check.standardError = FileHandle.nullDevice
   do { try check.run(); check.waitUntilExit(); if check.terminationStatus == 0 { self.timer?.invalidate(); self.startGame() } } catch {}
  }
 }

 @objc func showLibrary() {
  if preparing { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true); return }
  libraryVisible = true
  let view = makeWindow(width: 520, height: 405)
  label("今天想玩哪一款？", frame: NSRect(x: 30, y: 345, width: 460, height: 38), size: 25, bold: true, in: view)
  label("点击即进入，下次打开会记住你的选择", frame: NSRect(x: 30, y: 309, width: 460, height: 26), in: view)
  for (index, game) in games.enumerated() {
   let button = NSButton(title: game.title, target: self, action: #selector(chooseGame(_:)))
   button.frame = NSRect(x: 30 + CGFloat(index % 2) * 240, y: 250 - CGFloat(index / 2) * 49, width: 220, height: 40)
   button.bezelStyle = .rounded; button.font = .systemFont(ofSize: 17, weight: .medium); button.tag = index
   view.addSubview(button)
  }
  label("2 投币  ·  1 开始  ·  WASD 移动  ·  J K U I 攻击", frame: NSRect(x: 30, y: 14, width: 460, height: 24), size: 13, in: view)
 }

 @objc func chooseGame(_ sender: NSButton) {
  let game = games[sender.tag].id
  if let task = task, task.isRunning {
   pendingGame = game; showPreparation(); statusLabel?.stringValue = "正在保存设置并切换游戏…"
   do { try Data().write(to: support.appendingPathComponent("switch.request"), options: .atomic) }
   catch { pendingGame = nil; preparing = false; showLibrary() }
  } else { currentGame = game; startGame() }
 }

 func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showLibrary(); return true }
 func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
  let menu = NSMenu(); menu.addItem(withTitle: "换一款游戏…", action: #selector(showLibrary), keyEquivalent: ""); return menu
 }
 func windowShouldClose(_ sender: NSWindow) -> Bool {
  if task?.isRunning == true && !preparing { libraryVisible = false; sender.orderOut(nil) }
  else { NSApp.terminate(nil) }
  return false
 }
 @objc func openSaves() { NSWorkspace.shared.open(support.appendingPathComponent("Prefix/drive_c/KOF")) }
 @objc func openLogs() { NSWorkspace.shared.open(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/KOF10Mac")) }
 func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
  isQuitting = true; pendingGame = nil; timer?.invalidate()
  if let task = task, task.isRunning { task.terminate() }
  return .terminateNow
 }
}

let app = NSApplication.shared
let delegate = Launcher()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
