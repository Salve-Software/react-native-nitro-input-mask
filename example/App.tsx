import type { MaskResult } from '@salve-software/react-native-nitro-input-mask';
import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NitroInputMask, NitroInputMaskService } from '@salve-software/react-native-nitro-input-mask';

function App(): React.JSX.Element {
  const [ssn, setSsn] = useState<string>('');
  const [ssnRaw, setSsnRaw] = useState<string>('');
  const [phone, setPhone] = useState<string>('');
  const [phoneRaw, setPhoneRaw] = useState<string>('');
  const [date, setDate] = useState<string>('');
  const [dateRaw, setDateRaw] = useState<string>('');
  const [money, setMoney] = useState<string>('');
  const [moneyRaw, setMoneyRaw] = useState<string>('');

  function applySSNMask() {
    const { masked } = NitroInputMaskService.applyMask({
      value: '123456789',
      maskOptions: { mask: '999-99-9999' },
    });
    return masked;
  }

  function applyPhoneMask() {
    const { masked } = NitroInputMaskService.applyMask({
      value: '5551234567',
      maskOptions: { mask: '(999) 999-9999' },
    });
    return masked;
  }

  function applyDateMask() {
    const { masked } = NitroInputMaskService.applyMask({
      value: '11222025',
      maskType: 'datetime',
      maskOptions: { format: 'MM/DD/YYYY' },
    });
    return masked;
  }

  function applyMoneyMask() {
    const { masked } = NitroInputMaskService.applyMask({
      value: '123456',
      maskType: 'money',
      maskOptions: { unit: 'R$ ', precision: 2 },
    });
    return masked;
  }

  function handleSsnChangeText({ masked, raw }: MaskResult) {
    setSsn(masked);
    setSsnRaw(raw);
  }

  function handlePhoneChangeText({ masked, raw }: MaskResult) {
    setPhone(masked);
    setPhoneRaw(raw);
  }

  function handleDateChangeText({ masked, raw }: MaskResult) {
    setDate(masked);
    setDateRaw(raw);
  }

  function handleMoneyChangeText({ masked, raw }: MaskResult) {
    setMoney(masked);
    setMoneyRaw(raw);
  }

  return (
    <View style={styles.container}>
      <View>
        <Text style={styles.label}>TextInput</Text>

        <Text style={styles.inputLabel}>SSN</Text>
        <NitroInputMask
          maskOptions={{ mask: '999-99-9999' }}
          value={ssn}
          onChangeText={handleSsnChangeText}
          style={styles.input}
          testID="nitro-input-mask-ssn"
        />
        <Text style={styles.valueLabel}>Masked: {ssn}  Raw: {ssnRaw}</Text>

        <Text style={styles.inputLabel}>Phone</Text>
        <NitroInputMask
          maskOptions={{ mask: '(999) 999-9999' }}
          value={phone}
          onChangeText={handlePhoneChangeText}
          style={styles.input}
          testID="nitro-input-mask-phone"
        />
        <Text style={styles.valueLabel}>Masked: {phone}  Raw: {phoneRaw}</Text>

        <Text style={styles.inputLabel}>Date</Text>
        <NitroInputMask
          maskType="datetime"
          maskOptions={{ format: 'DD/MM/YYYY' }}
          value={date}
          onChangeText={handleDateChangeText}
          style={styles.input}
          testID="nitro-input-mask-date"
        />
        <Text style={styles.valueLabel}>Masked: {date}  Raw: {dateRaw}</Text>

        <Text style={styles.inputLabel}>Money</Text>
        <NitroInputMask
          maskType="money"
          maskOptions={{ unit: 'R$ ', precision: 2 }}
          value={money}
          onChangeText={handleMoneyChangeText}
          style={styles.input}
          testID="nitro-input-mask-money"
        />
        <Text style={styles.valueLabel}>Masked: {money}  Raw: {moneyRaw}</Text>
      </View>

      <View>
        <Text style={styles.label}>Service</Text>

        <Text style={styles.inputLabel}>SSN: {applySSNMask()}</Text>
        <Text style={styles.inputLabel}>Phone: {applyPhoneMask()}</Text>
        <Text style={styles.inputLabel}>Date: {applyDateMask()}</Text>
        <Text style={styles.inputLabel}>Money: {applyMoneyMask()}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
    gap: 16,
    backgroundColor: 'black',
  },

  label: {
    fontSize: 18,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 4,
    color: '#ccc',
  },

  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    alignSelf: 'flex-start',
    marginTop: 16,
    marginBottom: 4,
    color: '#ccc',
  },

  input: {
    width: 280,
    height: 44,
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 6,
    paddingHorizontal: 12,
    color: '#ccc',
  },

  valueLabel: {
    fontSize: 11,
    alignSelf: 'flex-start',
    color: '#888',
    marginTop: 2,
  },
});

export default App;
