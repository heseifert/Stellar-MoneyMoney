-- Inofficial Stellar (XLM) Extension for MoneyMoney
-- Fetches Stellar (XLM) quantity for addresses via Stellar Horizon API
-- Fetches Stellar (XLM) price in EUR via cryptonator API
-- Returns cryptoassets as securities
--
-- Username: Stellar Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2017 heseifert

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.2,
  description = "Include your Stellar as cryptoportfolio in MoneyMoney by providing Stellar (XLM) addresses as usernme (comma seperated) and a random Password",
  services= { "Stellar" }
}

local stellarAddress
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Stellar"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  stellarAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Stellar",
    accountNumber = "Crypto Asset Stellar",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestStellarPrice()

  for address in string.gmatch(stellarAddress, '([^,]+)') do
    stellarQuantity = requestStellarQuantityForStellarAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = stellarQuantity,
      price = prices["price"],
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestStellarPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()["ticker"]
end

function requestStellarQuantityForStellarAddress(stellarAddress)
  response = connection:request("GET", stellarRequestUrl(stellarAddress), {})
  json = JSON(response)
  return json:dictionary()["balances"][1]["balance"]
end

-- Helper Functions

function cryptocompareRequestUrl()
  return "https://api.cryptonator.com/api/ticker/xlm-eur"
end

function stellarRequestUrl(stellarAddress)
  return "https://horizon.stellar.org/accounts/" .. stellarAddress
end
