#Find the required data for each local authority, e.g. housing prices, Key Stage 2 results, etc. 
dataset.drop(dataset[dataset['KS2_Avg'] == 0].index, inplace=True)
grouped = dataset.groupby(['LA code'],as_index=False).mean() 

#Normalization of different indicators
dataset['KS2_norm'] = (dataset['KS2_Avg'] - dataset['KS2_Avg'].min())/ (dataset['KS2_Avg'].max()-dataset['KS2_Avg'].min())

#For normalizing Income Deprivation and Crime, the normalized value is substracted by 1, as a lower value represents a higher affluency or better safety respectively
dataset['ID_norm'] = 1- ((dataset['AvgID'] - dataset['AvgID'].min())/ (dataset['AvgID'].max()-dataset['AvgID'].min()))
