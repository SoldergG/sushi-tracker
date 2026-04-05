import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useApp } from '../context/AppContext';
import { UserStats } from '../types';

interface HomeScreenProps {
  onStartSession: () => void;
  onViewStats: () => void;
  onViewCalendar: () => void;
  onKeepAwake: () => void;
  onSushiList: () => void;
}

export function HomeScreen({ 
  onStartSession, 
  onViewStats, 
  onViewCalendar, 
  onKeepAwake,
  onSushiList 
}: HomeScreenProps) {
  const { user, signOut } = useApp();
  const [stats, setStats] = React.useState<UserStats | null>(null);

  React.useEffect(() => {
    // TODO: Load user stats from Supabase
    setStats({
      total_sessions: 12,
      total_pieces: 284,
      record_pieces: 45,
      average_pieces: 24,
      favorite_sushi: 'Salmão',
    });
  }, []);

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error: any) {
      console.error('Error signing out:', error);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.welcome}>Bem-vindo(a),</Text>
        <Text style={styles.userName}>{(user as any)?.user_metadata?.name || user?.email}</Text>
      </View>

      {stats && (
        <View style={styles.statsContainer}>
          <Text style={styles.sectionTitle}>📊 As Tuas Estatísticas</Text>
          
          <View style={styles.statsGrid}>
            <View style={styles.statCard}>
              <Text style={styles.statNumber}>{stats.total_sessions}</Text>
              <Text style={styles.statLabel}>Sessões</Text>
            </View>
            
            <View style={styles.statCard}>
              <Text style={styles.statNumber}>{stats.total_pieces}</Text>
              <Text style={styles.statLabel}>Total Peças</Text>
            </View>
            
            <View style={styles.statCard}>
              <Text style={styles.statNumber}>{stats.record_pieces}</Text>
              <Text style={styles.statLabel}>Recorde</Text>
            </View>
            
            <View style={styles.statCard}>
              <Text style={styles.statNumber}>{stats.average_pieces}</Text>
              <Text style={styles.statLabel}>Média</Text>
            </View>
          </View>

          <View style={styles.favoriteCard}>
            <Text style={styles.favoriteLabel}>🍣 Favorito:</Text>
            <Text style={styles.favoriteValue}>{stats.favorite_sushi}</Text>
          </View>
        </View>
      )}

      <View style={styles.actionsContainer}>
        <Text style={styles.sectionTitle}>🎯 Ações Rápidas</Text>
        
        <TouchableOpacity style={styles.actionButton} onPress={onStartSession}>
          <Text style={styles.actionButtonTitle}>🍱 Nova Sessão</Text>
          <Text style={styles.actionButtonSubtitle}>Começa a contar peças</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.actionButton} onPress={onViewStats}>
          <Text style={styles.actionButtonTitle}>📈 Ver Estatísticas</Text>
          <Text style={styles.actionButtonSubtitle}>Detalhes completos</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.actionButton} onPress={onViewCalendar}>
          <Text style={styles.actionButtonTitle}>📅 Calendário</Text>
          <Text style={styles.actionButtonSubtitle}>Refeições com amigos</Text>
        </TouchableOpacity>

        <TouchableOpacity style={[styles.actionButton, styles.keepAwakeButton]} onPress={onKeepAwake}>
          <Text style={styles.actionButtonTitle}>⚡ Modo Contínuo</Text>
          <Text style={styles.actionButtonSubtitle}>Tela nunca se apaga</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.actionButton} onPress={onSushiList}>
          <Text style={styles.actionButtonTitle}>📝 Lista de Sushi</Text>
          <Text style={styles.actionButtonSubtitle}>Gerir tipos de sushi</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity style={styles.signOutButton} onPress={handleSignOut}>
        <Text style={styles.signOutText}>Sair</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    backgroundColor: '#E63946',
    padding: 30,
    paddingTop: 60,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  welcome: {
    fontSize: 18,
    color: '#fff',
    opacity: 0.9,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 5,
  },
  statsContainer: {
    margin: 20,
    padding: 20,
    backgroundColor: '#fff',
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  statCard: {
    width: '48%',
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 10,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#E63946',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  favoriteCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 10,
  },
  favoriteLabel: {
    fontSize: 16,
    color: '#333',
  },
  favoriteValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#E63946',
  },
  actionsContainer: {
    margin: 20,
  },
  actionButton: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  keepAwakeButton: {
    backgroundColor: '#FFB700',
  },
  actionButtonTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  actionButtonSubtitle: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  signOutButton: {
    margin: 20,
    padding: 15,
    backgroundColor: '#dc3545',
    borderRadius: 10,
    alignItems: 'center',
  },
  signOutText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
