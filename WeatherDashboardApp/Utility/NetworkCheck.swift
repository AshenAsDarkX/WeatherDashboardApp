//
//  NetworkCheck.swift
//  WeatherDashboardTemplate
//
//  Created by Ashen on 2026-01-06.
//

import Foundation
import Network

// Listens for changes in internet connectivity.
// Marked as @MainActor so we can safely update the UI from here.
//https://medium.com/@husnainali593/how-to-check-network-connection-in-swiftui-using-nwpathmonitor-8f6cd4777514
//https://developer.apple.com/documentation/network/nwpathmonitor/init()
@MainActor
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // We publish this property so the ViewModel can react instantly if the net drops.
    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
