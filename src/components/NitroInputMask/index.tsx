import type { NitroInputMaskProps } from './types';
import type { NitroMaskOptions } from '../../specs/nitro-input-mask.nitro';
import React, { useCallback, useEffect, useId, useMemo, useRef } from 'react';
import { TextInput } from 'react-native';
import { nitroModule, getNitroServiceModule } from '../../nitro-module';

export const NitroInputMask = (props: NitroInputMaskProps) => {
  const { maskType, maskOptions, onChangeText, value, ...rest } = props;

  const reactId = useId();

  const resolvedMaskType = maskType ?? 'custom';
  const resolvedOptions = (maskOptions ?? {}) as Record<string, unknown>;
  const id = `nitro-input-mask-${reactId}`;
  const maskOptionsJson = JSON.stringify(resolvedOptions);

  const stableOptions: NitroMaskOptions = useMemo(() => JSON.parse(maskOptionsJson), [maskOptionsJson]);
  const valueFromUserInput = useRef(false);

  useEffect(() => {
    nitroModule.attach(id, resolvedMaskType, stableOptions);
    if (value != null) nitroModule.setValue(id, String(value));
    return () => nitroModule.detach(id);
  }, []);

  useEffect(() => {
    nitroModule.updateMask(id, resolvedMaskType, stableOptions);
  }, [resolvedMaskType, maskOptionsJson]);

  useEffect(() => {
    if (value == null) return;

    if (valueFromUserInput.current) {
      valueFromUserInput.current = false;
      return;
    }

    nitroModule.setValue(id, String(value));
  }, [value]);

  const handleChangeText = useCallback((text: string) => {
    valueFromUserInput.current = true;
    
    if (onChangeText) {
      const result = getNitroServiceModule().applyMask(text, resolvedMaskType, stableOptions);
      onChangeText(result);
    }
  }, [onChangeText, resolvedMaskType, stableOptions]);

  return (
    <TextInput 
      {...rest}
      onChangeText={handleChangeText}
      nativeID={id}
    />
  )
}

export type * from './types';
