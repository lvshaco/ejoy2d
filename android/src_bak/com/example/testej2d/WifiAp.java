package com.example.testej2d; 
  
import android.util.Log;
import android.content.BroadcastReceiver;  
import android.content.Context;  
import android.content.Intent;  
import android.content.IntentFilter;  
import android.net.wifi.ScanResult;  
import android.net.wifi.WifiManager;  
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;  
import java.util.Timer;
import java.util.List;

// wifi热点代理
class WifiApProxy {
    private static WifiManager mWifimgr;
    private static BroadcastReceiver mRecr;
    private static Thread thread;
    public static void init() {
        mWifimgr = (WifiManager) ActivityProxy.mA.getSystemService(Context.WIFI_SERVICE);
    }
    public static void open(String ssid, 
            String password, 
            int type, 
            int timeout, 
            final int functionid) {
        if (isopened())
            return;
        if (mWifimgr.isWifiEnabled()) {
            mWifimgr.setWifiEnabled(false);
        } 
        forceopen(ssid, password, type);
        TimerChecker timer = new TimerChecker() {
            @Override
            protected void ontick() {
                if (isopened()) {
                    this.exit(0);
                }
            }
            @Override
            protected void ondone(final int code) {
                    ActivityProxy.mA.runOnGLThread(new Runnable() {
                    @Override
                    public void run() { 
                        JavaBridge.nativeCalllua(functionid, String.valueOf(code)); 
                    }
                });
            }
        };
        timer.start(1000, timeout);
    }

    public static void close() {
        if (isopened()) {
            forceclose();
        }
    }

    public static boolean isopened() {  
        try {  
            Method method = mWifimgr.getClass().getMethod("isWifiApEnabled");  
            method.setAccessible(true);  
            return (Boolean) method.invoke(mWifimgr);  
        } catch (NoSuchMethodException e) {  
            e.printStackTrace();  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
        return false;  
    } 

    private static void forceopen(String ssid, String passwd, int type) {  
        try {  
            WifiConfiguration cfg = create_wifiinfo(ssid, passwd, type);
            Method method = mWifimgr.getClass().getMethod("setWifiApEnabled",  
                    WifiConfiguration.class, boolean.class);
            method.setAccessible(true);
            method.invoke(mWifimgr, cfg, true);  
        } catch (IllegalArgumentException e) {  
            e.printStackTrace();  
        } catch (IllegalAccessException e) {  
            e.printStackTrace();  
        } catch (InvocationTargetException e) {  
            e.printStackTrace();  
        } catch (SecurityException e) {  
            e.printStackTrace();  
        } catch (NoSuchMethodException e) {  
            e.printStackTrace();  
        }  
    }  
  
    private static void forceclose() {  
        try {  
            Method method = mWifimgr.getClass().getMethod("getWifiApConfiguration");  
            method.setAccessible(true);  
            WifiConfiguration cfg = (WifiConfiguration)method.invoke(mWifimgr);

            Method method2 = mWifimgr.getClass().getMethod("setWifiApEnabled", WifiConfiguration.class, boolean.class);  
            method2.setAccessible(true);
            method2.invoke(mWifimgr, cfg, false);  
        } catch (NoSuchMethodException e) {  
            e.printStackTrace();  
        } catch (IllegalArgumentException e) {  
            e.printStackTrace();  
        } catch (IllegalAccessException e) {  
            e.printStackTrace();  
        } catch (InvocationTargetException e) {  
            e.printStackTrace();  
        }  
    }

    public static void scan(final int functionid) {
        if (!mWifimgr.isWifiEnabled()) {
            mWifimgr.setWifiEnabled(true);
        } 
        mRecr = new BroadcastReceiver() {
            @Override  
            public void onReceive(Context context, Intent intent) {  
                final StringBuilder sb = new StringBuilder();
                List<ScanResult> wifiList = mWifimgr.getScanResults();  
                for (int i = 0; i < wifiList.size(); i++) {  
                    sb.append((wifiList.get(i)).SSID.toString()).append("\n");
                }  
                ActivityProxy.mA.unregisterReceiver(mRecr);
                ActivityProxy.mA.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        JavaBridge.nativeCalllua(functionid, sb.toString());
                    }
                });
            }
        };
        ActivityProxy.mA.registerReceiver(mRecr, new IntentFilter(  
                WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));  
        mWifimgr.startScan();
    }
   
    public static void connect(final String ssid, 
            final String passwd, 
            final int type, 
            final int timeout,
            final int functionid) {
        if (!mWifimgr.isWifiEnabled()) {
            mWifimgr.setWifiEnabled(true);
        } 
        Log.e("ejoy2d", "connect:"+ssid+":"+passwd+":"+type);
        thread = new Thread(new Runnable() {
            @Override
            public void run() {
                String ssidt = "\"" + ssid + "\"";
                String passwdt = "\"" + passwd + "\"";
                WifiConfiguration cfg = create_wifiinfo(ssidt, passwdt, type);
                int id = mWifimgr.addNetwork(cfg);
                if (id < 0) {
                ActivityProxy.mA.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        JavaBridge.nativeCalllua(functionid, "2");
                    }
                });
                return;
                }
                final boolean ok = mWifimgr.enableNetwork(id,true);
                //mWifimgr.saveConfiguration();  
                //mWifimgr.reconnect();
                int ip = 0;
                int cur_times = 0;
                if (ok) {
                    while (true) {
                        WifiInfo info = mWifimgr.getConnectionInfo();
                        if (info != null && info.getSSID() != null) {
                            if (info.getSSID().equals(ssidt)) {
                                break;
                            }
                        }
                        cur_times++;
                        if (cur_times >= timeout)
                            break;
                        try {
                            thread.sleep(1000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                            break;
                        }
                        Log.e("ejoy2d", "getConnectionInfo sleep onetime");
                    }
                    cur_times = 0;
                    while (true) {
                        Log.e("ejoy2d", "connect sleep onetime");
                        ip = mWifimgr.getDhcpInfo().gateway;
                        if (ip != 0)
                            break;
                        cur_times ++;
                        if (cur_times >= timeout)
                            break;
                        try {
                            thread.sleep(1000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                            break;
                        }
                    }
                }
                final int gateway = ip;
                ActivityProxy.mA.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        JavaBridge.nativeCalllua(functionid, ok?"0"+gateway:"1");
                    }
                });
            }
        });
        thread.start();
    }
   
    // 断开指定ID的网络    
    //public void disconnectWifi(int netId) {   
        //mWifimgr.disableNetwork(netId);   
        //mWifimgr.disconnect();   
    //}   
   
    private static WifiConfiguration create_wifiinfo(String ssid, String passwd, int type) {   
        WifiConfiguration cfg = isexist(ssid);             
        if(cfg != null) {    
            mWifimgr.removeNetwork(cfg.networkId);
        } 
        cfg = new WifiConfiguration();     
        cfg.SSID = ssid; 
            
        if(type == 1) { //WIFICIPHER_NOPASS  
            //cfg.wepKeys[0] = passwd; "" for open; "\"\"" for connect
            //cfg.wepTxKeyIndex = 0;
            cfg.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);   
        } else if(type == 2) { //WIFICIPHER_WEP  
            cfg.hiddenSSID = true;  
            cfg.wepKeys[0]= passwd; 
            cfg.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED);   
            cfg.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);   
            cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);   
            cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);   
            cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);   
            cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);   
            cfg.wepTxKeyIndex = 0;   
        } else if(type == 3) { //WIFICIPHER_WPA  
          cfg.preSharedKey = passwd;
          cfg.hiddenSSID = true;
          cfg.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
          //cfg.allowedProtocols.set(WifiConfiguration.Protocol.RSN); 
          //cfg.allowedProtocols.set(WifiConfiguration.Protocol.WPA); 
          cfg.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK); 
          cfg.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
          cfg.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP); 
          cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP); 
          cfg.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP); 
          cfg.status = WifiConfiguration.Status.ENABLED;
        }  
        return cfg;   
    }   
      
    private static WifiConfiguration isexist(String ssid) {
        List<WifiConfiguration> l = mWifimgr.getConfiguredNetworks();
        if (l==null) return null;
        for (WifiConfiguration cfg: l) {
            if (cfg.SSID.equals("\""+ssid+"\"")) {
                return cfg;
            }
        }
        return null;
    }
} 

// 定时检查器
abstract class TimerChecker {  
    private int cur_times = 0;  
    private int times = 1;  
    private int tick = 1000; 
    private boolean isdone = false;  
    private Thread thread = null;  
     
    public TimerChecker() {  
        thread = new Thread(new Runnable() {  
            @Override  
            public void run() {  
                while (!isdone) {  
                    cur_times ++;  
                    if (cur_times < times) {  
                        ontick();
                        sleep(tick);
                    } else {  
                        exit(1);
                    }  
                }  
            }  
        });  
    }  
    protected abstract void ontick();
    protected abstract void ondone(int code);
    public void start(int tick, int times) {  
        this.tick = tick;  
        this.times = times;  
        this.thread.start();  
    }  
    protected void exit(int code) {
        this.isdone = true;
        ondone(code);
    }
    protected void sleep(int ms) {
        try {  
            thread.sleep(ms);  
        } catch (InterruptedException e) {  
            e.printStackTrace();  
            exit(2);
        } 
    }
} 
