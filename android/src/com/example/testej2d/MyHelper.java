package com.example.testej2d;

import android.os.Message;
import android.content.res.AssetManager;
import android.content.Context;

public class MyHelper {
    static private MyActivity mActivity;
    static private MyHandler mHandler;
    static public void init(MyActivity act) {
        mActivity = act;
        mHandler = new MyHandler(act);
        MyHelper.nativeSetContext((Context)act, act.getAssets());
    }
    static public void showDialog(final String pTitle, final String pMessage) {
        Message msg = new Message();
        msg.what = MyHandler.HANDLER_SHOW_DIALOG;
        msg.obj = new MyHandler.DialogMessage(pTitle, pMessage);
        mHandler.sendMessage(msg);
    }
    static public void showEditTextDialog(
            final String pTitle, final String pContent, 
            final int pInputMode, final int pInputFlag, 
            final int pReturnType, final int pMaxLength,
            final int functionid) { 
        Message msg = new Message();
        msg.what = MyHandler.HANDLER_SHOW_EDITBOX_DIALOG;
        msg.obj = new MyHandler.EditBoxMessage(pTitle, pContent, 
                pInputMode, pInputFlag, pReturnType, pMaxLength, functionid);
        mHandler.sendMessage(msg);
    }
    private static native void nativeSetContext(final Context pContext, final AssetManager pAssetManager);
}
