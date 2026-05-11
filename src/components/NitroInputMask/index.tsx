import type { NitroInputMaskProps } from './types';
import React, { useCallback, useEffect, useId } from 'react';
import { TextInput } from 'react-native';
import { nitroModule, getNitroServiceModule } from '../../nitro-module';

export const NitroInputMask = (props: NitroInputMaskProps) => {
  const { maskType, maskOptions, onChangeText, value, ...rest } = props as NitroInputMaskProps & {
    maskType?: string;
    maskOptions?: Record<string, unknown>;
  };

  const resolvedMaskType = maskType ?? 'custom';
  const reactId = useId();
  const id = `nitro-input-mask-${reactId}`;

  const maskOptionsJson = JSON.stringify(maskOptions ?? {});

  useEffect(() => {
    nitroModule.attach(id, resolvedMaskType, maskOptions ?? {});
    if (value != null) nitroModule.setValue(id, String(value));
    return () => nitroModule.detach(id);
  }, []);

  useEffect(() => {
    nitroModule.updateMask(id, resolvedMaskType, maskOptions ?? {});
  }, [resolvedMaskType, maskOptionsJson]);

  useEffect(() => {
    if (value == null) return;
    nitroModule.setValue(id, String(value));
  }, [value]);

  const handleChangeText = useCallback((text: string) => {
    if (onChangeText) {
      const parsedOptions = JSON.parse(maskOptionsJson) as Record<string, unknown>;
      const result = getNitroServiceModule().applyMask(text, resolvedMaskType, parsedOptions);
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
