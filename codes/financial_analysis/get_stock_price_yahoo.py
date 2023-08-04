#Python code to extract the stock price dynamically from Yahoo.Finance
#Since Yahoo uses Unix Time Stamp (Epoch) in the HTML link, the current time and start time (set as 2 years ago) is converted as Epoch time first using Python code

from datetime import date
import time
import calendar
from datetime import datetime
from dateutil.relativedelta import relativedelta
import pandas as pd

now = datetime.now() #get today's date

last2year = now + relativedelta(years=-2) #get the date 2 years ago from today

current_date_and_time = time.time() #get the current epoch time

LastDate = int(current_date_and_time) #change the current date into integer format so as to fit into CSV link below

last2year_string = last2year.strftime("%a %b %d %H:%M:%S %Y")

StartDate = int(calendar.timegm(time.strptime(last2year_string))) #get the epoch time for the date 2 years ago and convert it to integer

Tickers = ['TSCO.L', 'SBRY.L', '3382.T', 'CA.PA', 'AXFO.ST', 'KR', 'WMT'] #ticker list

dataset = {} #create a dictionary object for containing the stock price for every ticker

#iterate each ticker in the ticker list
for Ticker in Tickers:
        #read the csv file dynamically for every ticker
	df = pd.read_csv(f'https://query1.finance.yahoo.com/v7/finance/download/{Ticker}?period1={StartDate}&period2={LastDate}&interval=1d&events=history&includeAdjustedClose=true')
	df['Ticker'] = Ticker
	dataset[Ticker] = df
	#time.sleep(1)

StockPrice = pd.concat(dataset) #put stock prices of all tickers together in one table 
StockPrice = StockPrice.reset_index(drop = True) #reser the index
