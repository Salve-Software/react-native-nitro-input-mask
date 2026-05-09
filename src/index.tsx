import type { TextInputProps, LayoutChangeEvent } from 'react-native'
import type { NitroInputMask as NitroInputMaskModule } from './specs/nitro-input-mask.nitro'
export type { NitroInputMask as NitroInputMaskModule } from './specs/nitro-input-mask.nitro'
import React, { useRef, useEffect, useId } from 'react'
import { TextInput } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'

const nitroModule = NitroModules.createHybridObject<NitroInputMaskModule>('NitroInputMask')

// Extracts raw (unformatted) characters from an already-masked string.
// Used to compute the rawValue in onChangeText, since the native side fires
// editingChanged with the masked text and we need to expose both forms.
function extractRaw(masked: string, mask: string): string {
  let raw = ''
  for (let i = 0; i < masked.length && i < mask.length; i++) {
    const m = mask[i]!
    if (m === '9' || m === 'A' || m === '*') raw += masked[i]
  }
  return raw
}

export type NitroInputMaskProps = Omit<TextInputProps, 'onChangeText'> & {
  mask: string
  // value accepts the raw (unformatted) string — the native side applies the mask before display.
  value?: string
  onChangeText?: (maskedValue: string, rawValue: string) => void
}

export function NitroInputMask({ mask, value, onChangeText, onLayout, ...rest }: NitroInputMaskProps) {
  const reactId = useId()
  const id = `nitro-input-mask-${reactId}`
  const attached = useRef(false)

  // Always-current refs so onLayout handler reads latest values without deps
  const maskRef = useRef(mask)
  const valueRef = useRef(value)
  maskRef.current = mask
  valueRef.current = value

  useEffect(() => {
    return () => {
      nitroModule.detach(id)
      attached.current = false
    }
  }, [])

  useEffect(() => {
    if (attached.current) nitroModule.updateMask(id, mask)
  }, [mask])

  useEffect(() => {
    if (attached.current && value != null) nitroModule.setValue(id, String(value))
  }, [value])

  function handleLayout(event: LayoutChangeEvent) {
    if (!attached.current) {
      attached.current = true
      nitroModule.attach(id, maskRef.current)
      const v = valueRef.current
      if (v != null) nitroModule.setValue(id, String(v))
    }
    onLayout?.(event)
  }

  return (
    <TextInput
      nativeID={id}
      onLayout={handleLayout}
      onChangeText={(text) => {
        const raw = extractRaw(text, mask)
        onChangeText?.(text, raw)
      }}
      {...rest}
    />
  )
}
