import requests  
import pandas as pd
import re
from bs4 import BeautifulSoup 

RICs = ['TSCO.L', 'SBRY.L', '3382.T', 'CARR.PA', 'AXFO.ST', 'KR.N', 'WMT.N'] #ticker list

dataset = {} #create a dictionary for containing the financial summary data for every ticker

#iterate every ticker for webscrapping
for RIC in RICs:
    #request the HTML codes of a particular ticker via API
    data = requests.get(f'http://api.scraperapi.com?api_key=ab037e18ebb50bc07cdb9ce0f2c991d2&url=https://www.reuters.com/markets/companies/{RIC}/').content
    #data = requests.get(f'https://www.reuters.com/markets/companies/{RIC}/').content
    soup = BeautifulSoup(data, "html.parser")

    #look for html tag <dd> with specified classes with the use of wildcard 
    table_rows1 = soup.find_all("dd", {"class": re.compile('text__text__1FZLe text__dark-grey__3Ml43 text__medium__1kbOh*')})
    table_rows2 = soup.find_all("dd", {"class": re.compile('text__text__1FZLe text__dark-grey__3Ml43 text__regular__2N1Xr*')})
    summary_data = pd.DataFrame(columns=["RIC", "Previous Close", "Open", "Volume", "3 Month Average Trading Volume", "Shares Out (Mil)", "Market Cap", "Forward P/E", "Dividend Yield", "P/E Excl. Extra Items (TTM)", "Price To Sales (TTM)", "Price To Book (Quarterly)", "Price To Cash Flow (Per Share TTM)", "Total Debt/Total Equity (Quarterly)", "Long Term Debt/Equity (Quarterly)", "Return On Investment (TTM)", "Return On Equity (TTM)"])

    #extracting relevant data from the above html code
    close = table_rows1[0].text
    open = table_rows1[1].text
    volume = table_rows1[2].text
    trading_vol = table_rows1[3].text
    shares = table_rows1[4].text
    market_cap = table_rows1[5].text
    forward_PE = table_rows1[6].text
    dividend_yield = table_rows1[7].text
    
    PER = table_rows2[0].text
    PS = table_rows2[1].text
    PB = table_rows2[2].text
    PCF = table_rows2[3].text
    total_gearing = table_rows2[4].text
    longterm_gearing = table_rows2[5].text
    ROI = table_rows2[6].text
    ROE = table_rows2[7].text

    #fill in the columns of the summary_data table    
    summary_data = summary_data.append({"RIC": RIC, "Previous Close":close, "Open":open, "Volume":volume, "3 Month Average Trading Volume": trading_vol, "Shares Out (Mil)": shares, "Market Cap": market_cap, "Forward P/E": forward_PE, "Dividend Yield": dividend_yield, "P/E Excl. Extra Items (TTM)": PER, "Price To Sales (TTM)": PS, "Price To Book (Quarterly)": PB, "Price To Cash Flow (Per Share TTM)": PCF, "Total Debt/Total Equity (Quarterly)": total_gearing, "Long Term Debt/Equity (Quarterly)": longterm_gearing, "Return On Investment (TTM)": ROI, "Return On Equity (TTM)": ROE}, ignore_index=True)

    #fill in the dictionary with the summary_data for every ticker using RIC as the key
    dataset[RIC] = summary_data

Summary = pd.concat(dataset) #merge the summary_data of all tickers into a dataframe called Summary
Summary = Summary.reset_index(drop = True) #reset the new index for the merged dataframe

Summary
