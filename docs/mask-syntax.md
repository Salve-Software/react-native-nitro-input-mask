# Mask Syntax

## Tokens

| Token | Accepts | Example mask | Example input | Result |
|---|---|---|---|---|
| `9` | Digit (0–9) | `999-99` | `12345` | `123-45` |
| `A` | Letter (a–z, A–Z) | `AAA` | `abc` | `abc` |
| `*` | Letter or digit | `***-***` | `a1b2c3` | `a1b-2c3` |
| `[n-m]` | Integer in range n–m | `[1-12]/[1-31]/9999` | `12312023` | `12/31/2023` |
| Any other char | Literal (inserted as-is) | `(99) 99999-9999` | `11987654321` | `(11) 98765-4321` |

## Common masks

| Use case | Mask |
|---|---|
| CPF | `999.999.999-99` |
| CNPJ | `99.999.999/9999-99` |
| Phone (mobile) | `(99) 99999-9999` |
| Phone (landline) | `(99) 9999-9999` |
| Date (DD/MM/YYYY) | `99/99/9999` |
| Date with range validation | `[1-31]/[1-12]/9999` |
| Time (HH:MM) | `[0-23]:[0-59]` |
| CEP | `99999-999` |
| Credit card | `9999 9999 9999 9999` |
| License plate (Mercosul) | `AAA9*99` |

## Range token `[n-m]`

The range token validates that the digits typed form a number within `[n, m]`.

```
mask: '[1-12]/[1-31]/9999'
```

- `[1-12]` — accepts months 01–12, rejects digits that would make the number exceed 12
- `[1-31]` — accepts days 01–31

Partial input is validated as a prefix: typing `1` is accepted because it could become `10`, `11`, or `12`. Typing `9` alone is rejected because no two-digit month starts with `9`.

## Trailing literals

Literals that appear after all input slots are filled are automatically appended.

```
mask:  '(99)'
input: '12'
// → '(12)'
```

Literals that appear before any input is typed are **not** pre-filled — the field starts empty.

## Notes

- Mask tokens are case-insensitive for letters: `A` accepts both `a` and `A`.
- Characters that don't match the expected token are silently skipped — they do not block input.
- Unicode characters and emoji are not supported as input (they may produce unexpected results).
