//
//  ContentView.swift
//  Shared
//
//  Created by Apollo Zhu on 12/2/21.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SystemConfiguration)
import SystemConfiguration
#endif

struct Row: View {
    let key: LocalizedStringKey
    let value: Text

    var body: some View {
        VStack(alignment: .leading) {
            value
            Text(key)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

extension Row {
    init(key: LocalizedStringKey, value: String) {
        self.init(key: key, value: Text(value))
    }
}

struct ContentView: View {
    var deviceNameSection: some View {
        Section {
            #if canImport(UIKit)
            Row(key: "UIDevice.current.name",
                value: UIDevice.current.name)
            #endif
            #if os(macOS)
            Row(key: "[DEPRECATED] Host.current().name!",
                value: Host.current().localizedName!)
            #endif
            #if canImport(SystemConfiguration) && os(macOS)
            Row(key: "SCDynamicStoreCopyComputerName(nil, nil)!",
                value: SCDynamicStoreCopyComputerName(nil, nil)! as String)
            #endif
        } header: {
            Text("Device Name")
        }
    }

    var deviceModelSection: some View {
        Section {
            #if canImport(UIKit)
            Row(key: "UIDevice.current.model",
                value: UIDevice.current.model)
            Row(key: "UIDevice.current.userInterfaceIdiom",
                value: { () -> String in
                switch UIDevice.current.userInterfaceIdiom {
                case .unspecified:
                    return "unspecified"
                case .phone:
                    return "phone"
                case .pad:
                    return "pad"
                case .tv:
                    return "tv"
                case .carPlay:
                    return "carPlay"
                case .mac:
                    return "mac"
                @unknown default:
                    return "unknown"
                }
            }())
            #endif
            Row(key: "utsname.machine",
                value: { () -> String in
                var systemInfo = utsname()
                uname(&systemInfo)
                return withUnsafePointer(to: systemInfo.machine) {
                    $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                        String(cString: $0)
                    }
                }
            }())
            Row(key: "hw.model",
                value: { () -> Text in
                return "hw.model".withCString { hwModelCStr in
                    var size = 0
                    if sysctlbyname(hwModelCStr, nil, &size, nil, 0) != 0 {
                        return Text("Failed to get size of hw.model (\(String(cString: strerror(errno))))")
                            .foregroundColor(.red)
                    }
                    precondition(size > 0)
                    var resultCStr = [CChar](repeating: 0, count: size)
                    if sysctlbyname(hwModelCStr, &resultCStr, &size, nil, 0) != 0 {
                        return Text("Failed to get hw.model (\(String(cString: strerror(errno))))")
                            .foregroundColor(.red)
                    }
                    return Text(String(cString: resultCStr))
                }
            }())
        } header: {
            Text("Device Model")
        }
    }

    var processInfoSection: some View {
        Section {
            Row(key: "ProcessInfo.processInfo.hostName",
                value: ProcessInfo.processInfo.hostName)
            Row(key: "ProcessInfo.processInfo.isiOSAppOnMac",
                value: "\(ProcessInfo.processInfo.isiOSAppOnMac)")
            Row(key: "ProcessInfo.processInfo.isMacCatalystApp",
                value: "\(ProcessInfo.processInfo.isMacCatalystApp)")
            Row(key: "sysctl.proc_translated",
                value: {
                // https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment
                return "sysctl.proc_translated".withCString { procTranslatedCStr -> Text in
                    var resultCInt = -1 as CInt
                    var size = MemoryLayout.size(ofValue: resultCInt)
                    // Call the sysctl and if successful return the result
                    // Returns 1 if running in Rosetta
                    if sysctlbyname(procTranslatedCStr, &resultCInt, &size, nil, 0) == 0 {
                        switch resultCInt {
                        case 1:
                            return Text("translated")
                        case 0:
                            return Text("native")
                        case let result:
                            return Text("Unexpected sysctl.proc_translated (\(result))")
                                .foregroundColor(.red)
                        }
                    } else if errno == ENOENT {
                        // If "sysctl.proc_translated" is not present then must be native
                        return Text("native")
                    } else {
                        return Text("Failed to get sysctl.proc_translated (\(String(cString: strerror(errno))))")
                            .foregroundColor(.red)
                    }
                }
            }())
        } header: {
            Text("Process Info")
        }

    }

    var list: some View {
        List {
            deviceNameSection
            deviceModelSection
            processInfoSection
        }
        .navigationTitle("Device Info")
    }

    var body: some View {
        #if os(macOS)
        list
        #else
        NavigationView {
            list
        }
        .navigationViewStyle(.stack)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
