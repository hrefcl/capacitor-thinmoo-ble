import { registerPlugin } from '@capacitor/core';

import type { ThinmooBlePlugin } from './definitions';

const ThinmooBle = registerPlugin<ThinmooBlePlugin>('ThinmooBle', {
  web: () => import('./web').then(m => new m.ThinmooBleWeb()),
});

export * from './definitions';
export { ThinmooBle };
