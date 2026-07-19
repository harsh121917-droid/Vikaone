class ApiConstants {
  ApiConstants._();
  static const String baseUrl       = 'https://bharatsqft-backend.onrender.com/api';
  static const String login         = '/auth/login';
  static const String register      = '/auth/register';
  static const String me            = '/auth/me';
  static const String properties    = '/properties';
  static const String createOrder   = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String myInvestments = '/payments/my';
  static const String kycSubmit     = '/kyc/submit';
  static const String kycMe         = '/kyc/me';
  static const String savings = '/savings';
}