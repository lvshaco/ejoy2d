package com.example.testej2d;

import java.lang.ref.WeakReference;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;

public class MyHandler extends Handler {
    public final static int HANDLER_SHOW_DIALOG = 1;
    public final static int HANDLER_SHOW_EDITBOX_DIALOG = 2;
    
    private WeakReference<MyActivity> mActivity;
    
    // ===========================================================
    // Constructors
    // ===========================================================
    public MyHandler(MyActivity activity) {
        this.mActivity = new WeakReference<MyActivity>(activity);
    }

    // ===========================================================
    // Getter & Setter
    // ===========================================================

    // ===========================================================
    // Methods for/from SuperClass/Interfaces
    // ===========================================================
    
    // ===========================================================
    // Methods
    // ===========================================================

    public void handleMessage(Message msg) {
        switch (msg.what) {
        case MyHandler.HANDLER_SHOW_DIALOG:
            showDialog(msg);
            break;
        case MyHandler.HANDLER_SHOW_EDITBOX_DIALOG:
            showEditBoxDialog(msg);
            break;
        }
    }
    
    private void showDialog(Message msg) {
        MyActivity theActivity = this.mActivity.get();
        DialogMessage dialogMessage = (DialogMessage)msg.obj;
        new AlertDialog.Builder(theActivity)
        .setTitle(dialogMessage.titile)
        .setMessage(dialogMessage.message)
        .setPositiveButton("Ok", 
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        // TODO Auto-generated method stub
                        
                    }
                }).create().show();
    }
    
    private void showEditBoxDialog(Message msg) {
        EditBoxMessage editBoxMessage = (EditBoxMessage)msg.obj;
        new Cocos2dxEditBoxDialog(this.mActivity.get(),
                editBoxMessage.title,
                editBoxMessage.content,
                editBoxMessage.inputMode,
                editBoxMessage.inputFlag,
                editBoxMessage.returnType,
                editBoxMessage.maxLength,
                editBoxMessage.functionid).show();
    }
    
    // ===========================================================
    // Inner and Anonymous Classes
    // ===========================================================
    
    public static class DialogMessage {
        public String titile;
        public String message;
        
        public DialogMessage(String title, String message) {
            this.titile = title;
            this.message = message;
        }
    }
    
    public static class EditBoxMessage {
        public String title;
        public String content;
        public int inputMode;
        public int inputFlag;
        public int returnType;
        public int maxLength;
        public int functionid;
        
        public EditBoxMessage(String title, String content, 
                int inputMode, int inputFlag, int returnType, int maxLength,
                int functionid){
            this.content = content;
            this.title = title;
            this.inputMode = inputMode;
            this.inputFlag = inputFlag;
            this.returnType = returnType;
            this.maxLength = maxLength;
            this.functionid = functionid;
        }
    }
}
