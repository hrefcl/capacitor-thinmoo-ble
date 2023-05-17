import Foundation
import Capacitor

@objc(ThinmooBlePlugin)
public class ThinmooBlePlugin: CAPPlugin {
    private let implementation = ThinmooBle()

    @objc func open(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        let devSn = call.getString("devSn") ?? ""
        let miniEkey = call.getString("miniEkey") ?? ""
        let connection_services = call.getString("connection_services") ?? ""
        let services = call.getString("services") ?? ""
        let characteristic_read = call.getString("characteristic_read") ?? ""
        let characteristic_write = call.getString("characteristic_write") ?? ""

        call.resolve([
            "value": implementation.open(value, devSn: devSn, miniEkey: miniEkey, connection_services: connection_services, services: services, characteristic_read: characteristic_read, characteristic_write: characteristic_write)
        ])
    }
}
