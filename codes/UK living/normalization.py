#Use of Python codes for normalization
dataset['KS2_norm'] = (dataset['KS2_Avg'] - dataset['KS2_Avg'].min())/ (dataset['KS2_Avg'].max()-dataset['KS2_Avg'].min())

#Normalization of Income Deprivation and Crime
#Normalized value is substracted by 1, as a lower value represents a higher affluency or better safety respectively
dataset['ID_norm'] = 1- ((dataset['AvgID'] - dataset['AvgID'].min())/ (dataset['AvgID'].max()-dataset['AvgID'].min()))
