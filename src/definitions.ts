import type { PluginListenerHandle } from '@capacitor/core';
export interface OpenSuccessData {
  success: boolean;
  devSn: string;
  miniEkey: string;
}
export interface ThinmooBlePlugin {
  open(options: {
    devSn: string;
    miniEkey: string;
    value?: string;
    connection_services?: string;
    services?: string;
    characteristic_read?: string;
    characteristic_write?: string;
  }): Promise<{ success: boolean }>;

  addListener(
    eventName: 'openSuccess',
    listenerFunc: (data: OpenSuccessData) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
}
