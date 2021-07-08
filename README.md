# payment_intent

Flutter Stripe Payment Sheet Demo for both Standard and Connect Direct charges.

- Standard Charges - go from the app to the stripe account holder
- Connect Direct charges - go from the app to the connected/vendor account.  This is the 'fun' one.  See https://stripe.com/docs/connect/direct-charges

## Getting Started

1. You will need a firebase account on Blaze package to talk to outside APIs like Stripe. Charges likely to be under 10c / mo.

2. copy lib/config.example.dart to lib/config.dart and enter your firebase functions URL.

3. You'll need a stripe account. 

4. set your stripe publishable key and secret key:

firebase functions:config:set stripe.pubkey=""
firebase functions:config:set stripe.secretkey=""

### A Video of this is forthcoming. Check the Founder@50 channel at https://www.youtube.com/channel/UCQdDdKqtWBpVVcnlL1MDhMg

