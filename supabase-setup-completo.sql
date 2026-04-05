-- =====================================================
-- SUSHI TRACKER - SUPABASE SETUP COMPLETO
-- Executar este ficheiro no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. CRIAÇÃO DAS TABELAS PRINCIPAIS
-- =====================================================

-- Tabela de perfis de usuários
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de sessões de sushi
CREATE TABLE sushi_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  total_pieces INTEGER DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  sushi_types JSONB DEFAULT '[]',
  friends JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de tipos de sushi
CREATE TABLE sushi_types (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de amigos
CREATE TABLE friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  friend_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Tabela de refeições compartilhadas
CREATE TABLE shared_meals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES sushi_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. ÍNDICES PARA MELHORAR PERFORMANCE
-- =====================================================

CREATE INDEX idx_sushi_sessions_user_id ON sushi_sessions(user_id);
CREATE INDEX idx_sushi_sessions_date ON sushi_sessions(date);
CREATE INDEX idx_sushi_types_user_id ON sushi_types(user_id);
CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_friends_friend_id ON friends(friend_id);
CREATE INDEX idx_shared_meals_user_id ON shared_meals(user_id);
CREATE INDEX idx_shared_meals_date ON shared_meals(date);

-- =====================================================
-- 3. TRIGGER PARA CRIAR PERFIL AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'name'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =====================================================
-- 4. ATIVAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_meals ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. POLÍTICAS DE SEGURANÇA - PROFILES
-- =====================================================

-- Usuários podem ver o próprio perfil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Usuários podem atualizar o próprio perfil
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- 6. POLÍTICAS DE SEGURANÇA - SUSHI SESSIONS
-- =====================================================

-- Usuários podem ver as próprias sessões
CREATE POLICY "Users can view own sessions" ON sushi_sessions
  FOR SELECT USING (auth.uid() = user_id);

-- Usuários podem inserir as próprias sessões
CREATE POLICY "Users can insert own sessions" ON sushi_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuários podem atualizar as próprias sessões
CREATE POLICY "Users can update own sessions" ON sushi_sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- Usuários podem apagar as próprias sessões
CREATE POLICY "Users can delete own sessions" ON sushi_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 7. POLÍTICAS DE SEGURANÇA - SUSHI TYPES
-- =====================================================

-- Usuários podem ver os próprios tipos de sushi
CREATE POLICY "Users can view own sushi types" ON sushi_types
  FOR SELECT USING (auth.uid() = user_id);

-- Usuários podem inserir os próprios tipos de sushi
CREATE POLICY "Users can insert own sushi types" ON sushi_types
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuários podem atualizar os próprios tipos de sushi
CREATE POLICY "Users can update own sushi types" ON sushi_types
  FOR UPDATE USING (auth.uid() = user_id);

-- Usuários podem apagar os próprios tipos de sushi
CREATE POLICY "Users can delete own sushi types" ON sushi_types
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 8. POLÍTICAS DE SEGURANÇA - FRIENDS
-- =====================================================

-- Usuários podem ver os próprios amigos
CREATE POLICY "Users can view own friends" ON friends
  FOR SELECT USING (auth.uid() = user_id);

-- Usuários podem adicionar amigos
CREATE POLICY "Users can add friends" ON friends
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuários podem apagar amigos
CREATE POLICY "Users can delete friends" ON friends
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 9. POLÍTICAS DE SEGURANÇA - SHARED MEALS
-- =====================================================

-- Usuários podem ver as próprias refeições compartilhadas
CREATE POLICY "Users can view own shared meals" ON shared_meals
  FOR SELECT USING (auth.uid() = user_id);

-- Usuários podem inserir refeições compartilhadas
CREATE POLICY "Users can insert shared meals" ON shared_meals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuários podem atualizar refeições compartilhadas
CREATE POLICY "Users can update shared meals" ON shared_meals
  FOR UPDATE USING (auth.uid() = user_id);

-- Usuários podem apagar refeições compartilhadas
CREATE POLICY "Users can delete shared meals" ON shared_meals
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 10. FUNÇÕES ÚTEIS
-- =====================================================

-- Função para obter estatísticas do usuário
CREATE OR REPLACE FUNCTION get_user_stats(user_uuid UUID)
RETURNS TABLE(
  total_sessions BIGINT,
  total_pieces BIGINT,
  record_pieces BIGINT,
  average_pieces NUMERIC,
  favorite_sushi TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_sessions,
    COALESCE(SUM(total_pieces), 0) as total_pieces,
    COALESCE(MAX(total_pieces), 0) as record_pieces,
    CASE 
      WHEN COUNT(*) > 0 THEN ROUND(COALESCE(AVG(total_pieces), 0))
      ELSE 0 
    END as average_pieces,
    'Salmão' as favorite_sushi -- Placeholder - pode ser calculado depois
  FROM sushi_sessions 
  WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter sessões recentes
CREATE OR REPLACE FUNCTION get_recent_sessions(user_uuid UUID, limit_count INTEGER DEFAULT 10)
RETURNS TABLE(
  id UUID,
  date TIMESTAMP WITH TIME ZONE,
  total_pieces INTEGER,
  duration_minutes INTEGER,
  sushi_types JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    id,
    date,
    total_pieces,
    duration_minutes,
    sushi_types
  FROM sushi_sessions 
  WHERE user_id = user_uuid
  ORDER BY date DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 11. VIEWS ÚTEIS
-- =====================================================

-- View para estatísticas detalhadas
CREATE OR REPLACE VIEW user_stats_view AS
SELECT 
  p.id as user_id,
  p.name,
  p.email,
  COUNT(ss.id) as total_sessions,
  COALESCE(SUM(ss.total_pieces), 0) as total_pieces,
  COALESCE(MAX(ss.total_pieces), 0) as record_pieces,
  CASE 
    WHEN COUNT(ss.id) > 0 THEN ROUND(COALESCE(AVG(ss.total_pieces), 0))
    ELSE 0 
  END as average_pieces,
  MAX(ss.date) as last_session_date
FROM profiles p
LEFT JOIN sushi_sessions ss ON p.id = ss.user_id
GROUP BY p.id, p.name, p.email;

-- =====================================================
-- 12. TRIGGERS PARA UPDATED_AT
-- =====================================================

-- Trigger para profiles
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger para sushi_sessions
CREATE TRIGGER update_sushi_sessions_updated_at
  BEFORE UPDATE ON sushi_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 13. CONFIGURAÇÃO DA AUTENTICAÇÃO (SEM VERIFICAÇÃO)
-- =====================================================

-- Desativar verificação de email (executar no painel Supabase)
-- UPDATE auth.config SET jwt_secret = 'your-jwt-secret' WHERE jwt_secret IS NOT NULL;

-- OU executar este SQL para desativar verificação:
ALTER TABLE auth.users 
ALTER COLUMN email_confirmed_at SET DEFAULT now();

-- Criar trigger para auto-confirmar email
CREATE OR REPLACE FUNCTION public.auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  NEW.email_confirmed_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created_confirm_email
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.auto_confirm_email();

-- NOTA: No painel do Supabase, vá para:
-- Authentication > Settings
-- Desative "Enable email confirmations"
-- Site URL: http://localhost:8081
-- Redirect URLs: http://localhost:8081/**
-- Ative Email/Password provider e Apple provider

-- =====================================================
-- FIM DO SETUP
-- =====================================================

-- Para verificar se tudo foi criado corretamente:
-- SELECT * FROM profiles;
-- SELECT * FROM sushi_sessions;
-- SELECT * FROM sushi_types;
-- SELECT * FROM friends;
-- SELECT * FROM shared_meals;
