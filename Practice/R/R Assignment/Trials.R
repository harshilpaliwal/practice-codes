install.packages('lattice')
install.packages("ggplot2")
install.packages("tidyverse")
install.packages("funModeling")
install.packages("dplyr")
library('lattice')
library('ggplot2')
library(tidyverse)
library('funModeling')
library(dplyr)
myData<-select('yield')
myData

barley %>% group_by(yield) %>% select(group_cols())
select(yield)

select

group_by('yield', 'year')

