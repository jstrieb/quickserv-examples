package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"text/template"
)

type PriceInfo struct {
	Price  string
	Symbol string
}

type PageInfo struct {
	Error  string
	Prices []PriceInfo
}

var MaxSymbols = 25
var t = template.Must(template.New("index.html").ParseFiles("templates/index.html"))

func main() {
	method := strings.ToUpper(os.Getenv("REQUEST_METHOD"))
	switch method {
	case "POST":
		doSymbolAction()
	case "GET":
		loadPage("")
	default:
		loadPage(fmt.Sprintf("Unsupported request method: %s", method))
	}
}

func parseParams() (map[string]string, error) {
	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return nil, err
	}
	valMap := make(map[string]string)
	vars := strings.Split(string(data), "&")
	for _, kv := range vars {
		splitPair := strings.Split(kv, "=")
		if len(splitPair) != 2 {
			// error
			continue
		}
		valMap[splitPair[0]] = splitPair[1]
	}
	return valMap, nil
}

func saveSymbol(symbol string) error {
	symbols, err := getSymbolMap()
	if err != nil {
		return fmt.Errorf("Error loading symbols.json: %s", err)
	}

	symbols[symbol] = true

	if len(symbols) > MaxSymbols {
		return fmt.Errorf("Cannot add symbol, maximum number of symbols is %d", MaxSymbols)
	}

	if err := writeSymbolMap(symbols); err != nil {
		return fmt.Errorf("Error writing to symbols.json: %s", err)
	}
	return nil
}

func deleteSymbol(symbol string) error {
	symbols, err := getSymbolMap()
	if err != nil {
		return fmt.Errorf("Error loading symbols.json: %s", err)
	}

	delete(symbols, symbol)

	if err := writeSymbolMap(symbols); err != nil {
		return fmt.Errorf("Error writing to symbols.json: %s", err)
	}
	return nil
}

func doSymbolAction() {
	var errString string
	defer loadPage(errString)

	params, err := parseParams()
	if err != nil {
		errString = fmt.Sprintf("Error parsing request: %s", err)
		return
	}

	symbol, ok := params["symbol"]
	if !ok {
		errString = "no symbol given"
		return
	}
	symbol = strings.ToUpper(symbol)

	action, ok := params["action"]
	if !ok {
		errString = "no action provided"
		return
	}
	action = strings.ToUpper(action)
	if action == "DELETE" {
		if err := deleteSymbol(symbol); err != nil {
			errString = err.Error()
		}
	} else if action == "SAVE" {
		if err := saveSymbol(symbol); err != nil {
			errString = err.Error()
		}
	} else {
		errString = fmt.Sprintf("bad action: %s", action)
	}
}

func loadPage(errString string) {
	pricesInfo := make([]PriceInfo, 0)
	defer func() {
		pi := PageInfo{
			Error:  errString,
			Prices: pricesInfo,
		}
		if err := t.Execute(os.Stdout, pi); err != nil {
			fmt.Println(err)
		}
	}()
	if errString != "" {
		return
	}

	symbols, err := getSymbolMap()
	if err != nil {
		errString = err.Error()
		return
	}
	for k := range symbols {
		price, err := getPriceForSymbol(k)
		if err != nil {
			price = err.Error()
		}
		pricesInfo = append(pricesInfo, PriceInfo{
			Price:  price,
			Symbol: k,
		})
	}
}

func getPriceForSymbol(symbol string) (string, error) {
	url := "https://api.binance.com/api/v3/avgPrice?symbol=" + symbol + "USDC"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}

	defer res.Body.Close()

	priceData := make(map[string]interface{})
	if err := json.NewDecoder(res.Body).Decode(&priceData); err != nil {
		return "", err
	}

	price, ok := priceData["price"]
	if !ok {
		msg, ok := priceData["msg"]
		if ok {
			msgStr, ok := msg.(string)
			if ok {
				return "", fmt.Errorf(msgStr)
			}
		}
		return "", fmt.Errorf("bad response from binance api")
	}
	priceStr, ok := price.(string)
	if !ok {
		return "", fmt.Errorf("returned price was not a string")
	}
	return priceStr, nil
}

func getSymbolMap() (map[string]bool, error) {
	symbols := make(map[string]bool, 0)
	data, err := ioutil.ReadFile("symbols.json")
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return nil, err
	} else if errors.Is(err, os.ErrNotExist)  {
		return symbols, nil
	}
	if err := json.Unmarshal(data, &symbols); err != nil {
		return nil, err
	}
	return symbols, nil
}

func writeSymbolMap(symbols map[string]bool) error {
	data, err := json.Marshal(symbols)
	if err != nil {
		return err
	}

	return ioutil.WriteFile("symbols.json", data, os.ModePerm)
}
