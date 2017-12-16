library(leaflet)

foo=read.csv("C:/Users/jrodr/Documents/RBlog/transMed_V3/mbta_full_orange.csv")

leaflet(data=foo) %>% addTiles() %>% addMarkers(~Longitude, ~Latitude, popup = ~as.character(Station_Name))


plot_ly(mbta, x=~Longitude, y=~Latitude, type="scatter", mode="line", line = list(color="orange", width=6), hoverinfo="none") %>%
  add_trace(x = ~Longitude, y=~Latitude, type="scatter", mode="markers", marker=list(color="black", size=8), hoverinfo= 'text',
            text = ~paste('</br> Station Name:', Station_Name,
                          '</br> Income:', Income,
                          '</br> Tract:', tract)) %>%
  layout(title="Median Income Along the T", showlegend=FALSE, xaxis=list(title="", tickangle=-90), yaxis=list(title="Median Household Income"), margin=list(b=160))



#library(tidycensus)
#library(ggplot2)
#library(viridis)
#library(tidyverse)

#census_api_key("b305d416b1bf92ddfec1ab1718f2f96aeed0398f", install = TRUE)

#foo = get_acs(geography='tract', variables = "B19013_001E", state="MA", year = 2015, geometry = TRUE)

#head(foo)

#foo %>% ggplot(aes(fill = estimate, color = estimate)) + 
 # geom_sf() + 
  #coord_sf(crs = 26911) + 
  #scale_fill_viridis(option = "magma") + 
  #scale_color_viridis(option = "magma")

#acs2016 = load_variables(2016, "acs1")
#View(acs2016)

#tGraph = ggplot(data=mbta, aes(x=Station.Name, y=income)) + geom_line(group =1, size = 2, color="orange") + geom_point(size=4, color="black")
#tGraph = tGraph + labs(y = "Median Household Income", x="") + theme(text = element_text(size=14)) + theme(legend.position = "none")
#tGraph = tGraph + theme(axis.text.x = element_text(angle = 90))
#tGraph = tGraph + scale_y_continuous(breaks = c(0, 40000, 80000, 120000, 160000), limits = c(0,160000), labels = comma)
#tGraph
---
 # title: Income Along Boston's T Stops
#author: Jorge A Rodriguez MD
#date: '2017-12-11'
#slug: income-along-boston-s-t-stops
---

#These are the packages I used for this project: 
#```{r echo=TRUE, eval=FALSE}
#library(acs)
#library(httr)
#library(plotly)
#library(tidyverse)
#library(ggthemes)
#library(scales)
#library(ggmap)
```

#I created MBTA location csv files to help with the project.
```{r}
#Read in the MBTA File 
#mbta = read.csv("../../data/mbta_orange.csv")
#str(mbta)
```

#Some clean up: 
```{r}
#Add index column
#mbta = add_column(mbta, index=1:nrow(mbta))

#Create tract empty
mbta$tract = NaN
mbta$county = NaN

mbta$Longitude = as.numeric(mbta$Longitude)
mbta$Latitude = as.numeric(mbta$Latitude)
```

Getting Census Tracts: 
```{r echo=TRUE, eval=FALSE}
for(i in 1:nrow(mbta)) {
x= as.character(mbta$Longitude[i])
y = as.character(mbta$Latitude[i])
url = sprintf("https://geocoding.geo.census.gov/geocoder/geographies/coordinates?x=%s&y=%s&benchmark=4&vintage=4", x, y)
print(url)
r= GET(url)
g = content(r, "parsed")
print(i)
mbta$tract[i]= as.character(g$result$geographies$`Census Tracts`[[1]][17]$TRACT[[1]])
mbta$county[i] = as.character(g$result$geographies$Counties[[1]]$NAME[[1]])
}
```
Create Median Income
```{r eval=FALSE}
mbta$income = NaN

for(i in 1:nrow(mbta)) {
tract= mbta$tract[i]
my.tract=geo.make(state="MA", county=mbta$county[i], tract=mbta$tract[i])
median.income=acs.fetch(geo=my.tract, endyear=2015,  table.name ="B19013")
mbta$income[i] = as.character(estimate(median.income[1,1]))[[1]]
}
```

```{r}
#To Numeric 
mbta$income = as.numeric(mbta$income)

#factor change
mbta$Station.Name = as.character(mbta$Station.Name)
mbta$Station.Name = factor(mbta$Station.Name, levels=unique(mbta$Station.Name))

```


#plot_ly(mbta, x=~mbta$Station.Name, y=~mbta$income, type="scatter", mode="line", color = "orange")


#tGraph = ggplot(data=mbta, aes(x=Station_Name, y=Income, label=tract)) + geom_line(group =1, size = 2, color="orange") + geom_point(size=4, color="black")
#tGraph = tGraph + labs(y = "Median Household Income", x="") + theme(text = element_text(size=14)) + theme(legend.position = "none")
#tGraph = tGraph + theme(axis.text.x = element_text(angle = 90))
#tGraph = tGraph + scale_y_continuous(breaks = c(0, 40000, 80000, 120000, 160000), limits = c(0,160000), labels = comma)
#tGraph
#ggplotly(tGraph)


plot_ly(mbta, x=~Station_Name, hoverinfo = 'text',
        text = ~paste('</br> Station Name:', Station_Name,
                      '</br> Income:', Income,
                      '</br> Tract:', tract)) %>%
  add_trace(y=~Income, type="scatter", mode="line", line = list(color="orange", width=6)) %>%
  add_trace(y=~Income, type="scatter", mode="markers", marker=list(color="black", size=8)) %>%
  layout(title="Median Income Along the T", showlegend=FALSE, xaxis=list(title="", tickangle=-90), yaxis=list(title="Median Household Income", range=c(0, 200000)), margin=list(b=1s60))








