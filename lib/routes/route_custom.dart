import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/crab_purchase_binding.dart';
import '../bindings/crabtype_binding.dart';
import '../bindings/daily_summary_binding.dart';
import '../bindings/trader_binding.dart';
import '../pages/dailySumView/daily_summary_detail_view.dart';
import '../pages/dailySumView/daily_summary_view.dart';
import '../pages/homeView/home_view.dart';
import '../pages/invoiceView/daily_invoice_view.dart';
import '../pages/invoiceView/invoice_creation_view.dart';
import '../pages/invoiceView/invoice_edit_view.dart';
import '../pages/loginView/login_view.dart';
import '../pages/rootView/root_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => RootView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      bindings: [
        AuthBinding(),
        CrabTypeBinding(),
        TraderBinding(),
        CrabPurchaseBinding(),
        DailySummaryBinding(),
      ],
    ),
    GetPage(
      name: '/invoice-creation',
      page: () => const InvoiceCreationView(),
      binding: CrabPurchaseBinding(),
    ),
    GetPage(
      name: '/daily-summary',
      page: () => DailySummaryView(),
      binding: DailySummaryBinding(),
    ),
    GetPage(
      name: '/daily-invoices',
      page: () => DailyInvoicesView(),
      binding: CrabPurchaseBinding(),
    ),
    GetPage(
      name: '/edit-invoice',
      page: () => EditInvoicePage(crabPurchase: Get.arguments),
      binding: CrabPurchaseBinding(),
    ),
    GetPage(
      name: '/daily-summary-detail',
      page: () => DailySummaryDetailView(
        dailySummary: Get.arguments,
      ),
      binding: DailySummaryBinding(),
    ),
  ];
}
