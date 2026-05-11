import type { NitroInputMaskProps } from './types';
import React, { useCallback, useEffect, useId } from 'react';
import { TextInput } from 'react-native';
import { nitroModule, getNitroServiceModule } from '../../nitro-module';

export const NitroInputMask = (props: NitroInputMaskProps) => {
  const { maskType, maskOptions, onChangeText, value, ...rest } = props;

  const resolvedMaskType = maskType ?? 'custom';
  const resolvedOptions = (maskOptions ?? {}) as Record<string, unknown>;
  const reactId = useId();
  const id = `nitro-input-mask-${reactId}`;

  const maskOptionsJson = JSON.stringify(resolvedOptions);

  useEffect(() => {
    nitroModule.attach(id, resolvedMaskType, resolvedOptions);
    if (value != null) nitroModule.setValue(id, String(value));
    return () => nitroModule.detach(id);
  }, []);

  useEffect(() => {
    nitroModule.updateMask(id, resolvedMaskType, resolvedOptions);
  }, [resolvedMaskType, maskOptionsJson]);

  useEffect(() => {
    if (value == null) return;
    nitroModule.setValue(id, String(value));
  }, [value]);

  const handleChangeText = useCallback((text: string) => {
    if (onChangeText) {
      const opts = JSON.parse(maskOptionsJson) as Record<string, unknown>;
      const result = getNitroServiceModule().applyMask(text, resolvedMaskType, opts);
      onChangeText(result);
    }
  }, [onChangeText, resolvedMaskType, maskOptionsJson]);

  return (
    <TextInput
      {...rest}
      onChangeText={handleChangeText}
      nativeID={id}
    />
  )
}

export type * from './types';
