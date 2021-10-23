# Crypto Dashboard

A simple web application to view real time cryptocurrency prices (in [USDC](https://www.circle.com/en/usdc))

## Building

Install [go](https://golang.org/)

Run `go build index.go` from this folder

## Usage

Install [quickserv](https://github.com/jstrieb/quickserv/)

Run `quickserv` from this folder

Visit [http://192.168.4.22:42069](http://192.168.4.22:42069) in your web browser. Enter a symbol for a cryptocurrency (ex BTC) and click SAVE. Now any time you visit the above URL, you can see up-to-date prices for your cryptocurrency as reported by the [Binance API](https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md)
