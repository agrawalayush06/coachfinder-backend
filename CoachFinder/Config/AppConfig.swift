import Foundation

enum AppConfig {
    // Change useSimulator to false when testing on a physical iPhone connected to local Wi-Fi
    static let useSimulator = true

    // LAN IP address of your Mac for physical iPhone testing
    static let macLanIP = "172.25.120.142"

    static var baseURL: URL {
        let host = useSimulator ? "localhost" : macLanIP
        guard let url = URL(string: "http://\(host):8080/v1") else {
            fatalError("Invalid base URL configuration")
        }
        return url
    }
}
