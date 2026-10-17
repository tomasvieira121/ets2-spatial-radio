# ETS2 Cabin Radio v1.2.0

### Real-Time 4.1-Cabin Spatial Audio Companion for Euro Truck Simulator 2 (macOS & Windows x64)

ETS2 Cabin Radio attaches a live, non-destructive DSP processor directly to FMOD's `bus:/radio` inside Euro Truck Simulator 2. It simulates physical in-cabin speakers and acoustic reflections that dynamically react as you drive, turn your camera, open windows, or lean outside.

---

### Key Features

- **4.1-Speaker Physical Cabin Simulation**:
  - Front Left (FL) door/dash speaker
  - Front Right (FR) passenger dash/door speaker (with cross-cab Haas delay)
  - Rear Left (RL) sleeper/B-pillar surround speaker
  - Rear Right (RR) sleeper/B-pillar surround speaker
  - Under-seat subwoofer cabin pressure
  - 4-tap cabin glass and sleeper reflection model
- **Dynamic 360° Binaural Spatialization**:
  - Fractional-sample Binaural ITD (Interaural Time Difference)
  - 2-band head-shadowing filter (low-frequency diffraction vs. high-frequency head occlusion)
  - Front/back pinna spectral directivity responding to 360° interior camera rotation
- **Acoustic Glass & Environment Bleed**:
  - Reacts in real time to open windows (`wnd_left`, `wnd_right`) and leaning out (`cabin_out`)
  - Realistic loss of cabin acoustic pressure and increased exterior bleed
- **Live Hot-Reloading & Zero Game Modification**:
  - Adjust sound profiles (**Premium**, **Warm**, **Stock Radio**, **Spatial**), intensity, sleeper balance, and dashboard positioning on the fly while ETS2 is running
  - Leaves your MP3 files, game executables, saves, and signatures completely untouched

---

### Downloads & Assets

| Asset | Platform | Description |
| :--- | :--- | :--- |
| **`ETS2-Cabin-Radio-v1.2.0-macOS.zip`** | macOS (Apple Silicon / Rosetta) | Universal SwiftUI companion app bundle |
| **`ETS2-Cabin-Radio-v1.2.0-Windows-x64.zip`** | Windows (64-bit) | Standalone GUI launcher & live DSP plugin DLL |
| **`ETS2-Cabin-Radio-v1.2.0-Source.zip`** | Source code | Complete buildable C, Swift, and resource source tree |

#### SHA-256 Checksums
```text
d5374055167c58f89b324468a83f5f8435d2215968985d2d37257169320b90eb  ETS2-Cabin-Radio-v1.2.0-macOS.zip
7c15bbaa5296dce034638b5c35f0ad2e5a0a5c4fd17600d4d2c598acee910454  ETS2-Cabin-Radio-v1.2.0-Windows-x64.zip
673dae894720ede2b0cf6156af39b5da48a5d5c5c9ba96c9dc5f759d3b853931  ETS2-Cabin-Radio-v1.2.0-Source.zip
```

---

### Installation & Usage

#### macOS:
1. Extract `ETS2-Cabin-Radio-v1.2.0-macOS.zip` and move `ETS2 Cabin Radio.app` to your `/Applications` folder.
2. Launch `ETS2 Cabin Radio.app` and click **Launch ETS2 with Live DSP**.
3. Adjust presets and audio positioning at any time while driving.

#### Windows (64-bit):
1. Extract `ETS2-Cabin-Radio-v1.2.0-Windows-x64.zip` into any folder.
2. Ensure `ETS2 Cabin Radio.exe` and `ETS2CabinDSP.dll` are kept in the same directory.
3. Run `ETS2 Cabin Radio.exe` and click **Launch / Attach Live DSP**.
   - *Optional*: Click **Install Steam Auto-Plugin** to automatically load the DSP whenever ETS2 is started directly from Steam.

---

### Support the Project
If you enjoy ETS2 Cabin Radio, consider supporting further development and updates on [Ko-fi](https://ko-fi.com/uawannacry)!

