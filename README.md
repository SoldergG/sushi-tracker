# 🍣 Sushi Tracker

Uma aplicação iOS para tracking de rodízio de sushi com funcionalidades sociais e estatísticas detalhadas.

## 🚀 Funcionalidades

### 📱 Autenticação
- Login e registro de usuários
- Perfil personalizado
- Sessão segura com Supabase

### 🍱 Tracking de Sushi
- Contador de peças de sushi em tempo real
- Tipos diferentes de sushi (salmão, atum, pargo, etc.)
- Sessões com tempo e estatísticas
- Recorde pessoal de peças

### 📊 Estatísticas
- Total de sessões
- Total de peças consumidas
- Recorde pessoal
- Média de peças por sessão
- Tipo de sushi favorito

### 👥 Funcionalidades Sociais
- Partilha de estatísticas com amigos
- Calendário de refeições compartilhadas
- Adicionar amigos

### ⚡ Modo Contínuo
- Tela nunca se apaga durante contagem
- Botão único para adicionar peças
- Contador infinito

### 📝 Lista de Sushi
- Gerenciar tipos de sushi
- Adicionar/remover tipos personalizados
- Contadores individuais por tipo

## 🛠️ Tecnologias

- **React Native com Expo** - Framework mobile
- **TypeScript** - Tipagem segura
- **Supabase** - Backend e autenticação
- **React Navigation** - Navegação
- **React Native Keep Awake** - Manter tela ativa
- **React Native Calendars** - Calendário de refeições

## 📋 Pré-requisitos

- Node.js 18+
- Expo CLI
- Conta Supabase
- iOS Simulator ou dispositivo iOS

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone <repository-url>
cd sushi-tracker
```

2. Instale as dependências:
```bash
npm install
```

3. Configure o Supabase seguindo o guia [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)

4. Crie o arquivo `.env`:
```bash
cp .env.example .env
# Edite .env com suas credenciais do Supabase
```

5. Inicie a aplicação:
```bash
npm start
```

6. Execute no iOS:
```bash
npm run ios
```

## 📱 Uso

### Login e Registro
1. Abra a aplicação
2. Faça registro com email e senha
3. Confirme o email (se necessário)
4. Faça login

### Contar Peças de Sushi
1. Na tela inicial, toque em "Nova Sessão"
2. Toque nos botões "+" para adicionar peças
3. Use "-" para remover se necessário
4. Termine a sessão para salvar estatísticas

### Modo Contínuo
1. Na tela inicial, toque em "Modo Contínuo"
2. A tela permanecerá ativa
3. Toque em "+1 Peça" para contar
4. Ideal para rodízios intensos

### Gerenciar Tipos de Sushi
1. Acesse "Lista de Sushi"
2. Adicione novos tipos personalizados
3. Apague tipos não utilizados
4. Reinicie contadores quando necessário

## 🏗️ Estrutura do Projeto

```
src/
├── components/     # Componentes reutilizáveis
├── context/       # Contexto da aplicação
├── screens/       # Telas da aplicação
├── services/      # Serviços (Supabase)
├── types/         # Tipos TypeScript
├── utils/         # Utilitários
└── hooks/         # Hooks personalizados
```

## 🔧 Configuração

### Variáveis de Ambiente
- `EXPO_PUBLIC_SUPABASE_URL` - URL do projeto Supabase
- `EXPO_PUBLIC_SUPABASE_ANON_KEY` - Chave anônima do Supabase

### Plugins Expo
- `expo-secure-store` - Armazenamento seguro
- `react-native-keep-awake` - Manter tela ativa

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.

## 🐛 Issues

Encontrou um bug? Por favor, abra uma issue descrevendo:
- O problema encontrado
- Passos para reproduzir
- Comportamento esperado
- Screenshots se aplicável

## 📞 Suporte

Para suporte, entre em contato através das issues do GitHub.

---

**Desenvolvido com ❤️ para amantes de sushi!**
