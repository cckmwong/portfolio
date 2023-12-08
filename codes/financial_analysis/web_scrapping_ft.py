import requests  
import pandas as pd
import re
from bs4 import BeautifulSoup 

FT_Tickers = ['AXFO:STO', 'CA:PAR', 'SBRY:LSE', 'KR:NYQ', '3382:TYO', 'TSCO:LSE', 'WMT:NYQ']

dataset = {} #create a dictionary for containing the financial summary data for every ticker

for FT_Ticker in FT_Tickers:
    data = requests.get(f'https://markets.ft.com/data/equities/tearsheet/summary?s={FT_Ticker}').content
    soup = BeautifulSoup(data, "html.parser")

    tables = soup.find_all('table')
    rows1 = tables[1].find_all("td")
    rows2 = tables[2].find_all("td")
    
    summary_data = pd.DataFrame(columns=["Market Cap", "Shares Outstanding", "Free_Float", "Dividend Yield"])

    market_cap = rows1[4].text
    PE = rows1[3].text
    div_yield = rows2[1].text
    shares_out = rows1[1].text
    free_float = rows1[2].text
    
    summary_data = summary_data.append({"FT Ticker": FT_Ticker, "Market Cap": market_cap, "Shares Outstanding": shares_out, "Free_Float": free_float, "P/E (TTM)": PE, "Dividend Yield": div_yield}, ignore_index=True)
    summary_data["Shares Outstanding_num"] = summary_data["Shares Outstanding"].str.extract(r'(\d+.\d+)').astype('float')
    summary_data["Free Float_num"] = summary_data["Free_Float"].str.extract(r'(\d+.\d+)').astype('float')
    summary_data["Free Float"] = summary_data["Free Float_num"]/ summary_data["Shares Outstanding_num"]
    dataset[FT_Ticker] = summary_data

Summary = pd.concat(dataset) #merge the summary_data of all tickers into a dataframe called Summary
Summary = Summary.reset_index(drop = True) #reset the new index for the merged dataframe
