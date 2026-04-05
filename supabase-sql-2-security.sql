-- =====================================================
-- ATIVAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_meals ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS DE SEGURANÇA - PROFILES
-- =====================================================

-- Usuários podem ver o próprio perfil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Usuários podem atualizar o próprio perfil
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- POLÍTICAS DE SEGURANÇA - SUSHI SESSIONS
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
-- POLÍTICAS DE SEGURANÇA - SUSHI TYPES
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
-- POLÍTICAS DE SEGURANÇA - FRIENDS
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
-- POLÍTICAS DE SEGURANÇA - SHARED MEALS
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
