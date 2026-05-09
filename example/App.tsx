import React from 'react';
import { View, StyleSheet } from 'react-native';
import { NitroMask } from 'react-native-nitro-mask';

function App(): React.JSX.Element {
  return (
    <View style={styles.container}>
        <NitroMask isRed={true} style={styles.view} testID="nitro-mask" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  view: {
    width: 200,
    height: 200
  }});

export default App;