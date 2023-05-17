package href.capacitor.thinmoo.ble;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "ThinmooBle")
public class ThinmooBlePlugin extends Plugin {

    private ThinmooBle implementation = new ThinmooBle();

    @PluginMethod
    public void open(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.open(value));
        call.resolve(ret);
    }
}
