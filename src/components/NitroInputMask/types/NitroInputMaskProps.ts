import type { TextInputProps } from 'react-native'

export type CustomMaskOptions = {
  mask: string
}

export type MoneyMaskOptions = {
  precision?: number
  separator?: string
  delimiter?: string
  unit?: string
  suffixUnit?: string
  zeroCents?: boolean
}

export type DatetimeMaskOptions = {
  format: string
}

export type CreditCardMaskOptions = {
  issuer?: 'visa-or-mastercard' | 'amex' | 'diners'
  obfuscated?: boolean
}

export type MaskConfig =
  | { maskType?: 'custom';      maskOptions: CustomMaskOptions }
  | { maskType: 'money';        maskOptions?: MoneyMaskOptions }
  | { maskType: 'datetime';     maskOptions: DatetimeMaskOptions }
  | { maskType: 'credit-card';  maskOptions?: CreditCardMaskOptions }

export type NitroInputMaskProps = TextInputProps & MaskConfig
