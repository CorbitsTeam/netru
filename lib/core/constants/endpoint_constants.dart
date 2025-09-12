class EndpointConstants {
  static const String baseUrl = 'https://admin-api.quickwash.sa';
  // Add your endpoints here

  static const String signUp = '/auth/customer/sign-up';
  static const String login = '/auth/customer/sign-in';
  static const String logout = '/auth/customer/sign-out';
  static const String otp = '/auth/customer/verify-otp';
  static const String availableSlots = '/slots/available';
  static const String promocodeValidate = '/promocodes/validate';
  static const String order = '/orders/online';
  static const String getCurrentbalance = '/customers/balance';
  static String receipt(id) =>
      'https://admin-api.quickwash.sa/orders/print/$id/invoice/ar';
  static const String pendingOrder =
      '/orders/pending'; // Added for pending orders
  static const String notifications = '/notifications';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static String notificationsMarkRead(id) => '/notifications/update/$id/read';
  static const String notificationsRegisterToken =
      '/notifications/device-token';

  // Notification settings endpoints
  static const String notificationsSettings = '/notifications/settings';
  static String notificationUpdateSetting(String type) =>
      '/notifications/settings/$type';

  static const String orderSearch = "/orders/search/my-orders";
  static const String offers = '/offers';
  static const String checkCreateNewOrder = '/orders/can-create-order';
  static const String packages = '/packages'; // Added the packages endpoint

  static String completeOrder(String id) => '/orders/$id/complete';
  static String orderDetails(num id) => '/orders/complete/$id';
  static String canceledOrder(num id) => '/orders/customer-cancel/$id';
  static String payOrder(num id) => '/orders/pay-order/$id';

  static const String minimumPrice = '/settings/general';
  static const String services = '/services';
  static const String slotById = '/slots';
  static const String addFund = '/customers/wallet/recharge';
  static const String slotAvailable = '/slots/available';
  static const String searchPlaces =
      '/places/search'; // Added for address handling
  static const String placeDetails =
      '/places/details'; // Added for address handling
  static const String addAddress = '/customers/addresses';
  static const String priceList =
      '/products/search'; // Added for address handling
  static const String addSubscriptions =
      '/subscriptions'; // Added for address handling
  static const String urlImage =
      'https://cdn.quickwash.sa/public/'; //url for images

  static String updateCustomer = '/customers/me';

  // Delete account endpoints
  static const String deleteAccountRequest = '/customers/me/delete-request';
  static const String deleteAccountConfirm = '/customers/me/delete-confirm';
}
