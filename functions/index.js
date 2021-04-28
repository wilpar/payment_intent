const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secretkey, {apiVersion: '2019-05-16'});
// 2020-08-27

exports.pub_key = functions.https.onRequest(async (req, res) => {
  res.json({ publishable_key: functions.config().stripe.pubkey });
});

exports.create_payment_intent = functions.https.onRequest(async (req, res) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: req.query.amount,
      currency: req.query.currency,    
    });
    res.json({ clientSecret: paymentIntent.client_secret });
  } catch(err) {
    res.status(400).json({ error: { message: err.message } })
  }
});