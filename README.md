# COINQVEST Merchant SDK (Ruby)

Official COINQVEST Merchant API SDK for Ruby by www.coinqvest.com

This SDK implements the REST API documented at https://www.coinqvest.com/en/api-docs

For SDKs in different programming languages, see https://www.coinqvest.com/en/api-docs#sdks

Read our Merchant API [development guide](https://www.coinqvest.com/en/blog/guide-mastering-cryptocurrency-checkouts-with-coinqvest-merchant-apis-321ac139ce15) and the examples below to help you get started.

Requirements
------------
* Ruby >= 2.0.0
* rest-client >= 2.1.0
* json >= 1.8.3

Installation with gem
---------------------
`gem install coinqvest_merchant_sdk`

**Usage Client**
```ruby
require 'coinqvest_merchant_sdk/client'

client = CoinqvestMerchantSDK::Client.new(
    'YOUR-API-KEY',
    'YOUR-API-SECRET',
    '/var/log/coinqvest-ruby.log' # an optional log file location
)
```
Get your API key and secret here: https://www.coinqvest.com/en/api-settings


## Examples

**Create a Customer** (https://www.coinqvest.com/en/api-docs#post-customer)

Creates a customer object, which can be associated with checkouts, payments, and invoices. Checkouts associated with a customer generate more transaction details, help with your accounting, and can automatically create invoices for your customer and yourself.

```ruby
response = client.post('/customer', {:customer => {
    :email => 'john@tester-1.com',
    :firstname => 'John',
    :lastname => 'Doe',
    :company => 'ACME Inc.',
    :adr1 => '810 Beach St',
    :adr2 => 'Finance Department',
    :zip => 'CA 94103',
    :city => 'San Francisco',
    :countrycode => 'US'
}})
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"
```
**Create a Hosted Checkout** (https://www.coinqvest.com/en/api-docs#post-checkout-hosted)

Hosted checkouts are the simplest form of getting paid using the COINQVEST platform. 

Using this endpoint, your server submits a set of parameters, such as the payment details including optional tax items, customer information, and settlement currency. Your server then receives a checkout URL in return, which is displayed back to your customer. 

Upon visiting the URL, your customer is presented with a checkout page hosted on COINQVEST servers. This page displays all the information the customer needs to complete payment.

```ruby
response = client.post('/checkout/hosted', {
    :charge => {
        :customerId => customer_id, # associates this charge with a customer
        :currency => 'USD', # specifies the billing currency
        :lineItems => [{ # a list of line items included in this charge
            :description => 'T-Shirt',
            :netAmount => 10, # denominated in the currency specified above
            :quantity => 1
        }],
        :discountItems => [{ # an optional list of discounts
            :description => 'Loyalty Discount',
            :netAmount => 0.5
        }],
        :shippingCostItems => [{ # an optional list of shipping and handling costs
            :description => 'Shipping and Handling',
            :netAmount => 3.99,
            :taxable => FALSE # sometimes shipping costs are taxable
        }],
        :taxItems => [{ # an optional list of taxes
            :name => 'CA Sales Tax',
            :percent => 0.0825 # 8.25% CA sales tax
        }]
    },
    :settlementCurrency => 'EUR' # specifies in which currency you want to settle
})
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"
```

**Monitor Payment State** (https://www.coinqvest.com/en/api-docs#get-checkout)

Once the payment is captured we notify you via email, [WEBHOOK /payment](https://www.coinqvest.com/en/api-docs#webhook-payment), or you can poll [GET /checkout](https://www.coinqvest.com/en/api-docs#get-checkout) for payment status updates:

```ruby
response = client.get('/checkout', {:id => checkout_id})
if response.code == 200
  data = JSON.parse(response.body)
  state = data["checkout"]["state"]
  if %w(COMPLETED DELAYED_COMPLETED RESOLVED).include? state
    print "The payment has completed and your account was credited. You can now ship the goods."
  else
    # try again in 30 seconds or so...
  end
end
```

**Query your USD Wallet** (https://www.coinqvest.com/en/api-docs#get-wallet)
```ruby
response = client.get('/wallet', {:assetCode => 'USD'})
```

**Query all Wallets** (https://www.coinqvest.com/en/api-docs#get-wallets)
```ruby
response = client.get('/wallets')
```

**Withdraw to your NGN Bank Account** (https://www.coinqvest.com/en/api-docs#post-withdrawal)
```ruby
response = client.post('/withdrawal', {
  :sourceAsset => 'USD:GDUKMGUGDZQK6YHYA5Z6AY2G4XDSZPSZ3SW5UN3ARVMO6QSRDWP5YLEX', #withdraw from your USD wallet
  :sourceAmount => '100',
  :targetNetwork => 'NGN', # send to an NGN bank account
  :targetAccount => {
    :nuban => '3080494548',
    :bankName => 'FirstBank'
  }
})
```

**Withdraw to your Bitcoin Account** (https://www.coinqvest.com/en/api-docs#post-withdrawal)
```ruby
response = client.post('/withdrawal', {
  :sourceAsset => 'USD:GDUKMGUGDZQK6YHYA5Z6AY2G4XDSZPSZ3SW5UN3ARVMO6QSRDWP5YLEX', #withdraw from your USD wallet
  :sourceAmount => '100',
  :targetNetwork => 'BTC', # send to a BTC address
  :targetAccount => {
    :address => 'bc1qj633nx575jm28smgcp3mx6n3gh0zg6ndr0ew23'
  }
})
```

**Withdraw to your Stellar Account** (https://www.coinqvest.com/en/api-docs#post-withdrawal)
```ruby
response = client.post('/withdrawal', {
  :sourceAsset => 'USD:GDUKMGUGDZQK6YHYA5Z6AY2G4XDSZPSZ3SW5UN3ARVMO6QSRDWP5YLEX', #withdraw from your USD wallet
  :sourceAmount => '100',
  :targetNetwork => 'XLM', # send to a Stellar account
  :targetAccount => {
    :account => 'GDONUHZKLSYLDOZWR2TDW25GFXOBWCCKTPK34DLUVSOMFHLGURX6FNU6',
    :memo => 'Exodus',
    :memoType => 'text'
  }
})
```

**Update a Customer** (https://www.coinqvest.com/en/api-docs#put-customer)
```ruby
response = client.put('/customer', {:customer => {
    :id => customer_id,
    :email => 'john@tester-2.com'
}})
```

**Delete a Customer** (https://www.coinqvest.com/en/api-docs#delete-customer)
```ruby
response = client.delete('/customer', {:id => customer_id})
```

**List your 250 newest customers** (https://www.coinqvest.com/en/api-docs#get-customers)
```ruby
response = client.get('/customers', {:limit => 250})
```

**List all available blockchains** (https://www.coinqvest.com/en/api-docs#get-blockchains)
```ruby
response = client.get('/blockchains')
```

**List all available fiat currencies** (https://www.coinqvest.com/en/api-docs#get-fiat-currencies)
```ruby
response = client.get('/fiat-currencies')
```

Please inspect https://www.coinqvest.com/en/api-docs for detailed API documentation or send us an email to service@coinqvest.com.

Support and Feedback
--------------------
Your feedback is appreciated! If you have specific problems or bugs with this SDK, please file an issue on Github. For general feedback and support requests, send an email to service@coinqvest.com.

Contributing
------------

1. Fork it ( https://github.com/COINQVEST/php-merchant-sdk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request