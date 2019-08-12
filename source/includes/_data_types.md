# Data Types

## Transfer

| Name | Type | Description |
|------|------|-------------|
| unique_id | string | Unique id defined by eZeeWallet for later use |
| transaction_id | string | Unique transfer transaction id defined by merchant |
| amount | integer | Amount of transfer transaction in minor currency unit |
| currency | string | Currency code in ISO 4217 |
| status | string | Status of the transfer transaction: approved or pending_async |
| source_wallet_id | string | Email address of consumer who owns the source wallet |
| return_success_url | string | URL where the consumer must be redirected to deposit money if status is pending async |
| return_failure_url | string | URL where the consumer must be redirected to deposit money if status is pending async |
| redirect_url | string | URL where the consumer must be redirected to deposit money if status is pending async |

## PayoutRequest

| Name               | Type        | Description                                            |
|--------------------|-------------|--------------------------------------------------------|
| email              | string(255) | Email address of consumer that will receive the amount |
| amount             | integer     | Amount of payout in minor currency unit                |
| currency           | string(3)   | Currency code in ISO 4217                              |
| merchant_reference | string(255) | Merchant reference identifier                          |

## SinglePayout

| Name               | Type   | Description                                             |
|--------------------|--------|---------------------------------------------------------|
| unique_id          | string | Unique id defined by eZeeWallet for later use           |
| status             | string | Status of the transfer transaction: succeeded or failed |
| merchant_reference | string | Merchant reference identifier                           |

## BatchPayout

| Name      | Type   | Description                                           |
|-----------|--------|-------------------------------------------------------|
| unique_id | string | Unique id defined by eZeeWallet for later use         |
| status    | string | Status of the transfer transaction: pending or failed |

## eZeePayout

| Name               | Type    | Description                                                             |
|--------------------|---------|-------------------------------------------------------------------------|
| transaction_id     | string  | Unique transfer transaction id defined by merchant                      |
| unique_id          | string  | Unique id defined by eZeeWallet for later use                           |
| amount             | integer | Amount of the payout transaction in minor currency unit                 |
| currency           | string  | Currency code in ISO 4217                                               |
| status             | string  | Status of the payout: pending or failed                                 |
| redirect_url       | string  | URL where the consumer must be redirected to enter credit card details  |
| return_success_url | string  | URL where customer is sent to after successful payout                   |
| return_failure_url | string  | URL where customer is sent to after unsuccessful payout                 |
| return_cancel_url  | string  | URL where customer is sent to after a cancelled payout                  |

## eZeePayoutDetails

| Name               | Type                      | Description                                             |
|--------------------|---------------------------|---------------------------------------------------------|
| transaction_id     | string     | Unique transfer transaction id defined by merchant                     |
| unique_id          | string     | Unique id defined by eZeeWallet for later use                          |
| amount             | integer    | Amount of the payout transaction in minor currency unit                |
| currency           | string     | Currency code in ISO 4217                                              |
| status             | string     | Status of the payout: pending or failed                                |
| redirect_url       | string     | URL where the consumer must be redirected to enter credit card details |
| return_success_url | string     | URL where customer is sent to after successful payout                  |
| return_failure_url | string     | URL where customer is sent to after unsuccessful payout                |
| return_cancel_url  | string     | URL where customer is sent to after a cancelled payout                 |
| billing_address    | [BillingAddress](#billingaddress) | Billing address of the consumer                 |
| credit_card        | [CreditCard](#creditcard) | Credit card details                                     |

## BillingAddress

| Name               | Type   | Description                |
|--------------------|--------|----------------------------|
| first_name         | string | First name of the consumer |
| last_name          | string | Last name of the consumer  |
| address1           | string | First line of the address  | 
| city               | string | City                       |
| zip_code           | string | Zip code                   |
| country            | string | Country                    |

## CreditCard

| Name             | Type   | Description                                 |
|------------------|--------|---------------------------------------------|
| holder           | string | Name of the holder                          |
| number           | string | First six and last four numbers on the card |
| expiration_month | string | Expiration month of the card                |
| expiration_year  | string | Expiration year of the card                 |

## Error

| Name              | Type   | Description                                                 |
|-------------------|--------|-------------------------------------------------------------|
| code              | string | machine parsable error code                                 |
| message           | string | human-readable message with simple description of the error |

## Pagination

| Name        | Type    | Description                         |
|-------------|---------|-------------------------------------|
| total_count | integer | total count of the returned objects |
| pages_count | integer | count of the pages                  |
| page        | integer | current page                        |
| per_page    | integer | number of returned objects per page |

## Notification

| Name           | Type   | Description                                                      |
|----------------|--------|------------------------------------------------------------------|
| transaction_id | string | Unique transfer transaction id defined by merchant               |
| unique_id      | string | Unique id defined by eZeeWallet for later use                    |
| status         | string | Status of the transfer transaction request                       |
| signature      | string | The signature of the notification used to verify the notifcation |

The signature is a mean of security to ensure that eZeeWallet is really the sender of the notification. It is generated by concatenating the unique id of the transaction with merchant name and generating a SHA1 Hash (Hex) of the string:

`SHA1 Hash (Hex) of <unique_id><merchant api_username>`

**Example:**

`unique_id = 123456789abcdefg`

`merchant api_username = 0987654321xyz`

`signature -> 9ec1df9a7013f6a5b952b9d3f12d620475d37c86`

## NotificationEcho

| Name      | Type   | Description                                   |
|-----------|--------|-----------------------------------------------|
| unique_id | string | Unique id defined by eZeeWallet for later use |
