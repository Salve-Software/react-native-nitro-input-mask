package com.nitroinputmask

import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.BaseReactPackage
import com.facebook.react.uimanager.ViewManager
import com.margelo.nitro.nitroinputmask.NitroInputMaskOnLoad

class NitroInputMaskPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    NitroInputMaskContext.reactContext = reactContext
    return null
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
    emptyMap()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return emptyList()
  }

  companion object {
    init {
      NitroInputMaskOnLoad.initializeNative()
    }
  }
}
