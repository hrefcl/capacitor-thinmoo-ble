import { WebPlugin } from '@capacitor/core';

import type { ThinmooBlePlugin } from './definitions';

export class ThinmooBleWeb extends WebPlugin implements ThinmooBlePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
