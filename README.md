# 📚 Alexandria - E-Book Reader App

Um aplicativo Flutter moderno e completo para leitura de e-books, desenvolvido com as melhores práticas de desenvolvimento mobile.

## 🚀 Funcionalidades

### 📖 Sistema de Leitura
- **Visualização de PDF**: Leitor integrado para arquivos PDF
- **Categorização**: Livros organizados por categorias
- **Sistema de Favoritos**: Marcar livros favoritos
- **Downloads Offline**: Leitura sem conexão com internet
- **Avaliações**: Sistema de rating por estrelas

### 👤 Autenticação e Perfil
- **Login/Registro**: Sistema completo de autenticação
- **Login Social**: Google, Facebook, Apple Sign-In
- **Modo Convidado**: Acesso sem registro
- **Perfil Personalizado**: Foto e informações do usuário

### 🎨 Interface Moderna
- **Tema Escuro/Claro**: Suporte completo a temas
- **Design Responsivo**: Adaptação a diferentes telas
- **Animações Suaves**: Transições elegantes
- **15 Idiomas**: Internacionalização completa

### 🔍 Busca e Navegação
- **Busca Inteligente**: Pesquisa por título e autor
- **Navegação Intuitiva**: 3 abas principais (Home, Explore, Settings)
- **Deep Linking**: Links diretos para livros específicos

## 🛠️ Tecnologias Utilizadas

### Core Framework
- **Flutter 3.27.4** - Framework de desenvolvimento
- **Dart** - Linguagem de programação

### State Management
- **GetX 4.6.6** - Gerenciamento de estado reativo
- **Provider 6.1.1** - Injeção de dependências

### Backend & APIs
- **Firebase** - Autenticação e links dinâmicos
- **HTTP** - Comunicação com API REST
- **SQLite** - Armazenamento local

### UI/UX
- **Curved Navigation Bar** - Navegação elegante
- **Shimmer** - Efeitos de loading
- **Glass Kit** - Efeitos de vidro
- **Cached Network Image** - Cache de imagens

### Funcionalidades Específicas
- **Syncfusion PDF Viewer** - Leitor de PDF
- **Google Mobile Ads** - Sistema de anúncios
- **Share Plus** - Compartilhamento
- **Permission Handler** - Gerenciamento de permissões

## 📱 Screenshots

### Tela Inicial
![Home Screen](assets/images/main.jpg)

### Categorias
- Lista horizontal de categorias
- Imagens otimizadas com cache
- Gradientes elegantes

### Detalhes do Livro
- Informações completas
- Sistema de avaliação
- Botões de ação (Download, Favorito, Compartilhar)

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.27.4 ou superior
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android/iOS ou emulador

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/vocsyinfotech/CC-FlutterEbook-CC-code.git
cd CC-FlutterEbook-CC-code
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Firebase** (opcional)
- Crie um projeto no Firebase Console
- Adicione os arquivos de configuração:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

4. **Execute o projeto**
```bash
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
├── consttants.dart          # Constantes globais
├── splashScreen.dart         # Tela de splash
├── screens/                  # Telas principais
│   ├── home.dart            # Tela inicial
│   ├── explore.dart         # Tela de exploração
│   ├── setting.dart         # Configurações
│   └── bottom_navigation.dart
├── model/                   # Modelos de dados
│   ├── allcategory.dart
│   ├── besthomebook.dart
│   └── Profile.dart
├── service/                 # Serviços de API
│   └── httpservice.dart
├── widgets/                 # Widgets reutilizáveis
└── generated/               # Arquivos gerados
    └── l10n.dart           # Internacionalização
```

## 🔧 Configuração

### Variáveis de Ambiente
```dart
// lib/consttants.dart
const apiLink = "https://ebook.alenxandriaglobaltec.com/";
```

### Configuração de Idiomas
O app suporta 15 idiomas:
- Português (Brasil)
- Inglês
- Espanhol
- Francês
- Alemão
- E mais...

## 📊 API Endpoints

### Principais Endpoints
- `GET /api.php?method_name=home` - Dados da tela inicial
- `GET /api.php?method_name=cat_list` - Lista de categorias
- `GET /api.php?method_name=home_section` - Seções da home
- `POST /user_login_api.php` - Autenticação de usuário
- `GET /user_profile_api.php` - Perfil do usuário

## 🎯 Funcionalidades Técnicas

### Responsividade
- Adaptação automática a orientação portrait/landscape
- Dimensões responsivas com `flutter_screenutil`
- Breakpoints para diferentes tamanhos de tela

### Performance
- Cache de imagens com `cached_network_image`
- Lazy loading de listas
- Otimização de memória

### Segurança
- Validação de entrada de dadosW
- Sanitização de HTML
- Gerenciamento seguro de tokens
