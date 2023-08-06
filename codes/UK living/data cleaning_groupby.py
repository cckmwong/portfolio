#Find the required data for each local authority, e.g. housing prices, Key Stage 2 results, etc. 
dataset.drop(dataset[dataset['KS2_Avg'] == 0].index, inplace=True)
grouped = dataset.groupby(['LA code'],as_index=False).mean() 
