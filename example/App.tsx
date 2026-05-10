import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NitroInputMask, NitroInputMaskService } from 'react-native-nitro-input-mask';

function App(): React.JSX.Element {
  const [cpf, setCpf] = useState<string>('');
  const [phone, setPhone] = useState<string>('');
  const [date, setDate] = useState<string>('');
  const [money, setMoney] = useState<string>('');

  function applyCPFMask() {
    return NitroInputMaskService.applyMask({
      value: '02145622051',
      maskOptions: { mask: '999.999.999-99' },
    });
  }

  function applyPhoneMask() {
    return NitroInputMaskService.applyMask({
      value: '90834513624',
      maskOptions: { mask: '(99) 99999-9999' },
    });
  }

  function applyDateMask() {
    return NitroInputMaskService.applyMask({
      value: '11222025',
      maskType: 'datetime',
      maskOptions: { format: 'MM/DD/YYYY' },
    });
  }

  function applyMoneyMask() {
    return NitroInputMaskService.applyMask({
      value: '123456',
      maskType: 'money',
      maskOptions: { unit: 'R$ ', precision: 2 },
    });
  }

  return (
    <View style={styles.container}>
      <View>
        <Text style={styles.label}>TextInput</Text>

        <Text style={styles.inputLabel}>CPF</Text>
        <NitroInputMask
          maskOptions={{ mask: '999.999.999-99' }}
          value={cpf}
          onChangeText={setCpf}
          style={styles.input}
          testID="nitro-input-mask-cpf"
        />

        <Text style={styles.inputLabel}>Phone</Text>
        <NitroInputMask
          maskOptions={{ mask: '(99) 99999-9999' }}
          value={phone}
          onChangeText={setPhone}
          style={styles.input}
          testID="nitro-input-mask-phone"
        />

        <Text style={styles.inputLabel}>Date</Text>
        <NitroInputMask
          maskType="datetime"
          maskOptions={{ format: 'DD/MM/YYYY' }}
          value={date}
          onChangeText={setDate}
          style={styles.input}
          testID="nitro-input-mask-date"
        />

        <Text style={styles.inputLabel}>Money</Text>
        <NitroInputMask
          maskType="money"
          maskOptions={{ unit: 'R$ ', precision: 2 }}
          value={money}
          onChangeText={setMoney}
          style={styles.input}
          testID="nitro-input-mask-money"
        />
      </View>

      <View>
        <Text style={styles.label}>Service</Text>

        <Text style={styles.inputLabel}>CPF: {applyCPFMask()}</Text>
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
});

export default App;
