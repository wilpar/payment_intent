# Flutter Stripe Payment Sheet Demo 

This works for for both Standard and Connect Direct charges. It's based on the example app at https://github.com/flutter-stripe/flutter_stripe/tree/main/example

There are two examples:

- Standard Charges - you charge the customer directly
- Connect Direct charges - you process the charge for your connected (vendor) account, and (optionally) keep a fee for yourself.  This is the 'fun' one, and to my mind, the optimal way of running a marketplace.  The customer sees the charge directly from the vendor, and the vendor sees both your marketplace fee and the stripe fee, separately. 

See https://stripe.com/docs/connect/direct-charges

## Credits

My most heartfealt thanks to the excellent support staff at Stripe.  On this project, I spent hours on chat and via email with Ruthann, Carly G, and Lucas.  Thanks guys!  You're the best! Couldn't have done this without your input.

## Known Issues

Currently, the app creates a new customer in the connected account for each payment.  This needs to be fixed in the function.

## Getting Started

1. You will need a firebase account on Blaze package to talk to outside APIs like Stripe. Charges likely to be under 10c / mo.

2. copy lib/config.example.dart to lib/config.dart and enter your firebase functions URL.

3. You'll need a stripe account. 

4. set your stripe publishable key and secret key:

firebase functions:config:set stripe.pubkey=""
firebase functions:config:set stripe.secretkey=""

### A Video of this is forthcoming. Check the Founder@50 channel at https://www.youtube.com/channel/UCQdDdKqtWBpVVcnlL1MDhMg

Consider subscribing to the channel if this was helpful to you.