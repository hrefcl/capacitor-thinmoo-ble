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
  }): Promise<{ success: boolean }> {
    console.log('open', options);
    if (Capacitor.getPlatform() !== 'ios') {
      console.info(
        'CapacitorVoipIos plugin is not implemented on this platform',
      );
      return Promise.resolve({ success: false });
    } else {
      // Aquí deberías hacer algún tipo de operación que devuelva un booleano
      // en función del éxito o fracaso de la operación.
      // Como esto es solo un ejemplo, simplemente devolveré `true`.
      return Promise.resolve({ success: true });
    }
  }
}
