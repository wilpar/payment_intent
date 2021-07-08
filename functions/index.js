const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secretkey, { apiVersion: '2020-08-27' });

exports.pub_key = functions.https.onRequest(async (req, res) => {
  res.json({ publishable_key: functions.config().stripe.pubkey });
});

exports.create_payment_intent = functions.https.onRequest(async (req, res) => {

  const customers = await stripe.customers.list()
  const customer = customers.data[0]

  if (!customer) {
    res.send({
      error: 'You have no customer created',
    })
  }

  try {
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2020-08-27' }
    )
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 10000,
      currency: 'usd',
      customer: customer.id,
    })
    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
    })
  } catch (err) {
    res.status(400).json({
      error: {
        message: err.message
      }
    })
  }
});

exports.connected_payment_intent = functions.https.onRequest(async (req, res) => {
  const platformCustomers = await stripe.customers.list()
  const platformCustomer = platformCustomers.data[0]
  const connectedAccountId = req.query.acct

  if (!platformCustomer) {
    res.send({
      error: 'Platform has no Customers.',
    })
  }

  try {
    // should check if customer already exists on connected account
    const connectedCustomer = await stripe.customers.create({
      email: platformCustomer.email
    }, {
      stripeAccount: connectedAccountId
    })
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: connectedCustomer.id },
      {
        apiVersion: '2020-08-27',
        stripeAccount: connectedAccountId,
      }
    )
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 10000,
      application_fee_amount: 1000,
      currency: 'usd',
      customer: connectedCustomer.id,
    }, {
      stripeAccount: connectedAccountId,
    })
    res.json({
      ephemeralKey: ephemeralKey.secret,
      paymentIntent: paymentIntent.client_secret,
      customer: connectedCustomer.id,
    })
  } catch (err) {
    res.status(400).json({
      error: {
        message: err.message
      }
    })
  }
})

// firebase functions:config:set stripe.webhook="xxx"
// firebase functions:config:set stripe.connect-webhook="yyy"

// 1. receive webhooks from stripe
exports.whca = functions.https.onRequest(async (req, res) => {
  const webhookSecret = functions.config().stripe.whca;
  let sig = req.headers["stripe-signature "];
  let event;

  const payloadData = req.rawBody;
  const payloadString = payloadData.toString();

  try {
    event = stripe.webhooks.constructEvent(payloadString, sig, webhookSecret);
  } catch (error) {
    functions.logger.error(`Error Message: ${error.message}`);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }

  const hookRef = admin.firestore().collection('webhooks').doc(event.id);
  const doc = await hookRef.get();
  if (!doc.exists) {
    let whSource = { source: 'whca' };
    let whStatus = { status: 'unprocessed' };
    let combinedObject = { ...event, ...whSource, ...whStatus };
    await hookRef.set(combinedObject);
    return res.json({ received: true });
  } else {
    return res.json({ received: true, duplicate: true });
  }
})

// 2. receive webhooks from stripe connect
exports.whca_connect = functions.https.onRequest(async (req, res) => {
  const webhookSecret = functions.config().stripe.whca_connect;
  let sig = req.headers["stripe-signature"];
  let event;

  const payloadData = req.rawBody;
  const payloadString = payloadData.toString();

  try {
    event = stripe.webhooks.constructEvent(payloadString, sig, webhookSecret);
  } catch (error) {
    functions.logger.error(`Error Message: ${error.message}`);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }

  const hookRef = admin.firestore().collection('webhooks').doc(event.id);
  const doc = await hookRef.get();
  if (!doc.exists) {
    let whSource = { source: 'whca_connect' };
    let whStatus = { status: 'unprocessed' };
    let combinedObject = { ...event, ...whSource, ...whStatus };
    await hookRef.set(combinedObject);
    return res.json({ received: true });
  } else {
    return res.json({ received: true, duplicate: true });
  }
})

//  3. webhookProcessor
exports.webhookProcessor = functions.firestore.document('webhooks/{docId}').onCreate((snapshot, context) => {
  let event = snapshot.data()
  if (event.status == 'processed') {
    return null;
  }
  switch (event.type) {
    case 'account.updated':
      functions.logger.info(`Account Updated Event: ${event.id}`);
      break;
    default:
      functions.logger.error(`Unhandled Event: ${event.type}`);
      break;
  }
  return snapshot.ref.set({ status: 'processed' }, { merge: true });
})