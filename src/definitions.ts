export interface ThinmooBlePlugin {
  open(options: { 
    value: string, 
    devSn: string,
    miniEkey: string,
    connection_services: string,
    services: string,
    characteristic_read: string,
    characteristic_write: string
  }): Promise<{ value: string }>;
}