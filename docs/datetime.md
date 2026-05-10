# Datetime Mask

The `datetime` mask type formats dates and times using a human-readable format string. Each token is converted to the appropriate range constraint internally.

## Usage

```tsx
<NitroInputMask
  maskType="datetime"
  maskOptions={{ format: 'DD/MM/YYYY' }}
  keyboardType="numeric"
/>
```

## Format tokens

| Token | Range | Slots | Description |
|---|---|---|---|
| `DD` | `[1-31]` | 2 | Day of month |
| `MM` | `[1-12]` | 2 | Month |
| `YYYY` | `9999` | 4 | Four-digit year |
| `HH` | `[0-23]` | 2 | Hour (24h) |
| `hh` | `[1-12]` | 2 | Hour (12h) |
| `mm` | `[0-59]` | 2 | Minutes |
| `ss` | `[0-59]` | 2 | Seconds |
| Any other character | Literal | — | Inserted automatically |

Tokens are matched longest-first, so `MM` is always detected before a single `M`.

## Examples

| Format | Example output |
|---|---|
| `DD/MM/YYYY` | `25/06/2025` |
| `MM/DD/YYYY` | `06/25/2025` |
| `YYYY-MM-DD` | `2025-06-25` |
| `DD/MM/YYYY HH:mm` | `25/06/2025 14:30` |
| `hh:mm:ss` | `02:45:10` |
