import Foundation
import Capacitor

@objc(ThinmooBlePlugin)
public class ThinmooBlePlugin: CAPPlugin {
    private let implementation = ThinmooBle()

    @objc func open(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? "1"
        let devSn = call.getString("devSn") ?? ""
        let miniEkey = call.getString("miniEkey") ?? ""
        let connection_services = call.getString("connection_services") ?? "00005CB8-0000-1000-8000-00805F9B34FB"
        let services = call.getString("services") ?? "0886b765-9f76-6472-96ef-ab19c539878a"
        let characteristic_read = call.getString("characteristic_read") ?? "0000878B-0000-1000-8000-00805f9b34fb"
        let characteristic_write = call.getString("characteristic_write") ?? "0000878C-0000-1000-8000-00805f9b34fb"

        call.resolve([
            "value": implementation.open(devSn, miniEkey: miniEkey,value: value, connection_services: connection_services, services: services, characteristic_read: characteristic_read, characteristic_write: characteristic_write)
        ])
    }
}
