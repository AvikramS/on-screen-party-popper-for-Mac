import Cocoa
import Carbon
import QuartzCore

extension NSColor {
    func lighter(by amount: CGFloat = 0.2) -> NSColor {
        return self.withColorComponent(by: amount)
    }
    
    func darker(by amount: CGFloat = 0.15) -> NSColor {
        return self.withColorComponent(by: -amount)
    }
    
    private func withColorComponent(by amount: CGFloat) -> NSColor {
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else { return self }
        return NSColor(
            red: min(max(rgbColor.redComponent + amount, 0.0), 1.0),
            green: min(max(rgbColor.greenComponent + amount, 0.0), 1.0),
            blue: min(max(rgbColor.blueComponent + amount, 0.0), 1.0),
            alpha: rgbColor.alphaComponent
        )
    }
}

class ConfettiWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let contentView = NSView(frame: screen.frame)
        contentView.wantsLayer = true
        self.contentView = contentView
    }
}

class ConfettiManager {
    static let shared = ConfettiManager()
    
    var windows: [ConfettiWindow] = []
    var leftEmitters: [CAEmitterLayer] = []
    var rightEmitters: [CAEmitterLayer] = []
    var sound: NSSound?
    
    private init() {
        setupSound()
        setupWindows()
    }
    
    func setupSound() {
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath + "/pop.wav"
        let execPath = (Bundle.main.bundlePath as NSString).appendingPathComponent("pop.wav")
        
        if fileManager.fileExists(atPath: execPath) {
            sound = NSSound(contentsOfFile: execPath, byReference: true)
        } else if fileManager.fileExists(atPath: currentPath) {
            sound = NSSound(contentsOfFile: currentPath, byReference: true)
        } else {
            // Fallback to system Pop sound
            sound = NSSound(contentsOfFile: "/System/Library/Sounds/Pop.aiff", byReference: true)
        }
    }
    
    func setupWindows() {
        // Create an overlay window for each screen
        for screen in NSScreen.screens {
            let window = ConfettiWindow(screen: screen)
            guard let contentView = window.contentView else { continue }
            
            // Matching the exact colors from clever-lovelace:
            // ["#8b5cf6", "#06b6d4", "#10b981", "#ec4899", "#ffeb3b"]
            let colors: [NSColor] = [
                NSColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0), // Violet
                NSColor(red: 6/255, green: 182/255, blue: 212/255, alpha: 1.0),  // Cyan
                NSColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0), // Emerald
                NSColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0), // Pink
                NSColor(red: 255/255, green: 235/255, blue: 59/255, alpha: 1.0)  // Yellow
            ]
            
            // Emitters positioned at the bottom corners
            let originY: CGFloat = 0.0
            
            // Bottom Left Emitter
            let leftEmitter = CAEmitterLayer()
            leftEmitter.emitterPosition = CGPoint(x: 0, y: originY)
            leftEmitter.emitterShape = .point
            leftEmitter.emitterSize = CGSize(width: 10, height: 10)
            
            // Bottom Right Emitter
            let rightEmitter = CAEmitterLayer()
            rightEmitter.emitterPosition = CGPoint(x: screen.frame.width, y: originY)
            rightEmitter.emitterShape = .point
            rightEmitter.emitterSize = CGSize(width: 10, height: 10)
            
            var leftCells: [CAEmitterCell] = []
            var rightCells: [CAEmitterCell] = []
            
            for color in colors {
                for shape in 0...2 {
                    let size = CGSize(width: CGFloat.random(in: 10...22), height: CGFloat.random(in: 6...14))
                    guard let image = createConfettiImage(color: color, size: size, shape: shape) else { continue }
                    
                    // --- DIAGONAL / LOW-ANGLE CELLS (35° to 70°) ---
                    // Lower velocity to prevent mid-length crossing
                    let cellLeftDiag = CAEmitterCell()
                    cellLeftDiag.contents = image
                    cellLeftDiag.birthRate = 0
                    cellLeftDiag.lifetime = 3.5
                    cellLeftDiag.lifetimeRange = 0.8
                    cellLeftDiag.velocity = 750
                    cellLeftDiag.velocityRange = 130
                    cellLeftDiag.emissionLongitude = 52.5 * CGFloat.pi / 180  // 52.5 degrees center
                    cellLeftDiag.emissionRange = 35 * CGFloat.pi / 180        // 35 degrees spread (35 to 70 degrees)
                    cellLeftDiag.yAcceleration = -750 // gravity pulling down
                    cellLeftDiag.xAcceleration = 0
                    cellLeftDiag.spin = CGFloat.random(in: 3...12)
                    cellLeftDiag.spinRange = 6
                    cellLeftDiag.scale = 1.0
                    cellLeftDiag.scaleRange = 0.3
                    
                    let cellRightDiag = CAEmitterCell()
                    cellRightDiag.contents = image
                    cellRightDiag.birthRate = 0
                    cellRightDiag.lifetime = 3.5
                    cellRightDiag.lifetimeRange = 0.8
                    cellRightDiag.velocity = 750
                    cellRightDiag.velocityRange = 130
                    cellRightDiag.emissionLongitude = 127.5 * CGFloat.pi / 180 // 127.5 degrees center
                    cellRightDiag.emissionRange = 35 * CGFloat.pi / 180        // 35 degrees spread (110 to 145 degrees)
                    cellRightDiag.yAcceleration = -750 // gravity pulling down
                    cellRightDiag.xAcceleration = 0
                    cellRightDiag.spin = CGFloat.random(in: 3...12)
                    cellRightDiag.spinRange = 6
                    cellRightDiag.scale = 1.0
                    cellRightDiag.scaleRange = 0.3
                    
                    leftCells.append(cellLeftDiag)
                    rightCells.append(cellRightDiag)
                    
                    // --- VERTICAL / HIGH-ANGLE CELLS (70° to 90°) ---
                    // High velocity to reach 55-60% height, staying on their own side due to vertical angle
                    let cellLeftVert = CAEmitterCell()
                    cellLeftVert.contents = image
                    cellLeftVert.birthRate = 0
                    cellLeftVert.lifetime = 3.5
                    cellLeftVert.lifetimeRange = 0.8
                    cellLeftVert.velocity = 825
                    cellLeftVert.velocityRange = 110
                    cellLeftVert.emissionLongitude = 80 * CGFloat.pi / 180   // 80 degrees center
                    cellLeftVert.emissionRange = 20 * CGFloat.pi / 180       // 20 degrees spread (70 to 90 degrees)
                    cellLeftVert.yAcceleration = -750 // gravity pulling down
                    cellLeftVert.xAcceleration = 0
                    cellLeftVert.spin = CGFloat.random(in: 3...12)
                    cellLeftVert.spinRange = 6
                    cellLeftVert.scale = 1.0
                    cellLeftVert.scaleRange = 0.3
                    
                    let cellRightVert = CAEmitterCell()
                    cellRightVert.contents = image
                    cellRightVert.birthRate = 0
                    cellRightVert.lifetime = 3.5
                    cellRightVert.lifetimeRange = 0.8
                    cellRightVert.velocity = 825
                    cellRightVert.velocityRange = 110
                    cellRightVert.emissionLongitude = 100 * CGFloat.pi / 180 // 100 degrees center
                    cellRightVert.emissionRange = 20 * CGFloat.pi / 180      // 20 degrees spread (90 to 110 degrees)
                    cellRightVert.yAcceleration = -750 // gravity pulling down
                    cellRightVert.xAcceleration = 0
                    cellRightVert.spin = CGFloat.random(in: 3...12)
                    cellRightVert.spinRange = 6
                    cellRightVert.scale = 1.0
                    cellRightVert.scaleRange = 0.3
                    
                    leftCells.append(cellLeftVert)
                    rightCells.append(cellRightVert)
                }
            }
            
            leftEmitter.emitterCells = leftCells
            rightEmitter.emitterCells = rightCells
            
            contentView.layer?.addSublayer(leftEmitter)
            contentView.layer?.addSublayer(rightEmitter)
            
            windows.append(window)
            leftEmitters.append(leftEmitter)
            rightEmitters.append(rightEmitter)
        }
    }
    
    private func createConfettiImage(color: NSColor, size: CGSize, shape: Int) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        let rect = CGRect(origin: CGPoint(x: 1, y: 1), size: CGSize(width: size.width - 2, height: size.height - 2))
        let path = CGMutablePath()
        
        if shape == 0 {
            // Rectangle
            path.addRect(rect)
        } else if shape == 1 {
            // Circle/Oval
            path.addEllipse(in: rect)
        } else {
            // Pill / Rounded Rectangle
            path.addRoundedRect(in: rect, cornerWidth: rect.height / 2, cornerHeight: rect.height / 2)
        }
        
        // High-definition shiny metallic gradient
        let lighterColor = color.lighter(by: 0.25)
        let darkerColor = color.darker(by: 0.15)
        let colorsArray = [lighterColor.cgColor, color.cgColor, darkerColor.cgColor] as CFArray
        let colorLocations: [CGFloat] = [0.0, 0.5, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colorsArray, locations: colorLocations) else { return nil }
        
        context.saveGState()
        context.addPath(path)
        context.clip()
        
        // Draw diagonal linear gradient
        let startPoint = CGPoint(x: rect.minX, y: rect.minY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
        
        // High-definition outline/border
        context.setStrokeColor(color.darker(by: 0.35).cgColor)
        context.setLineWidth(1.0)
        context.addPath(path)
        context.strokePath()
        
        return context.makeImage()
    }
    
    func pop() {
        // Play sound
        sound?.stop()
        sound?.play()
        
        // Order all windows front and trigger emitter cells
        for i in 0..<windows.count {
            let window = windows[i]
            let leftEmitter = leftEmitters[i]
            let rightEmitter = rightEmitters[i]
            
            window.orderFront(nil)
            
            leftEmitter.birthRate = 1.0
            rightEmitter.birthRate = 1.0
            
            // 30 cells * 12 birthRate * 0.15s = ~54 particles total per side
            for cell in leftEmitter.emitterCells ?? [] {
                cell.birthRate = 12
            }
            for cell in rightEmitter.emitterCells ?? [] {
                cell.birthRate = 12
            }
            
            // Turn off emission quickly to make it a burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                leftEmitter.birthRate = 0.0
                rightEmitter.birthRate = 0.0
                for cell in leftEmitter.emitterCells ?? [] {
                    cell.birthRate = 0
                }
                for cell in rightEmitter.emitterCells ?? [] {
                    cell.birthRate = 0
                }
            }
            
            // Hide window after confetti falls
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                window.orderOut(nil)
            }
        }
    }
}

// Set up HotKey handler
func hotKeyHandler(nextHandler: EventHandlerCallRef?, theEvent: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    ConfettiManager.shared.pop()
    return noErr
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy to accessory so it runs in the background without a Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        print("Confetti Popper started! Press Control + 1 to pop confetti.")
        
        // Register Carbon Event Handler for HotKey
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventType, nil, nil)
        if status != noErr {
            print("Error: Failed to install Carbon event handler (Status: \(status))")
        }
        
        // Register Control + 1
        // Key code for '1' is 18
        // Carbon modifier flag for control is controlKey (4096)
        // Signature "POPR" is 0x504F5052
        let hotKeyID = EventHotKeyID(signature: 0x504F5052, id: 1)
        let registerStatus = RegisterEventHotKey(18, UInt32(controlKey), hotKeyID, GetApplicationEventTarget(), 0, &self.hotKeyRef)
        if registerStatus != noErr {
            print("Error: Failed to register global hotkey Control + 1 (Status: \(registerStatus))")
        }
    }
}

let delegate = AppDelegate()
let app = NSApplication.shared
app.delegate = delegate
app.run()
