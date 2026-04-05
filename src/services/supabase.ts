import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL || 'YOUR_SUPABASE_URL';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';

class SupabaseClient {
  private supabase: any;

  constructor() {
    this.supabase = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        storage: this.customStorage(),
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false,
      },
    });
  }

  private customStorage() {
    return {
      getItem: async (key: string) => {
        if (Platform.OS === 'web') {
          return localStorage.getItem(key);
        }
        return await SecureStore.getItemAsync(key);
      },
      setItem: async (key: string, value: string) => {
        if (Platform.OS === 'web') {
          localStorage.setItem(key, value);
        } else {
          await SecureStore.setItemAsync(key, value);
        }
      },
      removeItem: async (key: string) => {
        if (Platform.OS === 'web') {
          localStorage.removeItem(key);
        } else {
          await SecureStore.deleteItemAsync(key);
        }
      },
    };
  }

  getClient() {
    return this.supabase;
  }

  // Auth methods
  async signIn(email: string, password: string) {
    const { data, error } = await this.supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  }

  async signUp(email: string, password: string, name: string) {
    const { data, error } = await this.supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          name,
        },
      },
    });
    return { data, error };
  }

  async signOut() {
    const { error } = await this.supabase.auth.signOut();
    return { error };
  }

  async getCurrentUser() {
    const { data: { user } } = await this.supabase.auth.getUser();
    return user;
  }

  // Database methods
  async createSushiSession(sessionData: any) {
    const { data, error } = await this.supabase
      .from('sushi_sessions')
      .insert(sessionData)
      .select()
      .single();
    return { data, error };
  }

  async getSushiSessions(userId: string) {
    const { data, error } = await this.supabase
      .from('sushi_sessions')
      .select('*')
      .eq('user_id', userId)
      .order('date', { ascending: false });
    return { data, error };
  }

  async updateSushiSession(sessionId: string, updates: any) {
    const { data, error } = await this.supabase
      .from('sushi_sessions')
      .update(updates)
      .eq('id', sessionId)
      .select()
      .single();
    return { data, error };
  }

  async deleteSushiSession(sessionId: string) {
    const { error } = await this.supabase
      .from('sushi_sessions')
      .delete()
      .eq('id', sessionId);
    return { error };
  }

  async getUserStats(userId: string) {
    const { data, error } = await this.supabase
      .from('sushi_sessions')
      .select('total_pieces')
      .eq('user_id', userId);
    
    if (error) return { data: null, error };
    
    const totalSessions = data?.length || 0;
    const totalPieces = data?.reduce((sum: number, session: any) => sum + session.total_pieces, 0) || 0;
    const recordPieces = data?.reduce((max: number, session: any) => Math.max(max, session.total_pieces), 0) || 0;
    const averagePieces = totalSessions > 0 ? Math.round(totalPieces / totalSessions) : 0;
    
    return {
      data: {
        total_sessions: totalSessions,
        total_pieces: totalPieces,
        record_pieces: recordPieces,
        average_pieces: averagePieces,
        favorite_sushi: 'Salmão',
      },
      error: null,
    };
  }
}

export default new SupabaseClient();
