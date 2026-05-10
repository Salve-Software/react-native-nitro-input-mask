import type { NitroInputMaskProps } from './types';
import React, { useEffect, useId } from 'react';
import { TextInput } from 'react-native';
import { nitroModule } from '../../nitro-module';

export const NitroInputMask = (props: NitroInputMaskProps) => {
  const { maskType, maskOptions, value, ...rest } = props as NitroInputMaskProps & {
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
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    nitroModule.updateMask(id, resolvedMaskType, maskOptions ?? {});
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resolvedMaskType, maskOptionsJson]);

  useEffect(() => {
    if (value == null) return;
    nitroModule.setValue(id, String(value));
  }, [value]);

  return (
    <TextInput
      {...rest}
      nativeID={id}
    />
  )
}

export type * from './types';
