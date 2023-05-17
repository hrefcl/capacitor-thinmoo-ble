import { WebPlugin } from '@capacitor/core';

import type { ThinmooBlePlugin } from './definitions';

export class ThinmooBleWeb extends WebPlugin implements ThinmooBlePlugin {
  async open(options: {
    value: string;
    devSn: string[];
    miniEkey: string[];
    connection_services: string[];
    services: string[];
    characteristic_read: string[];
    characteristic_write: string[];
  }): Promise<{ value: string }> {
    console.log('open', options);
    return options;
  }
}
