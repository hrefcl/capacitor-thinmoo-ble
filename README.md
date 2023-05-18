# capacitor-thinmoo-ble

Conexion via bluetooth para los dispositivos Thinmoo

## Install

```bash
npm install capacitor-thinmoo-ble
npx cap sync
```

## API

<docgen-index>

* [`open(...)`](#open)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### open(...)

```typescript
open(options: { devSn: string; miniEkey: string; value?: string; connection_services?: string; services?: string; characteristic_read?: string; characteristic_write?: string; }) => Promise<{ value: string; }>
```

| Param         | Type                                                                                                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ devSn: string; miniEkey: string; value?: string; connection_services?: string; services?: string; characteristic_read?: string; characteristic_write?: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------

</docgen-api>
