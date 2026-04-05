import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import KeepAwake from 'react-native-keep-awake';

interface KeepAwakeScreenProps {
  onBack: () => void;
}

export function KeepAwakeScreen({ onBack }: KeepAwakeScreenProps) {
  const [totalPieces, setTotalPieces] = useState(0);
  const [isKeepAwakeActive, setIsKeepAwakeActive] = useState(false);

  useEffect(() => {
    // Activate keep awake when component mounts
    KeepAwake.activate();
    setIsKeepAwakeActive(true);

    // Deactivate when component unmounts
    return () => {
      KeepAwake.deactivate();
      setIsKeepAwakeActive(false);
    };
  }, []);

  const addPiece = () => {
    setTotalPieces(prev => prev + 1);
  };

  const resetCounter = () => {
    Alert.alert(
      'Reiniciar Contador',
      'Tem certeza que deseja reiniciar o contador?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Reiniciar', 
          onPress: () => setTotalPieces(0),
          style: 'destructive'
        }
      ]
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Voltar</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Modo Contínuo</Text>
      </View>

      <View style={styles.statusContainer}>
        <View style={styles.statusCard}>
          <Text style={styles.statusText}>
            {isKeepAwakeActive ? '⚡ Tela Ativa' : '😴 Tela Normal'}
          </Text>
          <Text style={styles.statusDescription}>
            A tela nunca se apagará enquanto estiver modo ativo
          </Text>
        </View>
      </View>

      <View style={styles.counterContainer}>
        <Text style={styles.counterLabel}>Peças de Sushi</Text>
        <Text style={styles.counterNumber}>{totalPieces}</Text>
        <Text style={styles.counterSubtext}>toque para adicionar</Text>
      </View>

      <TouchableOpacity 
        style={styles.addButton} 
        onPress={addPiece}
        activeOpacity={0.8}
      >
        <Text style={styles.addButtonText}>+1 Peça</Text>
      </TouchableOpacity>

      <View style={styles.actionsContainer}>
        <TouchableOpacity style={styles.resetButton} onPress={resetCounter}>
          <Text style={styles.resetButtonText}>🔄 Reiniciar</Text>
        </TouchableOpacity>

        <TouchableOpacity 
          style={styles.toggleButton} 
          onPress={() => {
            if (isKeepAwakeActive) {
              KeepAwake.deactivate();
              setIsKeepAwakeActive(false);
            } else {
              KeepAwake.activate();
              setIsKeepAwakeActive(true);
            }
          }}
        >
          <Text style={styles.toggleButtonText}>
            {isKeepAwakeActive ? '⏸️ Pausar Tela' : '▶️ Ativar Tela'}
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.instructionsContainer}>
        <Text style={styles.instructionsTitle}>📋 Instruções</Text>
        <Text style={styles.instructionsText}>
          • Toque no botão "+1 Peça" para adicionar uma peça de sushi
        </Text>
        <Text style={styles.instructionsText}>
          • A tela permanecerá ativa para facilitar a contagem
        </Text>
        <Text style={styles.instructionsText}>
          • Use "Reiniciar" para zerar o contador
        </Text>
        <Text style={styles.instructionsText}>
          • Pausar a tela permite que o dispositivo desligue normalmente
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    paddingTop: 60,
    backgroundColor: '#FFB700',
  },
  backButton: {
    marginRight: 15,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  statusContainer: {
    padding: 20,
  },
  statusCard: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 15,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statusText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FFB700',
    marginBottom: 5,
  },
  statusDescription: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  counterContainer: {
    alignItems: 'center',
    padding: 30,
  },
  counterLabel: {
    fontSize: 18,
    color: '#333',
    marginBottom: 10,
  },
  counterNumber: {
    fontSize: 72,
    fontWeight: 'bold',
    color: '#E63946',
    marginBottom: 5,
  },
  counterSubtext: {
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
  },
  addButton: {
    backgroundColor: '#E63946',
    marginHorizontal: 20,
    padding: 20,
    borderRadius: 15,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
  },
  addButtonText: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  actionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 20,
  },
  resetButton: {
    backgroundColor: '#dc3545',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    minWidth: 120,
  },
  resetButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  toggleButton: {
    backgroundColor: '#6c757d',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    minWidth: 120,
  },
  toggleButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  instructionsContainer: {
    backgroundColor: '#fff',
    margin: 20,
    padding: 20,
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  instructionsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  instructionsText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
    lineHeight: 20,
  },
});
