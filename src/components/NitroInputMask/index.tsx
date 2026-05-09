import type { NitroInputMaskProps } from './types';
import React, { useEffect, useId } from 'react';
import { TextInput } from 'react-native';
import { nitroModule } from '../../nitro-module';

export const NitroInputMask = (props: NitroInputMaskProps) => {
  const { mask, value } = props;

  const reactId = useId();
  const id = `nitro-input-mask-${reactId}`;

  useEffect(() => {
    nitroModule.attach(id, mask);
    if (value != null) nitroModule.setValue(id, String(value));

    return () => nitroModule.detach(id);
  }, []);

  useEffect(() => {
    nitroModule.updateMask(id, mask);
  }, [mask]);

  useEffect(() => {
    if (value == null) return;
    nitroModule.setValue(id, String(value));
  }, [value]);

  return (
    <TextInput
      {...props}
      nativeID={id}
    />
  )
}

export type * from './types';
