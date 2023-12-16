# read files
df <- read.table("data/train.csv", sep=',', header=T)
store_item_nbrs <- read.table("model/store_item_nbrs.csv", sep=',', header=T)

# знову рахуємо те саме що і на попердньому степі - логарифм + 1, для тих самих цілей
df$log1p <- log1p(df$units)

# рахуємо дні від початку трейн датасету
origin <- as.integer(floor(julian(as.POSIXlt('2012-01-01'))))
df$date2j <- as.integer(floor(julian((as.POSIXlt(df$date))))) - origin

# викидаємо 2013-12-25 (підглянуто) Чому викидаємо? Бо це день різдва - дані не репрезентативні
# можливо можна викинути ще чорну п*ятницю і тд, але це треба тестувати
date_excl <- as.integer(floor(julian(as.POSIXlt('2013-12-25')))) - origin
df <- df[df$date2j != date_excl, ]

# пустий дата фрейм де data2j - дата від початку тесту, sno - номер стору ino - номер айтему
df_fitted <- data.frame(date2j=c(), sno=c(), ino=c())

# просто сіквенс шоб пройти фором від 1 до store_item_nbrs
rng <- 1:nrow(store_item_nbrs)

for (i in rng) {
  ino <- store_item_nbrs[i, "item_nbr"]
  sno <- store_item_nbrs[i, "store_nbr"]
  # беремо дати коли ЦЕЙ ТОВАР В ЦЬОМУ МАГАЗИНІ продавався
  df0 <- subset(df, store_nbr == sno & item_nbr == ino)
  # юзаємо поліноміальну регресію з ПЕНАЛЬТІ, бо залежність між елементами датасету поліноміальна (скоріше за все)
  # nterms і max.terms метрики для тренування моделі
  # log1p ~ date2j - кажемо шо нас цікавить залежність між датою з початку тестування і к-тю продажів (тренд), і це все В РАМКАХ ОДНОГО ПРОДУКТУ І ОДНОГО МАГАЗИНУ
  # тобто date2j це вхідний параметр фукції, а log1p це те що ми хочемо отримувати при предікті
  df0.ppr <- ppr(log1p ~ date2j, data = df0, nterms=3, max.terms=5)

  # новий дата фрейм для ЦЬОГО СТОРУ І ТОВАРУ, date2j це дата від початку, може бути від 0 до 1034 (просто кінець датасету)
  df1 <- data.frame(date2j=0:1034, store_nbr=sno, item_nbr=ino)
  # пихаємо сюди все запредікчене для всього датасету для цього стору і айтему. Тобто нові дані тут тільки дати
  # Тобто тут буде предікт і для дат по яким немає інформації
  df1$ppr_fitted <- predict(df0.ppr, df1)
  
  #plot(df0$date2j, df0$log1p, main=paste(c("result", ino, sno)))
  #lines(newdf$date2j, newdf$gampred, col="red")
  #lines(newdf$date2j, newdf$pprpred, col="blue")

  # додаємо результат предікту в пустий датафрейм
  df_fitted <- rbind(df_fitted, df1)
}

# записуємо результат предікту
write.table(df_fitted, "model/baseline.csv", quote=F, col.names=T, append=F, sep=",", row.names=F)

cat("curve fitting finished")

q("no")