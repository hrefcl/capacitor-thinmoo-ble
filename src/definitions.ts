export interface ThinmooBlePlugin {
  open(options: {
    devSn: string;
    miniEkey: string;
    value?: string;
    connection_services?: string;
    services?: string;
    characteristic_read?: string;
    characteristic_write?: string;
  }): Promise<{ value: string }>;
}
