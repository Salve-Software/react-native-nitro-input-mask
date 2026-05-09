import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NitroInputMask } from 'react-native-nitro-input-mask';

function App(): React.JSX.Element {
  const [cpf, setCpf] = useState<string>('');
  const [phone, setPhone] = useState<string>('');
  const [date, setDate] = useState<string>('');

  return (
    <View style={styles.container}>
      <Text style={styles.label}>CPF</Text>
      <NitroInputMask
        mask="999.999.999-99"
        value={cpf}
        onChangeText={setCpf}
        style={styles.input}
        testID="nitro-input-mask-cpf"
      />

      <Text style={styles.label}>Phone</Text>
      <NitroInputMask
        mask="(99) 99999-9999"
        value={phone}
        onChangeText={setPhone}
        style={styles.input}
        testID="nitro-input-mask-phone"
      />

      <Text style={styles.label}>Date</Text>
      <NitroInputMask
        mask="99/99/9999"
        value={date}
        onChangeText={setDate}
        style={styles.input}
        testID="nitro-input-mask-date"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  label: {
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
  hint: {
    fontSize: 12,
    color: '#666',
    alignSelf: 'flex-start',
    marginTop: 4,
  },
});

export default App;
