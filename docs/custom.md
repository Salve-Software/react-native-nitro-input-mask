# Custom Mask

The `custom` mask type lets you define a fixed pattern using tokens and literal characters.

## Usage

```tsx
<NitroInputMask
  maskOptions={{ mask: '999.999.999-99' }}
  keyboardType="numeric"
/>
```

`maskType` defaults to `'custom'`, so it can be omitted.

## Tokens

| Token | Accepts |
|---|---|
| `9` | Any digit (`0`–`9`) |
| `A` | Any letter (`a`–`z`, `A`–`Z`) |
| `*` | Any letter or digit |
| `[n-m]` | Integer in the inclusive range `n`–`m` |
| Any other character | Literal — inserted automatically |

Literals are inserted as the user types and skipped automatically on deletion.

## Range token `[n-m]`

The range token validates the input as an integer within bounds. It allocates as many character slots as the widest bound needs.

```
[1-12]   → 2 slots (month: accepts 1–12)
[1-31]   → 2 slots (day: accepts 1–31)
[0-23]   → 2 slots (hour in 24h: accepts 0–23)
[0-59]   → 2 slots (minutes/seconds: accepts 0–59)
```

The engine validates digit by digit. If the current prefix can still produce a valid value within the range, it is accepted. Otherwise the digit is rejected.

**Example:** for `[1-12]`, typing `1` is accepted (could become `10`, `11`, or `12`). Typing `2` is also accepted (becomes `2`). Typing `9` at the start is rejected (no value `9x` falls within `1`–`12`).

## Examples

| Mask | Example output |
|---|---|
| `999.999.999-99` | `123.456.789-09` |
| `(99) 99999-9999` | `(11) 98765-4321` |
| `AAA-9999` | `ABC-1234` |
| `99/[1-12]/9999` | `25/06/2025` |
| `****-****` | `ab12-cd34` |
