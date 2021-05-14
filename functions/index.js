const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secretkey, {apiVersion: '2020-08-27'});

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

  let dataObject = event.data.object;

  const hookRef = admin.firestore().collection('webhooks').doc(dataObject.id);
  const doc = await hookRef.get();
  if (!doc.exists) {
    let whSource = { a_source: 'whca'};
    let whStatus = { a_status: 'new'};
    let whType = { a_type: event.type };
    let combinedObject = {...dataObject, ...whSource, ...whStatus, ...whType};
    await hookRef.set(combinedObject);
    return res.json({ received: true});
  } else {
    return res.json({ received: true, dupe: true});
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

  let dataObject = event.data.object;

  const hookRef = admin.firestore().collection('webhooks').doc(dataObject.id);
  const doc = await hookRef.get();
  if (!doc.exists) {
    let whSource = { a_source: 'whca_connect'};
    let whStatus = { a_status: 'new'};
    let whType = { a_type: event.type };
    let combinedObject = {...dataObject, ...whSource, ...whStatus, ...whType};
    await hookRef.set(combinedObject);
    return res.json({ received: true});
  } else {
    return res.json({ received: true, dupe: true});
  }
})

//  3. webhookProcessor
exports.webhookProcessor = functions.firestore.document('webhooks/{docId}b ').onCreate((snapshot, context) => {
  const data = snapshot.data();
  if (data.a_status == 'processed') {
    return null;
  }
  switch(data.a_type) {
    case 'account.updated':
      functions.logger.info(`Account Updated: ${data.id}`);
      break;
    default:
      functions.logger.error(`Unhandled Event: ${data.a_type}`);
      break;
  }
  return snapshot.ref.set({a_status: 'processed'}, {merge: true});
})