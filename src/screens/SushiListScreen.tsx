import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert, FlatList, TextInput } from 'react-native';
import { useApp } from '../context/AppContext';

interface SushiType {
  id: string;
  name: string;
  pieces: number;
  created_at: string;
}

interface SushiListScreenProps {
  onBack: () => void;
}

export function SushiListScreen({ onBack }: SushiListScreenProps) {
  const [sushiTypes, setSushiTypes] = useState<SushiType[]>([
    { id: '1', name: 'Salmão', pieces: 0, created_at: new Date().toISOString() },
    { id: '2', name: 'Atum', pieces: 0, created_at: new Date().toISOString() },
    { id: '3', name: 'Pargo', pieces: 0, created_at: new Date().toISOString() },
    { id: '4', name: 'Lula', pieces: 0, created_at: new Date().toISOString() },
    { id: '5', name: 'Camarão', pieces: 0, created_at: new Date().toISOString() },
    { id: '6', name: 'Polvo', pieces: 0, created_at: new Date().toISOString() },
    { id: '7', name: 'Robalo', pieces: 0, created_at: new Date().toISOString() },
    { id: '8', name: 'Dourada', pieces: 0, created_at: new Date().toISOString() },
    { id: '9', name: 'Enguia', pieces: 0, created_at: new Date().toISOString() },
    { id: '10', name: 'Ovas', pieces: 0, created_at: new Date().toISOString() },
  ]);
  const [newSushiName, setNewSushiName] = useState('');
  const [showAddForm, setShowAddForm] = useState(false);

  const addSushiType = () => {
    if (!newSushiName.trim()) {
      Alert.alert('Erro', 'Por favor, insira um nome para o tipo de sushi');
      return;
    }

    const newSushi: SushiType = {
      id: Date.now().toString(),
      name: newSushiName.trim(),
      pieces: 0,
      created_at: new Date().toISOString(),
    };

    setSushiTypes(prev => [...prev, newSushi]);
    setNewSushiName('');
    setShowAddForm(false);
  };

  const deleteSushiType = (id: string, name: string) => {
    Alert.alert(
      'Apagar Tipo de Sushi',
      `Tem certeza que deseja apagar "${name}"?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Apagar', 
          onPress: () => {
            setSushiTypes(prev => prev.filter(sushi => sushi.id !== id));
          },
          style: 'destructive'
        }
      ]
    );
  };

  const resetAllCounters = () => {
    Alert.alert(
      'Reiniciar Todos os Contadores',
      'Tem certeza que deseja reiniciar todos os contadores para zero?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Reiniciar', 
          onPress: () => {
            setSushiTypes(prev => prev.map(sushi => ({ ...sushi, pieces: 0 })));
          },
          style: 'destructive'
        }
      ]
    );
  };

  const getTotalPieces = () => {
    return sushiTypes.reduce((total, sushi) => total + sushi.pieces, 0);
  };

  const incrementPieces = (id: string) => {
    setSushiTypes(prev => 
      prev.map(sushi => 
        sushi.id === id 
          ? { ...sushi, pieces: sushi.pieces + 1 }
          : sushi
      )
    );
  };

  const decrementPieces = (id: string) => {
    setSushiTypes(prev => 
      prev.map(sushi => 
        sushi.id === id && sushi.pieces > 0
          ? { ...sushi, pieces: sushi.pieces - 1 }
          : sushi
      )
    );
  };

  const renderSushiItem = ({ item }: { item: SushiType }) => (
    <View style={styles.sushiItem}>
      <View style={styles.sushiInfo}>
        <Text style={styles.sushiName}>{item.name}</Text>
        <Text style={styles.sushiPieces}>{item.pieces} peças</Text>
      </View>
      
      <View style={styles.sushiControls}>
        <TouchableOpacity 
          style={styles.minusButton} 
          onPress={() => decrementPieces(item.id)}
        >
          <Text style={styles.buttonText}>−</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.plusButton} 
          onPress={() => incrementPieces(item.id)}
        >
          <Text style={styles.buttonText}>+</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.deleteButton} 
          onPress={() => deleteSushiType(item.id, item.name)}
        >
          <Text style={styles.deleteButtonText}>🗑️</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Voltar</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Lista de Sushi</Text>
      </View>

      <View style={styles.statsContainer}>
        <Text style={styles.totalText}>Total: {getTotalPieces()} peças</Text>
        <TouchableOpacity style={styles.resetAllButton} onPress={resetAllCounters}>
          <Text style={styles.resetAllButtonText}>Reiniciar Tudo</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.listContainer}>
        <FlatList
          data={sushiTypes}
          renderItem={renderSushiItem}
          keyExtractor={(item) => item.id}
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.listContent}
        />
      </View>

      {showAddForm && (
        <View style={styles.addForm}>
          <Text style={styles.addFormTitle}>Adicionar Novo Tipo</Text>
          <TextInput
            style={styles.input}
            placeholder="Nome do sushi"
            value={newSushiName}
            onChangeText={setNewSushiName}
            autoFocus
          />
          <View style={styles.addFormButtons}>
            <TouchableOpacity 
              style={styles.cancelButton} 
              onPress={() => {
                setShowAddForm(false);
                setNewSushiName('');
              }}
            >
              <Text style={styles.cancelButtonText}>Cancelar</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.addButton} onPress={addSushiType}>
              <Text style={styles.addButtonText}>Adicionar</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {!showAddForm && (
        <TouchableOpacity 
          style={styles.floatingAddButton} 
          onPress={() => setShowAddForm(true)}
        >
          <Text style={styles.floatingAddButtonText}>+</Text>
        </TouchableOpacity>
      )}
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
    backgroundColor: '#6c757d',
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
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  totalText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  resetAllButton: {
    backgroundColor: '#dc3545',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 5,
  },
  resetAllButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  listContainer: {
    flex: 1,
  },
  listContent: {
    padding: 20,
  },
  sushiItem: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  sushiInfo: {
    flex: 1,
  },
  sushiName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  sushiPieces: {
    fontSize: 14,
    color: '#666',
  },
  sushiControls: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  minusButton: {
    backgroundColor: '#dc3545',
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  plusButton: {
    backgroundColor: '#28a745',
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  deleteButton: {
    backgroundColor: '#6c757d',
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  deleteButtonText: {
    fontSize: 14,
  },
  addForm: {
    backgroundColor: '#fff',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  addFormTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 15,
  },
  addFormButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelButton: {
    backgroundColor: '#6c757d',
    padding: 12,
    borderRadius: 8,
    flex: 1,
    marginRight: 10,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  addButton: {
    backgroundColor: '#28a745',
    padding: 12,
    borderRadius: 8,
    flex: 1,
    alignItems: 'center',
  },
  addButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  floatingAddButton: {
    position: 'absolute',
    bottom: 30,
    right: 30,
    backgroundColor: '#28a745',
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
  },
  floatingAddButtonText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
  },
});
