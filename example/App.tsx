import type { MaskResult } from '@salve-software/react-native-nitro-input-mask';
import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { NitroInputMask, NitroInputMaskService } from '@salve-software/react-native-nitro-input-mask';

const ssnService = NitroInputMaskService.applyMask({
  value: '123456789',
  maskOptions: { mask: '999-99-9999' },
});

const phoneService = NitroInputMaskService.applyMask({
  value: '5551234567',
  maskOptions: { mask: '(999) 999-9999' },
});

const dateService = NitroInputMaskService.applyMask({
  value: '11222025',
  maskType: 'datetime',
  maskOptions: { format: 'MM/DD/YYYY' },
});

const moneyService = NitroInputMaskService.applyMask({
  value: '123456',
  maskType: 'money',
  maskOptions: { unit: 'R$ ', precision: 2 },
});

function App(): React.JSX.Element {
  const [tab, setTab] = useState<'input' | 'service'>('input');
  const [ssn, setSsn] = useState('');
  const [ssnRaw, setSsnRaw] = useState('');
  const [phone, setPhone] = useState('');
  const [phoneRaw, setPhoneRaw] = useState('');
  const [date, setDate] = useState('');
  const [dateRaw, setDateRaw] = useState('');
  const [money, setMoney] = useState('');
  const [moneyRaw, setMoneyRaw] = useState('');

  return (
    <View style={styles.container}>
      <View style={styles.tabs}>
        <TouchableOpacity
          style={[styles.tab, tab === 'input' && styles.tabActive]}
          onPress={() => setTab('input')}
        >
          <Text style={[styles.tabText, tab === 'input' && styles.tabTextActive]}>TextInput</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, tab === 'service' && styles.tabActive]}
          onPress={() => setTab('service')}
        >
          <Text style={[styles.tabText, tab === 'service' && styles.tabTextActive]}>Service</Text>
        </TouchableOpacity>
      </View>

      {tab === 'input'
        ?
        <View style={styles.content}>
          <Text style={styles.inputLabel}>SSN</Text>
          <NitroInputMask
            maskOptions={{ mask: '999-99-9999' }}
            value={ssn}
            onChangeText={({ masked, raw }: MaskResult) => { setSsn(masked); setSsnRaw(raw); }}
            style={styles.input}
            testID="nitro-input-mask-ssn"
          />
          <Text style={styles.valueLabel}>Masked: {ssn}  Raw: {ssnRaw}</Text>

          <Text style={styles.inputLabel}>Phone</Text>
          <NitroInputMask
            maskOptions={{ mask: '(999) 999-9999' }}
            value={phone}
            onChangeText={({ masked, raw }: MaskResult) => { setPhone(masked); setPhoneRaw(raw); }}
            style={styles.input}
            testID="nitro-input-mask-phone"
          />
          <Text style={styles.valueLabel}>Masked: {phone}  Raw: {phoneRaw}</Text>

          <Text style={styles.inputLabel}>Date</Text>
          <NitroInputMask
            maskType="datetime"
            maskOptions={{ format: 'DD/MM/YYYY' }}
            value={date}
            onChangeText={({ masked, raw }: MaskResult) => { setDate(masked); setDateRaw(raw); }}
            style={styles.input}
            testID="nitro-input-mask-date"
          />
          <Text style={styles.valueLabel}>Masked: {date}  Raw: {dateRaw}</Text>

          <Text style={styles.inputLabel}>Money</Text>
          <NitroInputMask
            maskType="money"
            maskOptions={{ unit: 'R$ ', precision: 2 }}
            value={money}
            onChangeText={({ masked, raw }: MaskResult) => { setMoney(masked); setMoneyRaw(raw); }}
            style={styles.input}
            testID="nitro-input-mask-money"
          />
          <Text style={styles.valueLabel}>Masked: {money}  Raw: {moneyRaw}</Text>
        </View>
        :
        <View style={styles.content}>
          <Text style={styles.inputLabel}>SSN</Text>
          <Text style={styles.valueLabel}>Masked: {ssnService.masked}  Raw: {ssnService.raw}</Text>

          <Text style={styles.inputLabel}>Phone</Text>
          <Text style={styles.valueLabel}>Masked: {phoneService.masked}  Raw: {phoneService.raw}</Text>

          <Text style={styles.inputLabel}>Date</Text>
          <Text style={styles.valueLabel}>Masked: {dateService.masked}  Raw: {dateService.raw}</Text>

          <Text style={styles.inputLabel}>Money</Text>
          <Text style={styles.valueLabel}>Masked: {moneyService.masked}  Raw: {moneyService.raw}</Text>
        </View>
      }
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
    paddingTop: 60,
  },

  tabs: {
    flexDirection: 'row',
    marginHorizontal: 24,
    borderRadius: 8,
    backgroundColor: '#1a1a1a',
    padding: 4,
    marginBottom: 24,
  },

  tab: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 6,
  },

  tabActive: {
    backgroundColor: '#333',
  },

  tabText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
  },

  tabTextActive: {
    color: '#ccc',
  },

  content: {
    paddingHorizontal: 24,
  },

  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 20,
    marginBottom: 6,
    color: '#ccc',
  },

  input: {
    width: '100%',
    height: 44,
    borderWidth: 1,
    borderColor: '#333',
    borderRadius: 8,
    paddingHorizontal: 12,
    color: '#fff',
    backgroundColor: '#111',
  },

  valueLabel: {
    fontSize: 11,
    color: '#888',
    marginTop: 4,
  },
});

export default App;
