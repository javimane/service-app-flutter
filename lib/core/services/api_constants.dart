class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String session = '/auth/session';

  // Professionals
  static const String professionals = '/professionals';
  static const String professionalMe = '/professionals/me';
  static const String professionalRanking = '/professional-ranking';

  // Categories
  static const String categoriesServices = '/categories/services';
  static const String categoriesProducts = '/categories/products';

  // Services
  static const String services = '/services';

  // Products
  static const String products = '/products';

  // Reviews
  static const String reviews = '/reviews';

  // Users
  static const String userFavorites = '/users/me/favorites';
  static const String deviceTokens = '/users/me/device-tokens';

  // Subscription
  static const String subscriptionPrice = '/subscription-price';

  // Companies
  static const String companies = '/companies';

  // Proposals
  static const String proposals = '/professional-proposals';
  // Additional routes discovered in backend controllers
  static const String addresses = '/addresses';
  static const String arca = '/arca';
  static const String professionalAvailability = '/professional/availability';
  static const String professionalProposals = '/professional-proposals';
  static const String professionalPromotions = '/professional-promotions';
  static const String professionalImages = '/professional-images';
  static const String professionalVideos = '/professional-videos';
  static const String professionalReels = '/professional-reels';
  static const String provinces = '/provinces';
  static const String provinceDepartments = '/province-departments';
  static const String profiles = '/profiles';
  static const String communications = '/communications';
  static const String professionalDetails = '/professional-details';
  static const String authReset = '/auth/reset-password';
  static const String users = '/users';
  static const String banks = '/banks';
  static const String bankPromotions = '/bank-promotions';
  static const String storage = '/storage';
  static const String notifications = '/notifications';
  static const String videos = '/videos';
  static const String mercadopago = '/webhooks/mercadopago';
  static const String chats = '/chats';
  static const String health = '/health';
  static const String userDataBank = '/user-data-bank';
}
