package com.example.testej2d;

import android.view.inputmethod.InputMethodManager;

public class EditBox {
    private void openKeyboard() {
        final InputMethodManager imm = (InputMethodManager) this.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(this.mInputEditText, 0);
    }
}

