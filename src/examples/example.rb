#!/usr/bin/env ruby
require 'coinqvest_merchant_sdk/client'

# This file contains examples on how to interact with the COINQVEST Merchant API.
# All endpoints of the API are documented here: https://www.coinqvest.com/en/api-docs

# Create a COINQVEST Merchant API client
# The constructor takes your API Key, API Secret and an optional log file location as parameters
# Your API Key and Secret can be obtained here: https://www.coinqvest.com/en/api-settings
client = CoinqvestMerchantSDK::Client.new(
    'YOUR-API-KEY',
    'YOUR-API-SECRET',
    '/var/log/coinqvest-ruby.log' # an optional log file location
)

# Invoke a request to GET /auth-test (https://www.coinqvest.com/en/api-docs#get-auth-test) to see if everything worked
response = client.get('/auth-test')

# The API should return an HTTP status code of 200 if the request was successfully processed, let's have a look.
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"

# Check our USD wallet balance using GET /wallet (https://www.coinqvest.com/en/api-docs#get-wallet)
response = client.get('/wallet', {:assetCode => 'USD'})
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"

# Create a checkout and get paid in two easy steps!
#
# It's good practice to associate payments with a customer, let's create one!
# Invoke POST /customer (https://www.coinqvest.com/en/api-docs#post-customer) to create a new customer object.
# Tip: At a minimum a customer needs an email address, but it's better to provide a full billing address for invoices.
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

if response.code != 200
  # something went wrong, let's abort and debug by looking at our log file specified above in the client.
  print "Could not create customer, please check the logs."
  exit 1
end

# the customer was created
data = JSON.parse(response.body)
# data now contains an object as specified in the success response here: https://www.coinqvest.com/en/api-docs#post-customer
# extract the customer id to use it in our checkout below
customer_id = data["customerId"]

# We now have a customer. Let's create a checkout for him/her.
# This creates a hosted checkout, which will provide a payment interface hosted on COINQVEST servers
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

if response.code != 200
  # something went wrong, let's abort and debug by looking at our log file specified above in the client.
  print "Could not create checkout, please check the logs."
  exit 1
end

# the checkout was created
data = JSON.parse(response.body)
# data now contains an object as specified in the success response here: https://www.coinqvest.com/en/api-docs#post-checkout
checkout_id = data["checkoutId"] # store this persistently in your database
url = data["url"] # redirect your customer to this URL to complete the payment

# you can update a customer object like this
response = client.put('/customer', {:customer => {
    :id => customer_id,
    :email => 'john@tester-2.com',
    :firstname => 'John',
    :lastname => 'Doe'
}})
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"

# delete a customer when not needed anymore
response = client.delete('/customer', {
    :id => customer_id
})
print "Status Code: " + response.code.to_s + "\n"
print "Response Body: " + response.body + "\n"
