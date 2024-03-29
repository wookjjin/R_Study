# 로지스틱 회귀분석(분류) <- weather.csv로 내일 비 유무 분류예측 모델
weather <- read.csv('testdata/weather.csv')
head(weather, 5)
dim(weather) # 366 15
str(weather)

weather_df <- weather[, c(-1, -6, -8, -14)] # Date 등의 일부 열은 제외
head(weather_df)

# NA가 있는 행 찾기
weather_df[!comp]
# RainTomorrow는 더미변수(명목척도화 : 변수값을 0과 1로 변환)로 변환
weather_df$RainTomorrow[weather_df$RainTomorrow == 'Yes'] <- 1
weather_df$RainTomorrow[weather_df$RainTomorrow == 'No'] <- 0
weather_df$RainTomorrow <- as.numeric(weather_df$RainTomorrow)
head(weather_df)
str(weather_df)

# train / test
idx <- sample(1:nrow(weather_df), nrow(weather_df) * 0.7)
train <- weather_df[idx, ]
test <- weather_df[-idx, ]
dim(train)  # 256 11
dim(test)   # 110 11

# 모델
wmodel <- glm(RainTomorrow ~ ., data = train, family = 'binomial')
wmodel
summary(wmodel)
# 결과를 볼 때 일부 변수는 제외하는 것이 효과적

# 모델 평가
pred <- predict(wmodel, newdata = test, type = 'response')
head(pred, 10)
head(test$RainTomorrow[1:10])

result_pred <- ifelse(pred > 0.5, 1, 0)

table(result_pred)  # 빈도 표

# 모델 평가표 (Confusion matrix : 혼돈행렬)
t <- table(result_pred, test$RainTomorrow)
sum(diag(t)) / nrow(test)

# RocCurve로 모델 평가
install.packages("ROCR")
library(ROCR)

pr <- prediction(pred, test$RainTomorrow) # 예측값, 실제값값
pr

prf <- performance(pr, measuer = 'tpr', x.measure = 'fpr')
plot(prf)

# AUC : ROC Curve의 밑면적을 계산한 값. 1에 가까울수록 좋음
auc <- performance(pr, measure = 'auc')
auc

auc <- auc@y.values[[1]]
auc

# 새 값으로 예측
new_data <- train[c(1:3), ]
new_data <- edit(new_data)
new_data

new_pred <- predict(wmodel, newdata = new_data, type='response')
new_pred
ifelse(new_pred > 0.5, '비옴', '비안옴')
