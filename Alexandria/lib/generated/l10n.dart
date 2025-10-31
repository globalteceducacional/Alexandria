// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome back,`
  String get loginPage_WELCOME {
    return Intl.message(
      'Bem-vindo de Volta,',
      name: 'loginPage_WELCOME',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get loginPage_WELCOMES {
    return Intl.message(
      'Bem-vindo',
      name: 'loginPage_WELCOMES',
      desc: '',
      args: [],
    );
  }

  /// `Create New Account`
  String get loginPage_Create_New_Account {
    return Intl.message(
      'Criar nova conta',
      name: 'loginPage_Create_New_Account',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email`
  String get loginPage_emailHint {
    return Intl.message(
      'Entreda de e-mail',
      name: 'loginPage_emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Signup to enjoy the App`
  String get loginPage_Signup_to_enjoy_the_App {
    return Intl.message(
      'Faça o login para aproveitar o App',
      name: 'loginPage_Signup_to_enjoy_the_App',
      desc: '',
      args: [],
    );
  }

  /// `Login to continue`
  String get loginPage_login_to_continue {
    return Intl.message(
      'Logue para continuar',
      name: 'loginPage_login_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get loginPage_Already_Have_An_Account {
    return Intl.message(
      'Já tem uma conta?',
      name: 'loginPage_Already_Have_An_Account',
      desc: '',
      args: [],
    );
  }

  /// `Enter Password`
  String get loginPage_passwordHint {
    return Intl.message(
      'Digite a senha',
      name: 'loginPage_passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Trouble in login? `
  String get loginPage_TROUBLE_IN_LOGIN {
    return Intl.message(
      'Problemas no login? ',
      name: 'loginPage_TROUBLE_IN_LOGIN',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Email`
  String get loginPage_forgot_ENTER_YOUR_EMAIL {
    return Intl.message(
      'Digite seu e-mail',
      name: 'loginPage_forgot_ENTER_YOUR_EMAIL',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get loginPage_forgot_APPLY_button {
    return Intl.message(
      'Aplicar',
      name: 'loginPage_forgot_APPLY_button',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get loginPage_FORGOT_PASSWORD {
    return Intl.message(
      'Esqueceu sua senha',
      name: 'loginPage_FORGOT_PASSWORD',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginPage_LOGIN {
    return Intl.message(
      'Login',
      name: 'loginPage_LOGIN',
      desc: '',
      args: [],
    );
  }

  /// `SignUp`
  String get loginPage_SIGNUP {
    return Intl.message(
      'SignUp',
      name: 'loginPage_SIGNUP',
      desc: '',
      args: [],
    );
  }

  /// `Logged In Successfully`
  String get loginPage_LOGIN_SUCCESS_toast {
    return Intl.message(
      'Conectado com sucesso',
      name: 'loginPage_LOGIN_SUCCESS_toast',
      desc: '',
      args: [],
    );
  }

  /// `Register with `
  String get loginPage_REGISTER_WITH {
    return Intl.message(
      'Registre-se com ',
      name: 'loginPage_REGISTER_WITH',
      desc: '',
      args: [],
    );
  }

  /// `Social Media`
  String get loginPage_SOCIAL_MEDIA {
    return Intl.message(
      'Social Media',
      name: 'loginPage_SOCIAL_MEDIA',
      desc: '',
      args: [],
    );
  }

  /// `Problem in Signin`
  String get loginPage_PROBLEM_IN_SIGNIN_toast {
    return Intl.message(
      'Problema no login',
      name: 'loginPage_PROBLEM_IN_SIGNIN_toast',
      desc: '',
      args: [],
    );
  }

  /// `Want to skip for now..`
  String get loginPage_skip_login {
    return Intl.message(
      'Quer pular por enquanto..',
      name: 'loginPage_skip_login',
      desc: '',
      args: [],
    );
  }

  /// `Enter Name`
  String get loginPage_nameHint {
    return Intl.message(
      'Insira o nome',
      name: 'loginPage_nameHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter Phonenumber`
  String get loginPage_phoneHint {
    return Intl.message(
      'Insira o número de telefone',
      name: 'loginPage_phoneHint',
      desc: '',
      args: [],
    );
  }

  /// `SKIP`
  String get loginPage_SKIP {
    return Intl.message(
      'Pular',
      name: 'loginPage_SKIP',
      desc: '',
      args: [],
    );
  }

  /// `Greetings`
  String get home_GREETINGS {
    return Intl.message(
      'Saudações',
      name: 'home_GREETINGS',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get home_Hello {
    return Intl.message(
      'olá',
      name: 'home_Hello',
      desc: '',
      args: [],
    );
  }

  /// `No Book Url Found`
  String get no_book_url_found {
    return Intl.message(
      'Nenhum URL do livro encontrado',
      name: 'no_book_url_found',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get home_USER {
    return Intl.message(
      'Usuario',
      name: 'home_USER',
      desc: '',
      args: [],
    );
  }

  /// `Search best books here`
  String get home_search_bar {
    return Intl.message(
      'pesquise os melhores livros aqui',
      name: 'home_search_bar',
      desc: '',
      args: [],
    );
  }

  /// `Select `
  String get home_SELECT {
    return Intl.message(
      'Selecione ',
      name: 'home_SELECT',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get home_SeeAll {
    return Intl.message(
      'Ver tudo',
      name: 'home_SeeAll',
      desc: '',
      args: [],
    );
  }

  /// `No Favorite Available`
  String get no_favorite {
    return Intl.message(
      'Nenhum favorito disponível',
      name: 'no_favorite',
      desc: '',
      args: [],
    );
  }

  /// `No Download Available`
  String get no_download {
    return Intl.message(
      'Nenhum download disponível',
      name: 'no_download',
      desc: '',
      args: [],
    );
  }

  /// `Categoria`
  String get home_CATEGORY {
    return Intl.message(
      'Category',
      name: 'home_CATEGORY',
      desc: '',
      args: [],
    );
  }

  /// `Livro`
  String get home_category_BOOK {
    return Intl.message(
      'Book',
      name: 'home_category_BOOK',
      desc: '',
      args: [],
    );
  }

  /// `Error check your Internet!!!`
  String get home_category_internet_error {
    return Intl.message(
      'Erro, verifique sua Internet!!!',
      name: 'home_category_internet_error',
      desc: '',
      args: [],
    );
  }

  /// `Best of the `
  String get home_BEST_OF_THE {
    return Intl.message(
      'Melhor do',
      name: 'home_BEST_OF_THE',
      desc: '',
      args: [],
    );
  }

  /// `Dia`
  String get home_DAY {
    return Intl.message(
      'Day',
      name: 'home_DAY',
      desc: '',
      args: [],
    );
  }

  /// `Continue `
  String get home_CONTINUE {
    return Intl.message(
      'Continuar ',
      name: 'home_CONTINUE',
      desc: '',
      args: [],
    );
  }

  /// `Reading`
  String get home_READING {
    return Intl.message(
      'Leitura',
      name: 'home_READING',
      desc: '',
      args: [],
    );
  }

  /// `No Book Has Been Selected`
  String get home_continue_NO_BOOK_toast {
    return Intl.message(
      'Nenhum livro foi selecionado',
      name: 'home_continue_NO_BOOK_toast',
      desc: '',
      args: [],
    );
  }

  /// `Crushing & Influence`
  String get home_continue_CRUSHING_INFLUENCE {
    return Intl.message(
      'Esmagamento e influência',
      name: 'home_continue_CRUSHING_INFLUENCE',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get explore_EXPLORE {
    return Intl.message(
      'Explorar',
      name: 'explore_EXPLORE',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get explore_LATEST {
    return Intl.message(
      'Adicionados recentemente'
      ' ',
      name: 'explore_LATEST',
      desc: '',
      args: [],
    );
  }

  /// `books`
  String get explore_BOOKS {
    return Intl.message(
      '',
      name: 'explore_BOOKS',
      desc: '',
      args: [],
    );
  }

  /// `Searched by`
  String get explore_SEARCHED_BY {
    return Intl.message(
      'Pesquisado por',
      name: 'explore_SEARCHED_BY',
      desc: '',
      args: [],
    );
  }

  /// `Autores`
  String get explore_AUTHOR {
    return Intl.message(
      'Authors',
      name: 'explore_AUTHOR',
      desc: '',
      args: [],
    );
  }

  /// `Todos disponíveis`
  String get explore_ALL_AVAILABLE {
    return Intl.message(
      'All Available',
      name: 'explore_ALL_AVAILABLE',
      desc: '',
      args: [],
    );
  }

  /// `Livros`
  String get explore_BOOKS_available {
    return Intl.message(
      'Livros',
      name: 'explore_BOOKS_available',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting_SETTING {
    return Intl.message(
      'Contexto',
      name: 'setting_SETTING',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting_SETTINGTITLE {
    return Intl.message(
      'Contexto',
      name: 'setting_SETTINGTITLE',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get setting_PROFILE {
    return Intl.message(
      'Perfil',
      name: 'setting_PROFILE',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get setting_NORTIFICATION {
    return Intl.message(
      'Notificação',
      name: 'setting_NORTIFICATION',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get setting_DOWNLOAD {
    return Intl.message(
      'Download',
      name: 'setting_DOWNLOAD',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get setting_SHARE {
    return Intl.message(
      'Compartilhar',
      name: 'setting_SHARE',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get setting_PRIVACY_POLICY {
    return Intl.message(
      'política de Privacidade',
      name: 'setting_PRIVACY_POLICY',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get setting_LOGOUT {
    return Intl.message(
      'Sair',
      name: 'setting_LOGOUT',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get setting_DELETE {
    return Intl.message(
      'Deletar conta',
      name: 'setting_DELETE',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get setting_light_theme {
    return Intl.message(
      'Tema claro',
      name: 'setting_light_theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get setting_dark_theme {
    return Intl.message(
      'Tema escuro',
      name: 'setting_dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get setting_LANGUAGE {
    return Intl.message(
      'Linguaguem',
      name: 'setting_LANGUAGE',
      desc: '',
      args: [],
    );
  }

  /// `Example Share`
  String get setting_share_SHARE {
    return Intl.message(
      'Exemplo de compartilhamento',
      name: 'setting_share_SHARE',
      desc: '',
      args: [],
    );
  }

  /// `Exemplo de texto de compartilhamento`
  String get setting_share_SHARE_TEXT {
    return Intl.message(
      'Example Share Text',
      name: 'setting_share_SHARE_TEXT',
      desc: '',
      args: [],
    );
  }

  /// `Example Chooser Title`
  String get setting_share_TITLE {
    return Intl.message(
      'Exemplo de título do seletor',
      name: 'setting_share_TITLE',
      desc: '',
      args: [],
    );
  }

  /// `This is Ignored`
  String get setting_privacy_IGNORED {
    return Intl.message(
      'Isso é ignorado',
      name: 'setting_privacy_IGNORED',
      desc: '',
      args: [],
    );
  }

  /// `This is also Ignored`
  String get setting_privacy_ALSO_IGNORED {
    return Intl.message(
      'Isso é ignorado',
      name: 'setting_privacy_ALSO_IGNORED',
      desc: '',
      args: [],
    );
  }

  /// `Are you Sure ?`
  String get setting_logout_ARE_YOU_SURE {
    return Intl.message(
      'Tem certeza ?',
      name: 'setting_logout_ARE_YOU_SURE',
      desc: '',
      args: [],
    );
  }

  /// `Logout with Ebook`
  String get setting_logout_LOGOUT_WITH_EBOOK {
    return Intl.message(
      '',
      name: 'setting_logout_LOGOUT_WITH_EBOOK',
      desc: '',
      args: [],
    );
  }

  /// `Delete your account`
  String get setting_logout_DELETE_WITH_EBOOK {
    return Intl.message(
      'Deletar sua conta',
      name: 'setting_logout_DELETE_WITH_EBOOK',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get setting_logout_CANCEL {
    return Intl.message(
      'Cancelar',
      name: 'setting_logout_CANCEL',
      desc: '',
      args: [],
    );
  }

  /// `Failed to Logout`
  String get setting_logout_FAILED_TO_LOGOUT_toast {
    return Intl.message(
      'Falha ao sair',
      name: 'setting_logout_FAILED_TO_LOGOUT_toast',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category_CATEGORY {
    return Intl.message(
      'Categoria',
      name: 'category_CATEGORY',
      desc: '',
      args: [],
    );
  }

  /// `Descrição`
  String get detail_screen_DESCRIPTION {
    return Intl.message(
      'Descrição',
      name: 'detail_screen_DESCRIPTION',
      desc: '',
      args: [],
    );
  }

  /// `You might also `
  String get detail_screen_YOU_MIGHT_ALSO {
    return Intl.message(
      'Você também pode ',
      name: 'detail_screen_YOU_MIGHT_ALSO',
      desc: '',
      args: [],
    );
  }

  /// `Like….`
  String get detail_screen_LIKE {
    return Intl.message(
      'como...',
      name: 'detail_screen_LIKE',
      desc: '',
      args: [],
    );
  }

  /// `Like`
  String get detail_screen_LIKES {
    return Intl.message(
      'Como',
      name: 'detail_screen_LIKES',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get detail_screen_READ {
    return Intl.message(
      'Ler',
      name: 'detail_screen_READ',
      desc: '',
      args: [],
    );
  }

  /// `Book Add In Favourite`
  String get detail_screen_ADD_FAVOURITE {
    return Intl.message(
      'Adicionar livro aos favoritos',
      name: 'detail_screen_ADD_FAVOURITE',
      desc: '',
      args: [],
    );
  }

  /// `No Books Found`
  String get search_NO_BOOKS_FOUND {
    return Intl.message(
      'nenhum livro encontrado',
      name: 'search_NO_BOOKS_FOUND',
      desc: '',
      args: [],
    );
  }

  /// `Start Downloading`
  String get view_START_DOWNLOADING_toast {
    return Intl.message(
      'Comece a baixar',
      name: 'view_START_DOWNLOADING_toast',
      desc: '',
      args: [],
    );
  }

  /// `Permissão do usuário negada`
  String get view_PERMISSION_DENIED_toast {
    return Intl.message(
      'User permission denied',
      name: 'view_PERMISSION_DENIED_toast',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get view_LOADING {
    return Intl.message(
      'Carregando',
      name: 'view_LOADING',
      desc: '',
      args: [],
    );
  }

  /// `New York Time Best For 11th March 2020`
  String get beswtofday_TIME {
    return Intl.message(
      'Melhor horário de Nova York para 11 de março de 2020',
      name: 'beswtofday_TIME',
      desc: '',
      args: [],
    );
  }

  /// `How To Win \nFriends &  Influence`
  String get beswtofday_HOW_TO_WIN {
    return Intl.message(
      'Como ganhar \nAmigos e influência',
      name: 'beswtofday_HOW_TO_WIN',
      desc: '',
      args: [],
    );
  }

  /// `Gary Venchuk`
  String get beswtofday_GARY_VENCHUK {
    return Intl.message(
      'Gary Venchuk',
      name: 'beswtofday_GARY_VENCHUK',
      desc: '',
      args: [],
    );
  }

  /// `When the earth was flat and everyone wanted to win the game of the best and people….`
  String get beswtofday_WHEN_EARTH_WAS_FLAT {
    return Intl.message(
      'Quando a terra era plana e todos queriam ganhar o jogo dos melhores e das pessoas….',
      name: 'beswtofday_WHEN_EARTH_WAS_FLAT',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get reading_card_list_DETAILS {
    return Intl.message(
      'Detalhes',
      name: 'reading_card_list_DETAILS',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get details_screen_COMMENTS {
    return Intl.message(
      'Comentários',
      name: 'details_screen_COMMENTS',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get details_screen_LOADING {
    return Intl.message(
      'Carregando',
      name: 'details_screen_LOADING',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Value`
  String get details_screen_comments_textField_validation {
    return Intl.message(
      'Por favor insira o valor',
      name: 'details_screen_comments_textField_validation',
      desc: '',
      args: [],
    );
  }

  /// `Add a public comment`
  String get details_screen_comments_textField_hint_text {
    return Intl.message(
      'Adicione um comentário público',
      name: 'details_screen_comments_textField_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `No Comments Found`
  String get details_screen_comments_NO_COMMENTS_FOUND {
    return Intl.message(
      'Nenhum comentário encontrado',
      name: 'details_screen_comments_NO_COMMENTS_FOUND',
      desc: '',
      args: [],
    );
  }

  /// `Show more`
  String get read_more_text_SHOW_MORE {
    return Intl.message(
      'Mostre mais',
      name: 'read_more_text_SHOW_MORE',
      desc: '',
      args: [],
    );
  }

  /// `Show less`
  String get read_more_text_SHOW_LESS {
    return Intl.message(
      'Mostre menos',
      name: 'read_more_text_SHOW_LESS',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Book`
  String get detail_screen_PURCHASE_BOOK {
    return Intl.message(
      'Comprar livro',
      name: 'detail_screen_PURCHASE_BOOK',
      desc: '',
      args: [],
    );
  }

  /// `User Profile`
  String get profile_USER_PROFILE {
    return Intl.message(
      'Perfil de usuário',
      name: 'profile_USER_PROFILE',
      desc: '',
      args: [],
    );
  }

  /// `Name :`
  String get profile_NAME {
    return Intl.message(
      'Nome :',
      name: 'profile_NAME',
      desc: '',
      args: [],
    );
  }

  /// `Email :`
  String get profile_EMAIL {
    return Intl.message(
      'Email :',
      name: 'profile_EMAIL',
      desc: '',
      args: [],
    );
  }

  /// `Mobile :`
  String get profile_MOBILE {
    return Intl.message(
      'Mobile :',
      name: 'profile_MOBILE',
      desc: '',
      args: [],
    );
  }

  /// `Update Your Name`
  String get profile_UPDATE_YOUR_NAME {
    return Intl.message(
      'Atualize seu nome',
      name: 'profile_UPDATE_YOUR_NAME',
      desc: '',
      args: [],
    );
  }

  /// `Update profile picture`
  String get profile_UPDATE_PROFILE_PICTURE {
    return Intl.message(
      'Atualizar foto do perfil',
      name: 'profile_UPDATE_PROFILE_PICTURE',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get profile_CAMERA {
    return Intl.message(
      'Camera',
      name: 'profile_CAMERA',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get profile_GALLERY {
    return Intl.message(
      'Galeria',
      name: 'profile_GALLERY',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get profile_SAVE {
    return Intl.message(
      'Salvar',
      name: 'profile_SAVE',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get cat_Author {
    return Intl.message(
      'Autor(a)',
      name: 'cat_Author',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully rated`
  String get detail_screen_YOU_HAVE_SUCCESSFULLY_RATED {
    return Intl.message(
      'Você avaliou com sucesso',
      name: 'detail_screen_YOU_HAVE_SUCCESSFULLY_RATED',
      desc: '',
      args: [],
    );
  }

  /// `You have already rated`
  String get detail_screen_YOU_HAVE_ALREADY_RATED {
    return Intl.message(
      'Você já avaliou',
      name: 'detail_screen_YOU_HAVE_ALREADY_RATED',
      desc: '',
      args: [],
    );
  }

  /// `Login First`
  String get detail_screen_LOGIN_FIRST {
    return Intl.message(
      'Faça login primeiro',
      name: 'detail_screen_LOGIN_FIRST',
      desc: '',
      args: [],
    );
  }

  /// `Rate a book`
  String get detail_screen_RATE_A_BOOK {
    return Intl.message(
      'Avalie um livro',
      name: 'detail_screen_RATE_A_BOOK',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get detail_screen_SUBMIT {
    return Intl.message(
      'Enviar',
      name: 'detail_screen_SUBMIT',
      desc: '',
      args: [],
    );
  }

  /// `Favourite`
  String get setting_screen_FAVOURITE {
    return Intl.message(
      'Favorita',
      name: 'setting_screen_FAVOURITE',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar', countryCode: 'SA'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'hi', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
      Locale.fromSubtags(languageCode: 'kn', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ko', countryCode: 'KR'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'ta', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'te', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'th', countryCode: 'TH'),
      Locale.fromSubtags(languageCode: 'ur', countryCode: 'PK'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
