import { WebPlugin, Capacitor } from '@capacitor/core';

import type { ThinmooBlePlugin } from './definitions';

export class ThinmooBleWeb extends WebPlugin implements ThinmooBlePlugin {
  async open(options: {
    devSn: string;
    miniEkey: string;
    value: string;
    connection_services: string;
    services: string;
    characteristic_read: string;
    characteristic_write: string;
  }): Promise<{ value: string }> {
    console.log('open', options);
    if (Capacitor.getPlatform() !== 'ios') {
      console.info(
        'CapacitorVoipIos plugin is not implemented on this platform',
      );
      return Promise.resolve({ value: 'This platform is not supported' });
    } else return options;
  }
}
