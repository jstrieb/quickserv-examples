# Crypto Dashboard

View real time cryptocurrency prices (in [USDC](https://www.circle.com/en/usdc)).

## Building

Install [Go](https://golang.org/) and run `go build index.go` from this folder.

## Usage

Run `quickserv` from this folder. Then, visit
[http://localhost:42069](http://localhost:42069) in your web browser. 

On the site, enter a symbol for a cryptocurrency (e.g. "BTC") and click "SAVE."
Now any time you visit the URL, you can see up-to-date prices for your
cryptocurrency as reported by the [Binance
API](https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md).
