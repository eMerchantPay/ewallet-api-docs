# Endpoints

## Transfers

### CreateTransfer

> Example request

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

`POST /transfers`

Creates transfer, consumer to merchant wallet

> Example response

```shell
{
  "transfer": {
    "unique_id": "random_unique_id",
    "transaction_id": "MerchantTx123",
    "usage": "Purchasing shoes",
    "amount": 10000,
    "currency": "USD",
    "source_wallet_id": "consumer@example.com",
    "return_success_url": "http://example.com/success",
    "return_failure_url": "http://example.com/failure",
    "status": "approved"
  }
}
```

> Example response for pending async transfer

```shell
{
  "transfer": {
    "unique_id": "random_unique_id",
    "transaction_id": "MerchantTx123",
    "usage": "Purchasing shoes",
    "amount": 10000,
    "currency": "USD",
    "source_wallet_id": "consumer@example.com",
    "return_success_url": "http://example.com/success",
    "return_failure_url": "http://example.com/failure",
    "status": "pending",
    "redirect_url":"https://ezeewallet.com/en/consumers/top_up/random_unique_id"
  }
}
```

> Example response for failed transfer due to an error

```shell
{
  "error": {
    "code": 407,
    "message": "Currency mismatch",
  }
}
```

**Body params**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| transaction_id | string(255) | yes | Unique transaction id defined by merchant |
| usage | string(255) | no | Description of the transaction that will be visible to end users |
| amount | integer | yes | Amount of transaction in minor currency unit |
| currency | string(3) | yes | Currency code in ISO 4217 |
| source_wallet_id | string(255) | yes | Email address of consumer who owns the source wallet |
| source_wallet_pwd | string(255) | yes | Password of consumer who owns the source wallet, in Base64 encoded form |
| return_success_url | string(65535) | yes | URL where customer is sent to after successful payment |
| return_failure_url | string(65535) | yes | URL where customer is sent to after unsuccessful payment |
| notification_url | string(65535) | yes | URL where notification for transfer is sent |

**Response fields**

| Name        | Type                                             | Description       |
|-------------|-----------------------|----------------------------------------------|
| transfer    | [Transfer](#transfer) | The created transfer                         |
| error       | [Error](#error)       | Any errors that occurred during the request. |

Note that in the case of pending async (consumer does not have balance for the transaction and needs to top up) merchant will receive [Notification](#notification) upon transfer success/error and must respond with [NotificationEcho](#notificationecho)

### ListTransfers

`GET /transfers?unique_id=value`

`GET /transfers?transaction_id=value`

`GET /transfers?start_date=value&end_date=value`

> Example response

```shell
{
  "pagination": {
    "total_count": 1,
    "pages_count": 1,
    "per_page": 30,
    "page": "1"
  },
  "transfers": [
    {
      "unique_id": "f3a5870ab96f514f0e28983fb88a9c4eed2a366a",
      "transaction_id": "40",
      "amount": 10000,
      "currency": "USD",
      "status": "pending",
      "source_wallet_id": "dimitar.kostov@emerchantpay.com",
      "return_success_url": "http://example.com/success",
      "return_failure_url": "http://example.com/failure"
    }
  ]
}
```

**Body params**

| Name               | Type          | requried | Description                                          |
|--------------------|---------------|----------|------------------------------------------------------|
| param_name         | string(255)   | yes      | unique_id, transaction_id or start_date and end_date |

**Response fields**

| Name        | Type                      | Description                                 |
|-------------|---------------------------|---------------------------------------------|
| pagination  | [Pagination](#pagination) | pagination options object                   |
| transfers   | [Transfer](#transfer)     | Array of returned transfers                 |
| error       | [Error](#error)           | Any error that occurred during the request. |

## Single Payouts

### Create Single Payout 

`POST /single_payouts`

Creates single payout, merchant wallet to consumer wallet

> Example request

```shell
{
  "email": "consumer@emp.com",
  "amount": 100,
  "currency": "USD",
  "merchant_reference": "abc123"
}
```

> Example response

```shell
{
  "unique_id": 2,
  "status": "succeeded",
  "merchant_reference": "abc123"
}
```

**Body params**

| Name           | Type                            | Requried | Description           |
|----------------|---------------------------------|----------|-----------------------|
| payout_request | [PayoutRequest](#payoutrequest) | Yes      | Payout request object |

**Response fields**

| Name        | Type                          | Description                                  |
|-------------|-------------------------------|----------------------------------------------|
| payout      | [SinglePayout](#singlepayout) | The created payout                           | 
| error       | [Error](#error)               | Any errors that occurred during the request. |

## Batch Payouts

### Create Batch Payout

> Example request

```shell
{
  "payout_requests": [
    {
      "email": "consumer1@emerchantpay.com",
      "amount": 100,
      "currency": "USD",
      "merchant_reference": "abc123"
    },
    {
      "email": "consumer2@emerchantpay.com",
      "amount": 200,
      "currency": "EUR",
      "merchant_reference": "abc124"
    },
    {
      "email": "consumer2@emerchantpay.com",
      "amount": 350,
      "currency": "GBP",
      "merchant_reference": "abc125"
    }
  ]
}
```

> Example response

```shell
{
  "unique_id": 5,
  "status": "pending"
}
```

`POST /batch_payouts`

Creates batch payout, merchant wallet to consumer wallet

**Body params**

| Name            | Type                               | Requried | Description                     |
|-----------------|------------------------------------|----------|---------------------------------|
| payout_requests | [PayoutRequest[]](#payout-request) | Yes      | Array of payout request objects | 

**Response fields**

| Name         | Type                        | Description                                  |
|--------------|-----------------------------|----------------------------------------------|
| batch_payout | [BatchPayout](#batchpayout) | The created payout                           | 
| error        | [Error](#error)             | Any errors that occurred during the request. |

## eZeePayouts

eZeePayout is direct credit to consumers credit card. When the merchant requests payout via [CreateEzeePayout](#createezeepayout) redirect_url is returned where the consumer should be pointed to. After the consumer completes entering credit card details and submitting the form, the merchant must approve or decline the payout. The transaction is async and the merchant will receive a [Notification](#notification) after the approve/decline and must must respond with [NotificationEcho](#notificationecho). If the merchant does not take any action for 3 days(approve or decline the payout) the transaction will be marked as timed out

### CreateEzeePayout

`POST /ezee_payouts`

> Example request

```shell
{
  "amount": 10000,
  "currency": "USD",
  "transaction_id": "MerchantTx123",
  "return_success_url": "http://example.com/success",
  "return_failure_url": "http://example.com/failure",
  "return_cancel_url": "http://example.com/cancel",
  "notification_url": "http://example.com/"
}
```

> Example response

```shell
{
  "transaction_id": "MerchantTx123",
  "unique_id": "random_unique_id",
  "amount": 10000,
  "currency": "USD",
  "status": "pending",
  "redirect_url":"https://ezeewallet.com/redirect_to/random_unique_id",
  "return_success_url": "http://example.com/success",
  "return_failure_url": "http://example.com/failure",
  "return_cancel_url": "http://example.com/cancel"
}
```

Creates eZeePayout, direct credit to credit card. 

**Body params**

| Name | Type | Description |
|------|------|-------------|
| transaction_id | string | Unique transfer transaction id defined by merchant |
| amount | integer | Amount of transfer transaction in minor currency unit |
| currency | string | Currency code in ISO 4217 |
| return_success_url | string | URL where the consumer will be redirected to on successful |
| return_failure_url | string | URL where the consumer will be redirected to deposit money if status is pending async |
| return_cancel_url | string | URL where the consumer must be redirected to deposit money if status is pending async |
| notification_url | string | URL where notification for transfer is sent |

**Response fields**

| Name        | Type                          | Description                                  |
|-------------|-------------------------------|----------------------------------------------|
| ezee_payout | [EzeePayout](#ezeepayout)     | The created eZeePayout                       | 
| error       | [Error](#error)               | Any errors that occurred during the request. |

> Example response

```shell
{
  "transaction_id": "transaction123",
  "unique_id": "unique_id",
  "amount": 1000,
  "currency": "EUR",
  "status": "approved",
  "redirect_url":"https://ezeewallet.com/redirect_to/random_unique_id",
  "return_success_url": "https://staging.ezeewallet.com/",
  "return_failure_url": "http://example.com/failure",
  "return_cancel_url": "http://example.com/cancel",
  "billing_address": {
    "first_name": "Jane",
    "last_name": "Doe",
    "address1": "Address",
    "city": "Vienna",
    "zip_code": "1700",
    "country": "Austria"
  },
  "credit_card": {
    "holder": "Jane Doe",
    "number": "420000...0000",
    "expiration_month": "January",
    "expiration_year": 2021
  }
}
```

### ShowEzeePayout 

`GET /ezee_payouts/:unique_id`

Gets eZeePayout data

**Response fields**

| Name        | Type                                    | Description                                  |
|-------------|-----------------------------------------|----------------------------------------------|
| ezee_payout | [EzeePayoutDetails](#ezeepayoutdetails) | Details about the ezeepayout transaction     | 
| error       | [Error](#error)                         | Any errors that occurred during the request. |

<br/><br/><br/><br/><br/><br/><br/><br/><br/>

### ApproveEzeePayout

> Example request

```shell
{
  "status": "approved"
}
```

> Example response

```shell
{
  "transaction_id": "MerchantTx123",
  "unique_id": "random_unique_id",
  "amount": 10000,
  "currency": "USD",
  "status": "approved",
  "return_success_url": "http://example.com/success",
  "return_failure_url": "http://example.com/failure",
  "return_cancel_url": "http://example.com/cancel",
  "redirect_url":"https://ezeewallet.com/redirect_to/random_unique_id"
}
```

`PATCH /ezee_payouts/:unique_id`

Approves eZeePayout

**Body params**

| Name      | Type   | Required | Description             |
|-----------|--------|----------|-------------------------|
| status    | string | Yes      | status of the payout    |

**Response fields**

| Name        | Type                      | Description                                  |
|-------------|---------------------------|----------------------------------------------|
| ezee_payout | [EzeePayout](#ezeepayout) | The updated payout                           | 
| error       | [Error](#error)           | Any errors that occurred during the request. |

<br/><br/>

### DeclineEzeePayout 

`PATCH /ezee_payouts/:unique_id`

> Example request

```shell
{
  "status": "declined"
}
```

> Example response

```shell
{
  "transaction_id": "MerchantTx123",
  "unique_id": "random_unique_id",
  "amount": 10000,
  "currency": "USD",
  "status": "declined",
  "return_success_url": "http://example.com/success",
  "return_failure_url": "http://example.com/failure",
  "return_cancel_url": "http://example.com/cancel",
  "redirect_url":"https://ezeewallet.com/redirect_to/random_unique_id"
}
```

Declines eZeePayout

**Body params**

| Name      | Type   | Required | Description             |
|-----------|--------|----------|-------------------------|
| status    | string | Yes      | status of the payout    |

**Response fields**

| Name        | Type                      | Description                                  |
|-------------|---------------------------|----------------------------------------------|
| ezee_payout | [EzeePayout](#ezeepayout) | The updated payout                           | 
| error       | [Error](#error)           | Any errors that occurred during the request. |
