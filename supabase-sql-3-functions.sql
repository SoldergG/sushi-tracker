-- =====================================================
-- DADOS INICIAIS - TIPOS DE SUSHI PADRÃO
-- =====================================================

-- NOTA: Estes dados serão inseridos quando o primeiro usuário se registrar
-- através da aplicação. Este SQL é apenas para referência.

-- Exemplo de como inserir tipos de sushi para um usuário específico:
-- Substitua USER_ID pelo UUID real do usuário

-- INSERT INTO sushi_types (name, user_id) VALUES
-- ('Salmão', 'USER_ID'),
-- ('Atum', 'USER_ID'),
-- ('Pargo', 'USER_ID'),
-- ('Lula', 'USER_ID'),
-- ('Camarão', 'USER_ID'),
-- ('Polvo', 'USER_ID'),
-- ('Robalo', 'USER_ID'),
-- ('Dourada', 'USER_ID'),
-- ('Enguia', 'USER_ID'),
-- ('Ovas', 'USER_ID');

-- =====================================================
-- FUNÇÕES ÚTEIS
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
-- VIEWS ÚTEIS
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
-- TRIGGERS PARA UPDATED_AT
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
