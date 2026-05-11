import type { CreditCardMaskOptions } from "./CreditCardMaskOptions";
import type { CustomMaskOptions } from "./CustomMaskOptions";
import type { DatetimeMaskOptions } from "./DatetimeMaskOptions";
import type { MoneyMaskOptions } from "./MoneyMaskOptions";

export type MaskConfig =
  | { maskType?: 'custom'; maskOptions: CustomMaskOptions }
  | { maskType: 'money'; maskOptions?: MoneyMaskOptions }
  | { maskType: 'datetime'; maskOptions: DatetimeMaskOptions }
  | { maskType: 'credit-card'; maskOptions?: CreditCardMaskOptions }
