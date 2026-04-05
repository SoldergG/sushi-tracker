# Configuração do Supabase

Para que a aplicação funcione corretamente, você precisa configurar o Supabase:

## 1. Criar Projeto Supabase

1. Acesse https://supabase.com
2. Crie uma conta ou faça login
3. Crie um novo projeto
4. Anote o URL e a API Key anônima

## 2. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com:

```
EXPO_PUBLIC_SUPABASE_URL=seu_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=sua_supabase_anon_key
```

## 3. SQL para Criar Tabelas

Execute o seguinte SQL no editor SQL do Supabase:

```sql
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

-- Trigger para criar perfil automaticamente
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

-- RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sushi_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_meals ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own sessions" ON sushi_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON sushi_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON sushi_sessions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions" ON sushi_sessions
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own sushi types" ON sushi_types
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sushi types" ON sushi_types
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sushi types" ON sushi_types
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sushi types" ON sushi_types
  FOR DELETE USING (auth.uid() = user_id);
```

## 4. Configurar Auth

No painel do Supabase:
1. Vá para Authentication > Settings
2. Configure o site URL e redirect URLs para desenvolvimento
3. Ative o provedor de email

## 5. Testar

Após configurar, reinicie a aplicação e teste o registro e login.
