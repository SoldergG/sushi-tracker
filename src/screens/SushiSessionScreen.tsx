import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { useApp } from '../context/AppContext';
import supabase from '../services/supabase';

interface SushiSessionScreenProps {
  onBack: () => void;
}

interface SushiType {
  id: string;
  name: string;
  pieces: number;
}

export function SushiSessionScreen({ onBack }: SushiSessionScreenProps) {
  const { user } = useApp();
  const [isSessionActive, setIsSessionActive] = useState(false);
  const [totalPieces, setTotalPieces] = useState(0);
  const [sessionStartTime, setSessionStartTime] = useState<Date | null>(null);
  const [sushiTypes, setSushiTypes] = useState<SushiType[]>([
    { id: '1', name: 'Salmão', pieces: 0 },
    { id: '2', name: 'Atum', pieces: 0 },
    { id: '3', name: 'Pargo', pieces: 0 },
    { id: '4', name: 'Lula', pieces: 0 },
    { id: '5', name: 'Camarão', pieces: 0 },
    { id: '6', name: 'Polvo', pieces: 0 },
    { id: '7', name: 'Robalo', pieces: 0 },
    { id: '8', name: 'Dourada', pieces: 0 },
  ]);
  const [currentSessionId, setCurrentSessionId] = useState<string | null>(null);

  useEffect(() => {
    let interval: ReturnType<typeof setInterval>;
    if (isSessionActive && sessionStartTime) {
      interval = setInterval(() => {
        // Update timer if needed
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isSessionActive, sessionStartTime]);

  const startSession = async () => {
    try {
      const sessionData = {
        user_id: user?.id,
        date: new Date().toISOString(),
        total_pieces: 0,
        duration_minutes: 0,
        sushi_types: sushiTypes.map(type => ({
          name: type.name,
          pieces: 0,
        })),
      };

      const { data, error } = await supabase.createSushiSession(sessionData);
      if (error) throw error;

      setCurrentSessionId(data.id);
      setIsSessionActive(true);
      setSessionStartTime(new Date());
      setTotalPieces(0);
      setSushiTypes(sushiTypes.map(type => ({ ...type, pieces: 0 })));
    } catch (error: any) {
      Alert.alert('Erro', 'Não foi possível iniciar a sessão');
      console.error('Error starting session:', error);
    }
  };

  const endSession = async () => {
    if (!currentSessionId || !sessionStartTime) return;

    try {
      const endTime = new Date();
      const duration = Math.round((endTime.getTime() - sessionStartTime.getTime()) / 60000);

      const updates = {
        total_pieces: totalPieces,
        duration_minutes: duration,
        sushi_types: sushiTypes.filter(type => type.pieces > 0).map(type => ({
          name: type.name,
          pieces: type.pieces,
        })),
      };

      const { error } = await supabase.updateSushiSession(currentSessionId, updates);
      if (error) throw error;

      Alert.alert(
        'Sessão Terminada!',
        `Comeste ${totalPieces} peças em ${duration} minutos!\nRecorde pessoal: ${totalPieces} peças`,
        [{ text: 'OK', onPress: onBack }]
      );

      setIsSessionActive(false);
      setCurrentSessionId(null);
      setSessionStartTime(null);
    } catch (error: any) {
      Alert.alert('Erro', 'Não foi possível terminar a sessão');
      console.error('Error ending session:', error);
    }
  };

  const addPiece = (sushiTypeId: string) => {
    if (!isSessionActive) return;

    setSushiTypes(prev => 
      prev.map(type => 
        type.id === sushiTypeId 
          ? { ...type, pieces: type.pieces + 1 }
          : type
      )
    );
    setTotalPieces(prev => prev + 1);
  };

  const removePiece = (sushiTypeId: string) => {
    if (!isSessionActive) return;

    setSushiTypes(prev => 
      prev.map(type => 
        type.id === sushiTypeId && type.pieces > 0
          ? { ...type, pieces: type.pieces - 1 }
          : type
      )
    );
    setTotalPieces(prev => Math.max(0, prev - 1));
  };

  const getElapsedTime = () => {
    if (!sessionStartTime) return '00:00';
    const elapsed = Math.floor((new Date().getTime() - sessionStartTime.getTime()) / 1000);
    const minutes = Math.floor(elapsed / 60);
    const seconds = elapsed % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Voltar</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Sessão de Sushi</Text>
      </View>

      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{totalPieces}</Text>
          <Text style={styles.statLabel}>Peças Totais</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>{getElapsedTime()}</Text>
          <Text style={styles.statLabel}>Tempo</Text>
        </View>
      </View>

      {!isSessionActive ? (
        <View style={styles.startContainer}>
          <Text style={styles.instructionText}>
            Pronto para começar a contar as tuas peças de sushi?
          </Text>
          <TouchableOpacity style={styles.startButton} onPress={startSession}>
            <Text style={styles.startButtonText}>🍱 Começar Sessão</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.sessionContainer}>
          <Text style={styles.sessionActiveText}>Sessão Ativa</Text>
          
          <View style={styles.sushiGrid}>
            {sushiTypes.map((sushi) => (
              <View key={sushi.id} style={styles.sushiCard}>
                <Text style={styles.sushiName}>{sushi.name}</Text>
                <View style={styles.sushiControls}>
                  <TouchableOpacity 
                    style={styles.minusButton} 
                    onPress={() => removePiece(sushi.id)}
                  >
                    <Text style={styles.buttonText}>−</Text>
                  </TouchableOpacity>
                  <Text style={styles.sushiCount}>{sushi.pieces}</Text>
                  <TouchableOpacity 
                    style={styles.plusButton} 
                    onPress={() => addPiece(sushi.id)}
                  >
                    <Text style={styles.buttonText}>+</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>

          <TouchableOpacity style={styles.endButton} onPress={endSession}>
            <Text style={styles.endButtonText}>🏁 Terminar Sessão</Text>
          </TouchableOpacity>
        </View>
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
    backgroundColor: '#E63946',
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
    justifyContent: 'space-around',
    padding: 20,
    backgroundColor: '#fff',
    margin: 20,
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statCard: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#E63946',
  },
  statLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  startContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  instructionText: {
    fontSize: 18,
    color: '#333',
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 24,
  },
  startButton: {
    backgroundColor: '#E63946',
    padding: 20,
    borderRadius: 15,
    alignItems: 'center',
  },
  startButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  sessionContainer: {
    flex: 1,
    padding: 20,
  },
  sessionActiveText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#28a745',
    textAlign: 'center',
    marginBottom: 20,
  },
  sushiGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  sushiCard: {
    width: '48%',
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  sushiName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
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
    marginLeft: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  sushiCount: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    minWidth: 30,
    textAlign: 'center',
  },
  endButton: {
    backgroundColor: '#dc3545',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  endButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
