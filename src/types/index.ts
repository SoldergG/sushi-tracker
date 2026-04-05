export interface User {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  created_at: string;
}

export interface SushiSession {
  id: string;
  user_id: string;
  date: string;
  total_pieces: number;
  duration_minutes: number;
  sushi_types: SushiType[];
  friends?: Friend[];
  created_at: string;
}

export interface SushiType {
  id: string;
  name: string;
  pieces: number;
  session_id: string;
}

export interface Friend {
  id: string;
  name: string;
  email: string;
  avatar_url?: string;
}

export interface UserStats {
  total_sessions: number;
  total_pieces: number;
  record_pieces: number;
  average_pieces: number;
  favorite_sushi: string;
}

export interface AuthState {
  user: User | null;
  session: any | null;
  loading: boolean;
}

export interface AppContextType {
  user: User | null;
  session: any | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, name: string) => Promise<void>;
  signOut: () => Promise<void>;
}
