import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NitroInputMask } from 'react-native-nitro-input-mask';

type MaskState = { masked: string; raw: string };

function App(): React.JSX.Element {
  const [cpf, setCpf] = useState<MaskState>({ masked: '', raw: '' });
  const [phone, setPhone] = useState<MaskState>({ masked: '', raw: '' });
  const [date, setDate] = useState<MaskState>({ masked: '', raw: '' });

  return (
    <View style={styles.container}>
      <Text style={styles.label}>CPF</Text>
      <NitroInputMask
        mask="999.999.999-99"
        value={cpf.raw}
        onChangeText={(maskedValue, rawValue) =>
          setCpf({ masked: maskedValue, raw: rawValue })
        }
        style={styles.input}
        testID="nitro-input-mask-cpf"
      />
      <Text style={styles.hint}>
        masked: {cpf.masked} | raw: {cpf.raw}
      </Text>

      <Text style={styles.label}>Phone</Text>
      <NitroInputMask
        mask="(99) 99999-9999"
        value={phone.raw}
        onChangeText={(maskedValue, rawValue) =>
          setPhone({ masked: maskedValue, raw: rawValue })
        }
        style={styles.input}
        testID="nitro-input-mask-phone"
      />
      <Text style={styles.hint}>
        masked: {phone.masked} | raw: {phone.raw}
      </Text>

      <Text style={styles.label}>Date</Text>
      <NitroInputMask
        mask="99/99/9999"
        value={date.raw}
        onChangeText={(maskedValue, rawValue) =>
          setDate({ masked: maskedValue, raw: rawValue })
        }
        style={styles.input}
        testID="nitro-input-mask-date"
      />
      <Text style={styles.hint}>
        masked: {date.masked} | raw: {date.raw}
      </Text>
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
