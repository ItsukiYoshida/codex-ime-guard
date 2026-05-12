import AppKit
import ApplicationServices
import Carbon
import Foundation

private let defaultAsciiSource = "com.apple.keylayout.ABC"
private let defaultTargetBundleIDs: Set<String> = [
    "com.apple.Terminal",
    "com.googlecode.iterm2",
    "com.github.wez.wezterm",
    "com.mitchellh.ghostty",
    "dev.warp.Warp-Stable",
    "dev.warp.Warp",
    "net.kovidgoyal.kitty",
    "org.alacritty",
    "io.alacritty",
    "com.microsoft.VSCode",
]

private func envSet(_ name: String, fallback: Set<String>) -> Set<String> {
    guard let value = ProcessInfo.processInfo.environment[name], !value.isEmpty else {
        return fallback
    }
    return Set(
        value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    )
}

private func currentInputSourceID() -> String? {
    guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
        let rawID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
    else {
        return nil
    }
    return Unmanaged<CFString>.fromOpaque(rawID).takeUnretainedValue() as String
}

private func selectInputSource(_ id: String) {
    if currentInputSourceID() == id {
        return
    }

    let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
    guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
        let source = list.first
    else {
        fputs("codex-ime-guard: input source not found: \(id)\n", stderr)
        return
    }
    TISSelectInputSource(source)
}

private final class ImeGuard {
    private let asciiSourceID: String
    private let targetBundleIDs: Set<String>
    private var previousInputSourceID: String?
    private var assumesVimNormal = true
    private var eventTap: CFMachPort?

    init(asciiSourceID: String, targetBundleIDs: Set<String>) {
        self.asciiSourceID = asciiSourceID
        self.targetBundleIDs = targetBundleIDs
    }

    func start() -> Bool {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let unmanagedSelf = Unmanaged.passUnretained(self).toOpaque()
        guard
            let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: mask,
                callback: eventTapCallback,
                userInfo: unmanagedSelf
            )
        else {
            fputs(
                "codex-ime-guard: failed to create event tap. Enable Accessibility permission for this tool.\n",
                stderr)
            return false
        }

        eventTap = tap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        if isTargetAppFrontmost(), assumesVimNormal {
            rememberCurrentInputSource()
            selectInputSource(asciiSourceID)
        }

        fputs(
            "codex-ime-guard: running. ASCII source=\(asciiSourceID), apps=\(targetBundleIDs.sorted().joined(separator: ","))\n",
            stderr)
        CFRunLoopRun()
        return true
    }

    func handle(_ type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        guard type == .keyDown, isTargetAppFrontmost() else {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        if keyCode == CGKeyCode(kVK_Escape) {
            rememberCurrentInputSource()
            selectInputSource(asciiSourceID)
            assumesVimNormal = true
            return Unmanaged.passUnretained(event)
        }

        if (keyCode == CGKeyCode(kVK_Return) || keyCode == CGKeyCode(kVK_ANSI_KeypadEnter))
            && flags.contains(.maskControl)
        {
            rememberCurrentInputSource()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [asciiSourceID] in
                selectInputSource(asciiSourceID)
            }
            assumesVimNormal = true
            return Unmanaged.passUnretained(event)
        }

        if assumesVimNormal && isSimpleInsertEntryKey(keyCode) {
            let restoreID = previousInputSourceID
            assumesVimNormal = false
            if let restoreID, restoreID != asciiSourceID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    selectInputSource(restoreID)
                }
            }
        }

        return Unmanaged.passUnretained(event)
    }

    private func rememberCurrentInputSource() {
        guard let current = currentInputSourceID(), current != asciiSourceID else {
            return
        }
        previousInputSourceID = current
    }

    private func isTargetAppFrontmost() -> Bool {
        guard let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
            return false
        }
        return targetBundleIDs.contains(bundleID)
    }

    private func isSimpleInsertEntryKey(_ keyCode: CGKeyCode) -> Bool {
        keyCode == CGKeyCode(kVK_ANSI_I)
            || keyCode == CGKeyCode(kVK_ANSI_A)
            || keyCode == CGKeyCode(kVK_ANSI_O)
            || keyCode == CGKeyCode(kVK_Help)
    }
}

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else {
        return Unmanaged.passUnretained(event)
    }
    let guardInstance = Unmanaged<ImeGuard>.fromOpaque(userInfo).takeUnretainedValue()
    return guardInstance.handle(type, event: event)
}

func runImeGuard() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    if !AXIsProcessTrustedWithOptions(options) {
        fputs(
            "codex-ime-guard: Accessibility permission is required. Grant it in System Settings, then start this tool again.\n",
            stderr)
        RunLoop.current.run(until: Date().addingTimeInterval(20))
        exit(1)
    }

    let asciiSource = ProcessInfo.processInfo.environment["CODEX_IME_GUARD_ASCII_SOURCE"] ?? defaultAsciiSource
    let targetApps = envSet("CODEX_IME_GUARD_APPS", fallback: defaultTargetBundleIDs)

    let guardInstance = ImeGuard(asciiSourceID: asciiSource, targetBundleIDs: targetApps)
    if !guardInstance.start() {
        RunLoop.current.run(until: Date().addingTimeInterval(20))
        exit(1)
    }
}
