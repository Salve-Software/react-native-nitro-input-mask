## [1.1.0](https://github.com/Salve-Software/react-native-nitro-input-mask/compare/v1.0.0...v1.1.0) (2026-05-11)

### ⚠ BREAKING CHANGES

* **mask:** `applyMask` now returns `{ masked, raw }` instead of a plain string. Migrate with `const { masked, raw } = applyMask(props)`
* **mask:** `<NitroInputMask onChangeText />` now receives `(result: MaskResult) => void` instead of `(text: string) => void`

### ✨ Features

* **example:** demonstrate onChangeValue on phone input ([a4d2065](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/a4d206548e9cc6fbf2f390690cd0346147aa1d9d))
* **example:** replace ScrollView with tab navigation ([a53ce27](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/a53ce27a75c76908b6ec7502bdaaeef0b65743eb))
* **example:** show masked and raw values below each input ([cf47835](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/cf47835d532a637568f315c2f918d3e93a6d2a05))
* **mask:** add MaskResult type and update spec ([8274da6](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/8274da61a4313fd69b46d1ced5af1fd37b762847))
* **mask:** return MaskResult from applyMask and add onChangeValue ([9a3f489](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/9a3f489ffc2b1914a903a48e90f1534568dc50aa))
* **mask:** wire onChangeValue in component and service ([8c56e30](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/8c56e305ae553fb18ff80e8c26558d0d5a388ccc))

### 🐛 Bug Fixes

* **android:** add missing MaskResult import ([d53a328](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/d53a3286c3c23178a17e49c654af76892df78229))
* **android:** revert JNI descriptors to correct package path ([dcaf26e](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/dcaf26e74881e08618634bbb2eaed5b93d357a52))
* **example:** update import to scoped package name ([dd14004](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/dd140041fc260de95cb4ced9379a244be124bcf3))
* **mask:** mark user input before onChangeText check ([01431b8](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/01431b80d48f89ce66027a9fc90f434d9827c137))
* **mask:** replace onChangeValue with overridden onChangeText ([172df90](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/172df9068cce7a63dc336fad997760bb62e82632))

### 💨 Performance Improvements

* **mask:** memoize options and fix double setValue on Android ([c9a4025](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/c9a4025cb7969b6d996715ede758e9b1615773e5))

### 🔄 Code Refactors

* **mask:** remove top-level props cast in NitroInputMask ([6672676](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/6672676830c6f7feaa18af80b5bbb42ec6670127))

### 📚 Documentation

* fix npm badge package name ([ec42bfd](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/ec42bfdd99ecbaec6db113b8eae4d781c81f1cbc))
* fix README examples to use onChangeText with MaskResult ([4d343f3](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/4d343f3f20eb0e56e00c2d8395d38a61f9776def))
* up changelog ([cb9179e](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/cb9179e920514eb71bc98a2834e9e5c2dd42b696))
* up demo gif ([5cf4fc6](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/5cf4fc675c33f21d0d92b72b8f03d634bf5b5998))
* update README and CHANGELOG for MaskResult ([4c7455f](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/4c7455fb2ca037c00520b6ec1aba1fde003171b7))

### 🛠️ Other changes

* **codegen:** regenerate nitro bindings ([91af4f9](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/91af4f96ff48cd61645666cd63dcb1fcb4b08a51))
* **ios:** update pods for 1.0.0 ([693c731](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/693c73111e6229f6f182046681969ff94fa14a7c))
* **release:** map breaking changes to minor bump ([75184f1](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/75184f191695e7521904528ff198393d3c0b1b3a))
* update package name to scoped [@salve-software](https://github.com/salve-software) ([c20a9d1](https://github.com/Salve-Software/react-native-nitro-input-mask/commit/c20a9d1548aad70026a4a02df7578cc96c27fadd))

## 1.0.0 (2026-05-11)

### ✨Initial release

High-performance native input masks for React Native, built on [Nitro Modules](https://github.com/mrousavy/nitro).

- **`<NitroInputMask />`** — drop-in replacement for `<TextInput />` with synchronous native masking (zero JS flicker)
- **`NitroInputMaskService`** — apply any mask to a string without rendering a component
- **Built-in mask types** — `custom`, `money`, `datetime`, `credit-card`
- **Range tokens** — inline `[from-to]` syntax (e.g. `[1-12]` for month)
- iOS (Swift) and Android (Kotlin) support
