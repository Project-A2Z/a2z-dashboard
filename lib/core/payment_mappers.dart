class PaymentMappers {
  static const List<String> paymentWayOptionsAr = ['كاش', 'اونلاين'];
  static const List<String> paymentStatusOptionsAr = [
    'تم دفع جزء',
    'تم الدفع',
    'تم الاسترجاع',
    'تم الإلغاء',
  ];
  static const List<String> paymentWithOptionsAr = ['انستا باي', 'فودافون'];

  static String toPaymentStatusApi(String value) {
    switch (value.trim()) {
      case 'تم الدفع':
      case 'paid':
      case 'Paid':
        return 'Paid';
      case 'تم دفع جزء':
      case 'deposit':
      case 'Deposit':
        return 'Deposit';
      case 'تم الاسترجاع':
      case 'refunded':
      case 'Refunded':
        return 'Refunded';
      case 'تم الإلغاء':
      case 'cancelled':
      case 'Cancelled':
        return 'Cancelled';
      default:
        return 'Paid';
    }
  }

  static String toPaymentWayApi(String value) {
    switch (value.trim()) {
      case 'كاش':
      case 'cash':
      case 'Cash':
        return 'Cash';
      case 'اونلاين':
      case 'online':
      case 'Online':
        return 'Online';
      default:
        return 'Cash';
    }
  }

  static String toPaymentWithApi(String value) {
    switch (value.trim()) {
      case 'انستا باي':
      case 'instaPay':
      case 'InstaPay':
        return 'InstaPay';
      case 'فودافون':
      case 'vodafone':
      case 'Vodafone':
        return 'Vodafone';
      default:
        return 'InstaPay';
    }
  }

  static String toPaymentTypeApi(String value) {
    switch (value.trim()) {
      case 'revenues':
      case 'Revenues':
      case 'ايرادات':
      case 'إيرادات':
        return 'Revenues';
      case 'expenses':
      case 'Expenses':
      case 'مصروفات':
        return 'Expenses';
      default:
        return 'Revenues';
    }
  }
}