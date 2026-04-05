# 🍎 Configuração Apple Sign In - Guia Completo

## 📋 Pré-requisitos

1. **Conta Apple Developer** (paga - $99/ano)
2. **App ID criado** no Apple Developer Portal
3. **Team ID** da tua conta Apple

## 🔧 Passo 1: Apple Developer Portal

1. Vai para https://developer.apple.com
2. Clica em "Certificates, Identifiers & Profiles"
3. Vai para "Identifiers" e clica em "+"
4. Escolhe "App IDs"
5. Preenche:
   - **Description**: "Sushi Tracker"
   - **Bundle ID**: "com.teunome.sushitracker" (único)
   - Capabilities: Ativa **"Sign In with Apple"**
6. Clica em "Continue" e "Register"

## 🔧 Passo 2: Configurar Service ID

1. Vai para "Identifiers" e clica em "+"
2. Escolhe "Services ID"
3. Preenche:
   - **Description**: "Sushi Tracker Web"
   - **Identifier**: "com.teunome.sushitracker.web"
4. Regista e depois edita
5. Ativa **"Sign In with Apple"**
6. Configura:
   - **Return URLs**: 
     - Development: `https://pztktyckaiswbstlaxcx.supabase.co/auth/v1/callback`
     - Production: `https://pztktyckaiswbstlaxcx.supabase.co/auth/v1/callback`

## 🔧 Passo 3: Atualizar app.json

Substitui `YOUR_APPLE_TEAM_ID` no ficheiro `app.json`:

```json
[
  "@invertase/react-native-apple-authentication",
  {
    "appleTeamId": "TEU_TEAM_ID_AQUI"
  }
]
```

## 🔧 Passo 4: Configurar Supabase

1. Vai ao painel Supabase
2. Authentication > Providers > Apple
3. Ativa o provider Apple
4. Preenche:
   - **Client ID**: O Service ID que criaste
   - **Team ID**: O teu Apple Team ID
   - **Key ID**: Cria uma chave em "Certificates, Identifiers & Profiles > Keys"
   - **Private Key**: Faz download do ficheiro .p8

## 🔧 Passo 5: Desativar Verificação de Email

No painel Supabase:
1. Authentication > Settings
2. Desativa **"Enable email confirmations"**
3. Site URL: `http://localhost:8081`
4. Redirect URLs: `http://localhost:8081/**`

## 🔧 Passo 6: Executar SQL

Executa o ficheiro `supabase-setup-completo.sql` no SQL Editor do Supabase.

## 🧪 Testar

1. Reinicia a app:
   ```bash
   npx expo start
   ```

2. Testa o Apple Sign In:
   - No iOS Simulator: Funciona com conta Apple de teste
   - No dispositivo real: Funciona com tua conta Apple

## ⚠️ Notas Importantes

- **iOS Simulator**: Precisa de configurar conta Apple no Settings
- **Dispositivo Real**: Funciona com Touch ID/Face ID
- **Bundle ID**: Deve ser único na App Store
- **Team ID**: Encontra-se em Apple Developer > Membership

## 🚀 Deploy para Produção

Para deploy na App Store:
1. Configura Bundle ID final
2. Gera certificados de produção
3. Ativa Apple Sign In em produção
4. Atualiza URLs no Supabase

---

**Pronto! O Apple Sign In está totalmente configurado! 🍎**
