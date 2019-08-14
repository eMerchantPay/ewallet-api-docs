# Overview

eZeeWallet API supports creating and listing transfer transactions via **HTTPS using JSON**.

> You can get cURL from <a href='https://curl.haxx.se'>https://curl.haxx.se</a>

## Authentication

Wallet API uses **HTTP Basic Authentication**. Each merchant registered with eZeeWallet is provided an API username and password. These credentials are different from the login credentials of merchant employees and can be configured in 'Merchant API Details' tab.

## Endpoint paths

| Environment | Address                            |
|-------------|------------------------------------|
| Staging     | https://staging.ezeewallet.com/api |
| Production  | https://ezeewallet.com/api         |

## Request and response headers

Requests to eZeeWallet API endpoints must include the following HTTP header:

`Content-Type: application/json`

By default, all endpoint responses provide data as JSON in the response body and include a Content-Type header:

`application/json`

## Providing parameters

The way you provide parameters to a eZeeWallet API request depends on the HTTP method of the request.

### GET requests

For GET requests, you provide parameters in a query string you append to your request's URL. For example, you provide the unique_id parameter to the ListTransfers endpoint like so:

`https://ezeewallet.com/api/transfers?unique_id=1234567890`

```shell
{
  "transaction_id": "MerchantTx123",
  "usage": "Purchasing shoes",
  "amount": 10000,
  "currency": "USD",
  "source_wallet_id": "consumer@example.com",
  "source_wallet_pwd": "UGFzc3dvcmQx",
  "return_success_url": "http://example.com/success",
  "return_failure_url": "http://example.com/failure",
  "notification_url": "http://example.com/notification"
}
```

### POST requests

For POST requests, you instead provide parameters as JSON in the body of your request. For example, the body of a request to the CreateTransfer endpoint looks like this:

## Working with monetary amounts

Amounts on the API level should be submitted in the minor currency unit for the given currency.
The currency field is in **ISO 4217** format.

eZeeWallet does not support any form of Forex. Per transfer transaction, currency usage is restricted: the requested currency must match the currency that is configured for the source wallet and the target wallet. For example, if a consumer has a USD wallet and a merchant has only a GBP wallet, a transfer is not possible, resulting in a "Currency mismatch" error for any currency in the API request. If a consumer and a merchant both have a USD wallet only, then an API request for any currency other than USD will receive a "Currency mismatch" error.

## Working with dates

All representations of dates are strings in **ISO RFC3339** format (date time 2011-01-11T00:00:00Z).

## Paginating results

List endpoints such as ListTransfers might paginate the results they return. This means that instead of returning all results in a single response, these endpoints might return some of the results, along with a attributes for current page, page count, etc in the response body.

```shell
{
  "pagination": {
    "total_count": 190,
    "pages_count": 2,
    "page": 2,
    "per_page": 100
  },

  "transfers": [
    {},
    {},
  ]
}
```

## Handling errors

eZeeWallet API endpoints use HTTP protocol status codes to indicate errors.

All eZeeWallet API endpoints include [Error](#error) object in their response body if any errors occurred during a request. The response body has the following structure:

```shell
{
  "error": {
    "code": 407,
    "message": "Currency mismatch",
  }
}
```

Each error has the following fields:

* code is machine parsable error code
* message is a human-readable string with simple description of the error

See [Error Codes](#errors) for list of errors provided by the system
