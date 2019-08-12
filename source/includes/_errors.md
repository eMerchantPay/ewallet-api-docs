# Errors

eZeeWallet API attempts to return appropriate HTTP status codes for every request and returns errors with HTTP status, human readable error message and machine parsable error code and description in JSON format


| Code | HTTP Status | Message |
|------|-------------|---------|
| 401  | 400 Bad Request | Parameters are missing or invalid |
| 402  | 400 Bad Request | Invalid credentials for source wallet account |
| 403  | 400 Bad Request | Transaction disallowed for source wallet account |
| 404  | 400 Bad Request | Merchant wallet is disabled |
| 405  | 400 Bad Request | Target wallet account not found |
| 406  | 400 Bad Request | Transaction disallowed for target wallet account |
| 407  | 400 Bad Request | Currency mismatch |
| 407  | 400 Bad Request | One of the payout currencies mismatched to the currency of source wallets |
| 407  | 400 Bad Request | Payout currency mismatched to the currency of source wallets |
| 407  | 400 Bad Request | Target wallet currency is different than the currency of the payout |
| 408  | 400 Bad Request | Transaction ID already processed |
| 409  | 400 Bad Request | Required top up amount is higher than the maximum deposit amount |
| 410  | 400 Bad Request | Transaction disallowed between wallets with different industry types |
| 412  | 400 Bad Request | Payouts for this account have been suspended |
| 413  | 400 Bad Request | One of the payout amounts is of an invalid format |
| 413  | 400 Bad Request | Payout amount is in an invalid format |
| 414  | 400 Bad Request | Insufficient balance in source wallet account to make a payout |
| 415  | 400 Bad Request | Exceeded threshold limit for payouts |
| 416  | 400 Bad Request | Record not found |
| 417  | 400 Bad Request | Could not approve a timed out credit payout request |
| 418  | 400 Bad Request | Could not approve a failed credit payout request |
| 419  | 400 Bad Request | Could not approve a declined credit payout request |
| 420  | 400 Bad Request | Credit payout request already approved |
| 500  | 500 Internal Server Error | Request Transfer failed due to internal error |
