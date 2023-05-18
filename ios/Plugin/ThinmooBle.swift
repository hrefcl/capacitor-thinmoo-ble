import Foundation
import CoreBluetooth

@objc public class ThinmooBle: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!

    var serviceUUID: CBUUID!
    var readWriteServiceUUID: CBUUID!
    var readCharacteristicUUID: CBUUID!
    var writeCharacteristicUUID: CBUUID!
    var miniEkey: String!
    var devSn: String!
    var rssi: NSNumber?
    var value: String?

    public func open(_  devSn: String, miniEkey: String, value: String? = nil, connection_services: String? = nil, services: String? = nil, characteristic_read: String? = nil, characteristic_write: String? = nil) -> String {
        self.value = value ?? "1"
        self.devSn = devSn
        self.miniEkey = miniEkey
        self.serviceUUID = CBUUID(string: connection_services ?? "00005CB8-0000-1000-8000-00805F9B34FB")
        self.readWriteServiceUUID = CBUUID(string: services ?? "0886b765-9f76-6472-96ef-ab19c539878a")
        self.readCharacteristicUUID = CBUUID(string: characteristic_read ?? "0000878B-0000-1000-8000-00805f9b34fb")
        self.writeCharacteristicUUID = CBUUID(string: characteristic_write ?? "0000878C-0000-1000-8000-00805f9b34fb")

        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)

        return self.value ?? "1"
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
        if let name = peripheral.name, name.contains(devSn) {
            self.rssi = RSSI
            self.peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }


    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID, readWriteServiceUUID])
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            if service.uuid == readWriteServiceUUID {
                peripheral.discoverCharacteristics([readCharacteristicUUID, writeCharacteristicUUID], for: service)
            }
        }
    }

   public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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
                        if characteristic.properties.contains(.write) {
                            guard let data = Data(hex: self.miniEkey) else {
                                print("Invalid miniEkey")
                                return
                            }
                            peripheral.writeValue(data, for: characteristic, type: .withResponse)
                        } else if characteristic.properties.contains(.writeWithoutResponse) {
                            guard let data = Data(hex: self.miniEkey) else {
                                print("Invalid miniEkey")
                                return
                            }
                            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
                        }
                    }
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        print("Success!")
        centralManager.cancelPeripheralConnection(peripheral)
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
