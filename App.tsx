import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { AppProvider } from './src/context/AppContext';
import { WelcomeScreen } from './src/screens/WelcomeScreen';
import { LoginScreen } from './src/screens/NewLoginScreen';
import { SignUpScreen } from './src/screens/NewSignUpScreen';
import { HomeScreen } from './src/screens/HomeScreen';
import { SushiSessionScreen } from './src/screens/SushiSessionScreen';
import { KeepAwakeScreen } from './src/screens/KeepAwakeScreen';
import { SushiListScreen } from './src/screens/SushiListScreen';
import { useApp } from './src/context/AppContext';

type ScreenType = 'welcome' | 'login' | 'signup' | 'home' | 'session' | 'keepAwake' | 'sushiList';

function AppContent() {
  const { user, loading } = useApp();
  const [currentScreen, setCurrentScreen] = useState<ScreenType>('welcome');

  if (loading) {
    return null; // ou um componente de loading
  }

  if (!user) {
    if (currentScreen === 'login') {
      return (
        <LoginScreen 
          onSignUp={() => setCurrentScreen('signup')}
          onBack={() => setCurrentScreen('welcome')}
        />
      );
    }
    
    if (currentScreen === 'signup') {
      return (
        <SignUpScreen 
          onBackToLogin={() => setCurrentScreen('login')}
          onBack={() => setCurrentScreen('welcome')}
        />
      );
    }
    
    return (
      <WelcomeScreen 
        onLogin={() => setCurrentScreen('login')}
        onSignUp={() => setCurrentScreen('signup')}
      />
    );
  }

  const renderScreen = () => {
    switch (currentScreen) {
      case 'session':
        return (
          <SushiSessionScreen 
            onBack={() => setCurrentScreen('home')} 
          />
        );
      case 'keepAwake':
        return (
          <KeepAwakeScreen 
            onBack={() => setCurrentScreen('home')} 
          />
        );
      case 'sushiList':
        return (
          <SushiListScreen 
            onBack={() => setCurrentScreen('home')} 
          />
        );
      default:
        return (
          <HomeScreen 
            onStartSession={() => setCurrentScreen('session')}
            onViewStats={() => setCurrentScreen('home')} // TODO: Implementar stats screen
            onViewCalendar={() => setCurrentScreen('home')} // TODO: Implementar calendar screen
            onKeepAwake={() => setCurrentScreen('keepAwake')}
            onSushiList={() => setCurrentScreen('sushiList')}
          />
        );
    }
  };

  return (
    <>
      <StatusBar style="light" />
      {renderScreen()}
    </>
  );
}

export default function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}
