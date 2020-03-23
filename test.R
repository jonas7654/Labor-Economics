attach(empdata_minwage)

period = empdata_minwage %>%
  select(period)

dummy_dataframe = as.data.frame(matrix(nrow = length(t(period)),ncol = length(min(period):max(period))))
colnames(dummy_dataframe) = paste("period",1:length(dummy_dataframe),sep = "")


for (i in 1:length(min(period):max(period))){
  k = (i + min(period) -1)
  period_dummy = paste("period",i,sep = "")
  dummy_dataframe[,i] = (assign(period_dummy,as.numeric(period == k))) 
}




dubelesterreich_minwage = read_dta(file = "~/Documents/Programming/R/Labor Economics [2020]/Data for PS2/dubelesterreich_minwage.dta")



minwage = rep(0,length(dubelesterreich_minwage$st_mw))

for (i in 1:length(t(minwage))){
  if (is.na(dubelesterreich_minwage$st_mw[i] == TRUE)){
    minwage[i] = dubelesterreich_minwage$fed_mw[i] 
  } else if (dubelesterreich_minwage$st_mw[i] > dubelesterreich_minwage$fed_mw[i]){
    minwage[i] = dubelesterreich_minwage$st_mw[i]
  } else if (dubelesterreich_minwage$st_mw[i] == dubelesterreich_minwage$fed_mw[i]){
    minwage[i] = dubelesterreich_minwage$st_mw[i]
  } else {
    minwage[i] = dubelesterreich_minwage$fed_mw[i]
  }
}

mean_stwage = dubelesterreich_minwage %>%
  na.omit(dubelesterreich_minwage$st_mw) %>%
  group_by(year) %>%
  arrange(year) %>%
  summarise(mean_st = mean(st_mw)) %>%
  select(mean_st)


mean_minwage_fed = data.frame(mean_fedwage,mean_minwage) %>%
  select(-year.1) %>%
  pivot_longer()
