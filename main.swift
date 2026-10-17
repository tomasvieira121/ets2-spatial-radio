import AppKit
import Foundation
import SwiftUI

enum CabinPreset: String, CaseIterable, Identifiable {
    case premium = "Premium"
    case warm = "Warm"
    case stock = "Stock Radio"
    case spatial = "Spatial"

    var id: String { rawValue }

    var liveKey: String {
        switch self {
        case .premium: return "premium"
        case .warm: return "warm"
        case .stock: return "stock"
        case .spatial: return "spatial"
        }
    }

    var summary: String {
        switch self {
        case .premium:
            return "Balanced 4.1 cabin: crisp front dash/door speakers, rear sleeper speakers & under-seat bass"
        case .warm:
            return "Rich late-night cruiser with fuller rear cabin speakers and deep under-seat warmth"
        case .stock:
            return "Front-focused factory door speakers with subtle rear cabin bounce"
        case .spatial:
            return "Full 360° surround cabin stage with strong rear sleeper speakers & wide binaural imaging"
        }
    }
}

private func format(_ value: Double) -> String {
    String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value)
}

@MainActor
final class CabinRadioModel: ObservableObject {
    @Published var preset: CabinPreset
    @Published var intensity: Double
    @Published var rear: Double
    @Published var position: Double
    @Published var liveStatus = ""

    private let defaults = UserDefaults.standard
    private var liveProcess: Process?

    init() {
        preset = CabinPreset(rawValue: UserDefaults.standard.string(forKey: "preset") ?? "") ?? .premium
        let storedIntensity = UserDefaults.standard.object(forKey: "intensity") as? Double
        intensity = storedIntensity ?? 0.72
        let storedRear = UserDefaults.standard.object(forKey: "rear") as? Double
        rear = storedRear ?? 0.75
        let storedPosition = UserDefaults.standard.object(forKey: "position") as? Double
        position = storedPosition ?? 0.12
        writeLiveSettingsFile()
    }

    var liveInjectorAvailable: Bool {
        Bundle.main.url(forResource: "libETS2CabinDSP", withExtension: "dylib") != nil
    }

    var gameAppearsRunning: Bool {
        NSWorkspace.shared.runningApplications.contains {
            ($0.localizedName ?? "").localizedCaseInsensitiveContains("Euro Truck Simulator")
        }
    }

    private var logDirectoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/ETS2 Cabin Radio", isDirectory: true)
    }

    private var liveSettingsURL: URL {
        logDirectoryURL.appendingPathComponent("live-settings.env")
    }

    func openMusicFolder() {
        let musicFolder = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Euro Truck Simulator 2/music", isDirectory: true)
        NSWorkspace.shared.open(musicFolder)
    }

    func openLiveLog() {
        let log = logDirectoryURL.appendingPathComponent("live-dsp.log")
        if FileManager.default.fileExists(atPath: log.path) {
            NSWorkspace.shared.open(log)
        } else {
            liveStatus = "The live DSP log will appear after the first launch."
        }
    }

    func saveSettings() {
        defaults.set(preset.rawValue, forKey: "preset")
        defaults.set(intensity, forKey: "intensity")
        defaults.set(rear, forKey: "rear")
        defaults.set(position, forKey: "position")
        writeLiveSettingsFile()
    }

    private func writeLiveSettingsFile() {
        try? FileManager.default.createDirectory(at: logDirectoryURL, withIntermediateDirectories: true)
        let contents = """
        preset=\(preset.liveKey)
        intensity=\(format(intensity))
        rear=\(format(rear))
        position=\(format(position))
        """
        try? contents.write(to: liveSettingsURL, atomically: true, encoding: .utf8)
    }

    func launchLiveMode() {
        saveSettings()
        liveStatus = ""

        guard !gameAppearsRunning else {
            liveStatus = "ETS2 is already running. Any slider or preset changes here update the live cabin DSP automatically."
            return
        }
        guard let injector = Bundle.main.url(forResource: "libETS2CabinDSP", withExtension: "dylib") else {
            liveStatus = "The live DSP library is missing from this app bundle."
            return
        }

        let gameRoot = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Steam/steamapps/common/Euro Truck Simulator 2", isDirectory: true)
        let executable = gameRoot
            .appendingPathComponent("Euro Truck Simulator 2.app/Contents/MacOS/eurotrucks2")
        guard FileManager.default.isExecutableFile(atPath: executable.path) else {
            liveStatus = "ETS2 was not found in the normal Steam location."
            return
        }

        let process = Process()
        process.executableURL = executable
        process.currentDirectoryURL = gameRoot
        process.arguments = ["-rdevice", "vk"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        var environment = ProcessInfo.processInfo.environment
        environment["DYLD_INSERT_LIBRARIES"] = injector.path
        environment["ETS2_CABIN_PRESET"] = preset.liveKey
        environment["ETS2_CABIN_INTENSITY"] = format(intensity)
        environment["ETS2_CABIN_REAR"] = format(rear)
        environment["ETS2_CABIN_POSITION"] = format(position)
        environment["SteamAppId"] = "227300"
        environment["SteamGameId"] = "227300"
        process.environment = environment

        process.terminationHandler = { [weak self] finished in
            DispatchQueue.main.async {
                guard finished.terminationStatus != 0 else { return }
                self?.liveStatus = "ETS2 exited with status \(finished.terminationStatus). Check the live DSP log for details."
            }
        }

        do {
            try process.run()
            liveProcess = process
            liveStatus = "ETS2 launched with live 4.1 \(preset.rawValue) DSP & 360° camera head-tracking."
        } catch {
            liveStatus = "Could not launch ETS2: \(error.localizedDescription)"
        }
    }
}

struct ContentView: View {
    @StateObject private var model = CabinRadioModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(spacing: 18) {
                    soundCard
                    liveCard
                }
                .padding(24)
            }
        }
        .frame(minWidth: 660, idealWidth: 700, minHeight: 500, idealHeight: 540)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(LinearGradient(
                        colors: [Color.purple, Color.accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Image(systemName: "car.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 3) {
                Text("ETS2 Cabin Radio")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("3D 4.1 multi-speaker cabin processor with 360° head-tracking")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Label("4.1 Cabin DSP", systemImage: "waveform.circle.fill")
                .font(.callout.weight(.medium))
                .foregroundColor(.purple)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    private var soundCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Cabin", selection: $model.preset) {
                    ForEach(CabinPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.segmented)

                Text(model.preset.summary)
                    .font(.callout)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Cabin effect")
                        Spacer()
                        Text("\(Int(model.intensity * 100))%")
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $model.intensity, in: 0.2...1.0)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Rear / sleeper speakers")
                        Spacer()
                        Text("\(Int(model.rear * 100))%")
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $model.rear, in: 0.0...1.0)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Dashboard position")
                        Spacer()
                        Text(positionLabel)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Left").font(.caption).foregroundColor(.secondary)
                        Slider(value: $model.position, in: -1...1)
                        Text("Right").font(.caption).foregroundColor(.secondary)
                    }
                }

                Text("Adjusting presets or sliders updates the live FMOD cabin DSP in real time—even while ETS2 is running.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .onChange(of: model.preset) { _ in model.saveSettings() }
            .onChange(of: model.intensity) { _ in model.saveSettings() }
            .onChange(of: model.rear) { _ in model.saveSettings() }
            .onChange(of: model.position) { _ in model.saveSettings() }
        } label: {
            Text("Sound profile")
                .font(.headline)
        }
    }

    private var liveCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "bolt.horizontal.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.purple)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Process FMOD bus:/radio in real time")
                            .font(.headline)
                        Text("Session-only injection—your MP3 files, game files, saves, and signatures are never modified. Automatically reacts to cabin camera rotation and open windows.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }

                if !model.liveStatus.isEmpty {
                    Text(model.liveStatus)
                        .font(.callout)
                        .foregroundColor(model.liveStatus.contains("launched") ? .green : .orange)
                        .textSelection(.enabled)
                }

                HStack(spacing: 12) {
                    Button {
                        model.launchLiveMode()
                    } label: {
                        Label("Launch ETS2 with Live DSP", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .controlSize(.large)
                    .disabled(!model.liveInjectorAvailable)

                    Button("Open DSP log") { model.openLiveLog() }
                        .controlSize(.large)

                    Button("Open Music folder") { model.openMusicFolder() }
                        .controlSize(.large)

                    Spacer()
                }
            }
            .padding(8)
        } label: {
            Text("Launch")
                .font(.headline)
        }
    }

    private var positionLabel: String {
        if model.position < -0.15 { return "Left of driver" }
        if model.position > 0.15 { return "Right of driver" }
        return "Centered"
    }
}

@main
struct ETS2CabinRadioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
