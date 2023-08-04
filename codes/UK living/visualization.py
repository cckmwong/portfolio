#Correlation Matrix
import matplotlib.pyplot as plt
import seaborn as sb
sb.heatmap(dataset.corr(), cmap = "Blues", linecolor = "white", linewidth = 5, annot = True, alpha = 0.8)
plt.title("Correlation Matrix of KS2 results against different factors ")
plt.tight_layout()
plt.show()

#Regression Plot 
import matplotlib.pyplot as plt
import seaborn as sb
sb.regplot(x="KS4_disadvantaged", y="KS4_Avg", data=dataset)
plt.ylim(0,) # set the y-limits of the current axes
plt.title("High correlation between % of disadvantaged students and KS4 results")

#Boxplot
import matplotlib.pyplot as plt
import seaborn as sb
sb.boxplot(x="Ofsted", y="KS2_Avg", data=dataset, order=["Outstanding", "Good", "Requires improvement"]) 
plt.title("Boxplot of KS2 Results and Ofsted Ratings")
plt.tight_layout()
plt.show()

#Heatmap
import matplotlib.pyplot as plt
import seaborn as sb

dataset2 = dataset[(dataset['Ofsted'] == 'Requires improvement') | (dataset['Ofsted'] == 'Good')| (dataset['Ofsted'] == 'Outstanding')]
a = ['Outstanding', 'Good', 'Requires improvement']
b = ['Boys', 'Girls', 'Mixed']
grouped_KS2  = dataset2.groupby(['Ofsted', 'Gender'],as_index=False).mean()
grouped_pivot = grouped_KS2.pivot('Ofsted','Gender', 'KS2_Avg')
grouped_pivot = grouped_pivot.reindex(index=a, columns=b)

sb.heatmap(grouped_pivot, cmap = "YlOrRd", linecolor = "white", linewidth = 1, annot = True, alpha = 0.8, fmt=".0f")
plt.title('Heat Map of Key Stage 2 Results')
plt.tight_layout()
plt.show()
