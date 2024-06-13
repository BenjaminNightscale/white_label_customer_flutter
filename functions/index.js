const functions = require('firebase-functions');
const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require('firebase-admin');
admin.initializeApp();

// Zugriff auf die Umgebungsvariable
//const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripeSecret = "sk_test_51P6zuhRqMnrUhHfkUVqir9My7sWBJdxG2iGLm9HZ7PME8k8DbeQQeLIyNrTWtvmVmRlM2F7BvXaBLXEYpoJVsCY700U3Tr995U";
const stripe = require('stripe')(stripeSecret);

exports.createPaymentIntent = onCall(async (request) => {
  const amount = request.data.amount; // Amount in cents
  const currency = request.data.currency; // Currency, e.g., 'eur'

  if (!amount || !currency) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with the arguments "amount" and "currency".');
  }

  try {
    logger.info(`Creating payment intent for amount: ${amount} and currency: ${currency}`);
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
    });

    logger.info(`Payment intent created: ${paymentIntent.id}`);
    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    logger.error("Error creating payment intent", error);
    throw new functions.https.HttpsError('unknown', `Error creating payment intent: ${error.message}`, error);
  }
});

exports.checkStripeKey = onCall((request) => {
  if (!stripeSecret) {
    logger.error('Stripe secret key is not set.');
    throw new functions.https.HttpsError('failed-precondition', 'Stripe secret key is not set.');
  }
  logger.info(`Stripe key: ${stripeSecret}`);
  return { stripeSecret };
});
