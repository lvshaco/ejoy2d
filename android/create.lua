local args={...}
local name = args[1]

local manifest=string.format([[
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.lvshaco.%s"
    android:versionCode="1"
    android:versionName="1.0" >
    <uses-sdk
        android:minSdkVersion="9"
        android:targetSdkVersion="9" />
    <uses-feature android:glEsVersion="0x00020000"/>
   <uses-permission android:name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.ACCESS_CHECKIN_PROPERTIES"></uses-permission>  
    <uses-permission android:name="android.permission.WAKE_LOCK"></uses-permission>  
    <uses-permission android:name="android.permission.INTERNET"></uses-permission>  
    <uses-permission android:name="android.permission.MODIFY_PHONE_STATE"></uses-permission> 
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" ></uses-permission> 
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" ></uses-permission>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" ></uses-permission>  
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" ></uses-permission>
    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:theme="@android:style/Theme.NoTitleBar.Fullscreen" >
        <activity
            android:name="com.example.testej2d.MyActivity"
            android:screenOrientation="landscape"
            android:label="@string/app_name" >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
]], name)
local f = io.open("AndroidManifest.xml","w")
f:write(manifest)
f:close()
