# Sistema de Orientação por Tipo de Dispositivo

## 📱 Visão Geral

O aplicativo agora detecta automaticamente o tipo de dispositivo e ajusta as orientações permitidas:

- **📱 Celulares**: Apenas modo retrato (bloqueia landscape)
- **📱 Tablets**: Permite todas as orientações (retrato e paisagem)

## 🔧 Implementação

### 1. Detecção de Dispositivo (`main.dart`)

A função `_checkIfTablet()` detecta automaticamente se o dispositivo é um tablet:

**Para Android:**
- Verifica se o nome do modelo contém "tablet" ou "pad"
- Verifica o campo `device` e `product`

**Para iOS:**
- Verifica se o modelo contém "ipad"
- Verifica o `utsname.machine`

### 2. Configuração de Orientação

```dart
if (isTablet) {
  // Tablet: todas as orientações
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
} else {
  // Celular: apenas retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
```

### 3. Helper Function (`consttants.dart`)

Nova função `isDeviceTablet()` que pode ser usada em qualquer tela:

```dart
bool isDeviceTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600 || isTablet;
}
```

## 🎯 Como Usar

### Em Qualquer Tela

Se você quiser verificar se está em um tablet em qualquer widget:

```dart
bool isTablet = isDeviceTablet(context);

if (isTablet) {
  // Usar layout otimizado para tablet
} else {
  // Usar layout para celular
}
```

### Orientação Dinâmica

Para forçar uma orientação específica em uma tela:

```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

Depois, quando sair da tela:

```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```

## 📊 Variáveis Globais

- `bool isTablet`: Indica se o dispositivo é um tablet (definido em `main.dart`)
- `bool isAndroidVersionUp13`: Indica se o Android é versão 13 ou superior

## ✅ Benefícios

1. **UX Melhor**: Celulares não podem girar para landscape (não gera layout quebrado)
2. **Tablets**: Podem usar todas as orientações normalmente
3. **Detecção Automática**: Funciona em Android e iOS
4. **Código Limpo**: Variável global e função helper para uso em qualquer lugar

## 🧪 Testando

Para testar a detecção:

1. Em um emulador/device real: O log mostrará "Dispositivo detectado como: Tablet" ou "Celular"
2. Verifique no console: `dispose()` será chamado
3. Tente girar em um celular: não deve rotacionar
4. Tente girar em um tablet: deve rotacionar normalmente

## 🔍 Debug

Os logs mostram:
- `Dispositivo detectado como: Tablet` ou `Celular`
- Em caso de erro: `Erro ao detectar tipo de dispositivo: [erro]`

