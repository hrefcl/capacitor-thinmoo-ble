import Foundation
import CoreBluetooth
import Capacitor

@objc public class ThinmooBle: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var plugin: CAPPlugin?
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var openPromise: (Bool) -> Void = { _ in }
    
    var serviceUUID: CBUUID!
    var readWriteServiceUUID: CBUUID!
    var readCharacteristicUUID: CBUUID!
    var writeCharacteristicUUID: CBUUID!
    var miniEkey: String!
    var devSn: String!
    var rssi: NSNumber?
    var value: String?
    var completionHandler: ((Bool) -> Void)?
    
    public func open(_  devSn: String, miniEkey: String, value: String? = nil, connection_services: String? = nil, services: String? = nil, characteristic_read: String? = nil, characteristic_write: String? = nil, plugin: CAPPlugin?, completion: @escaping (Bool) -> Void) {
        print("Open method called")
        
        self.value = value ?? "1"
        self.devSn = devSn
        self.miniEkey = miniEkey
        self.serviceUUID = CBUUID(string: connection_services ?? "00005CB8-0000-1000-8000-00805F9B34FB")
        self.readWriteServiceUUID = CBUUID(string: services ?? "0886b765-9f76-6472-96ef-ab19c539878a")
        self.readCharacteristicUUID = CBUUID(string: characteristic_read ?? "0000878B-0000-1000-8000-00805f9b34fb")
        self.writeCharacteristicUUID = CBUUID(string: characteristic_write ?? "0000878C-0000-1000-8000-00805f9b34fb")
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        self.plugin = plugin
        self.openPromise = completion
        
    }
    
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central manager state: \(central.state.rawValue)")
        
        // Same as in BluetoothManager
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        case .poweredOff:
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unknown:
            print("Bluetooth is unknown")
        case .unsupported:
            print("Bluetooth is unsupported")
        @unknown default:
            print("Unknown state")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "")")
        
        if let name = peripheral.name, name.contains(devSn) {
            self.rssi = RSSI
            self.peripheral = peripheral
            peripheral.delegate = self  // Añade esta línea
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "")")
        
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID, readWriteServiceUUID])
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services for peripheral: \(peripheral.name ?? "")")
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == readWriteServiceUUID {
                peripheral.discoverCharacteristics([readCharacteristicUUID, writeCharacteristicUUID], for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics for service: \(service.uuid.uuidString)")
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == readCharacteristicUUID {
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == writeCharacteristicUUID {
                if let rssi = rssi, let value = value, let valueDouble = Double(value) {
                    let txPower = -60.0 // Potencia de transmisión a 1 metro (este valor debe ser ajustado según el dispositivo)
                    let n = 2.0 // Factor de atenuación de la señal (ajustar según sea necesario)
                    let distance = pow(10, (txPower - rssi.doubleValue) / (10 * n))
                    print("Distancia estimada:", distance)
                    
                    if distance <= valueDouble {
                        if characteristic.properties.contains(.writeWithoutResponse) {
                            guard let data = Data(hex: self.miniEkey) else {
                                print("Invalid miniEkey")
                                return
                            }
                            if peripheral.state == .connected {
                                peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
                                // completionHandler?(true)
                                if let plugin = self.plugin {
                                    plugin.notifyListeners("openSuccess", data: [
                                        "success": true,
                                        "devSn"    : devSn ?? "",
                                        "miniEkey"   : miniEkey ?? ""
                                    ])
                                }
                            } else {
                                print("Peripheral not in correct state")
                                if let plugin = self.plugin {
                                    plugin.notifyListeners("openSuccess", data: [
                                        "success": false,
                                        "devSn"    : devSn ?? "",
                                        "miniEkey"   : miniEkey ?? ""
                                    ])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            if let plugin = self.plugin {
                plugin.notifyListeners("openSuccess", data: [
                    "success": true,
                    "devSn"    : devSn ?? "",
                    "miniEkey"   : miniEkey ?? ""
                ])
            }
            completionHandler?(false)
        } else {
            print("Success!")
            completionHandler?(true)
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            completionHandler?(false)
        } else {
            print("Value updated successfully")
            // completionHandler?(true)
        }
    }

}


extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex
        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        self = data
    }
}
