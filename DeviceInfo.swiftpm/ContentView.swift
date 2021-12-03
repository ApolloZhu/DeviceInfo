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
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
            Text(key)
                .font(.caption)
                .foregroundColor(.secondary)
        }
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
                value: {
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
                value: {
                var systemInfo = utsname()
                uname(&systemInfo)
                return withUnsafePointer(to: systemInfo.machine) {
                    $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                        String(cString: $0)
                    }
                }
            }())
            Row(key: "hw.model",
                value: {
                return "hw.model".withCString { hwModelCStr in
                    var size = 0
                    sysctlbyname(hwModelCStr, nil, &size, nil, 0)
                    let resultCStr = UnsafeMutablePointer<CChar>.allocate(capacity: size)
                    defer { resultCStr.deallocate() }
                    sysctlbyname(hwModelCStr, resultCStr, &size, nil, 0)
                    return String(cString: resultCStr)
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
