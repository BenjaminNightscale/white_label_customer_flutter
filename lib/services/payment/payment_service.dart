import 'package:cloud_functions/cloud_functions.dart';

class PaymentService {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');

  Future<String> createPaymentIntent(int amount, String currency) async {
    try {
      final response = await callable.call(<String, dynamic>{
        'amount': amount,
        'currency': currency,
      });
      return response.data['clientSecret'];
    } catch (e) {
      print('Error creating payment intent: $e');
      throw e;
    }
  }
}
