# if you see KRAKOZYABRY then do 
# "File" - "Reopen with encoding" - "UTF-8" - (Set as default) - OK


Sys.setenv(LANG = "en")
#install.packages("ggplot2", dependencies=TRUE)
library(ggplot2)
#install.packages("MASS", dependencies=TRUE)
library("MASS")
#install.packages("epicalc", dependencies=TRUE)
library("epicalc")
#install.packages("outliers", dependencies = TRUE)
library("outliers")
#install.packages("rpart", dependencies = TRUE)
library("rpart")
#install.packages("randomForest", dependencies = TRUE)
library("randomForest")
#install.packages("C50", dependencies = TRUE)
library("C50")









#��������� ������ �� �����
bankruptcy <- read.csv(file="�����������-�.csv",stringsAsFactors = FALSE, header=TRUE, sep=";")
bankruptcy <- as.data.frame(sapply(bankruptcy, gsub, pattern=",",replacement="."))
for (i in 2:6) bankruptcy[,i]  <- as.numeric(as.character(bankruptcy[,i]))



#��������� �� ���� ������
summary(bankruptcy)
boxplot(�����������.������� ~ ������� , data = bankruptcy, xlab = "����������� �������", ylab = "�������", main = "����������� ����������� �� ����������� �������")
boxplot(��������������.������� ~ ������� , data = bankruptcy, xlab = "�������������� �������", ylab = "�������", main = "����������� ����������� �� �������������� �������")
boxplot(����������.������� ~ ������� , data = bankruptcy, xlab = "���������� �������", ylab = "�������", main = "����������� ����������� �� ���������� �������")
boxplot(������������ ~ ������� , data = bankruptcy, xlab = "������������", ylab = "�������", main = "����������� ����������� �� ������������ �������")
boxplot(���������������.������� ~ ������� , data = bankruptcy, xlab = "���������������.�������", ylab = "�������", main = "����������� ����������� �� ��������������� �������")

bankruptcy <- bankruptcy[ which(bankruptcy$������������ < 30 ), ]
bankruptcy <- bankruptcy[ which(bankruptcy$��������������.������� > -6), ]
bankruptcy <- bankruptcy[ which(bankruptcy$����������.������� > -6), ]
bankruptcy <- bankruptcy[ which(bankruptcy$���������������.������� < 10), ]
bankruptcy <- bankruptcy[ which(bankruptcy$����������.������� > -6), ]

#������� �������� �������
summary(bankruptcy)
boxplot(��������������.������� ~ ������� , data = bankruptcy, xlab = "�������������� �������", ylab = "�������", main = "����������� ����������� �� �������������� �������")
boxplot(����������.������� ~ ������� , data = bankruptcy, xlab = "���������� �������", ylab = "�������", main = "����������� ����������� �� ���������� �������")
boxplot(������������ ~ ������� , data = bankruptcy, xlab = "������������", ylab = "�������", main = "����������� ����������� �� ������������ �������")
boxplot(���������������.������� ~ ������� , data = bankruptcy, xlab = "���������������.�������", ylab = "�������", main = "����������� ����������� �� ��������������� �������")



#��������������� ���� ������� �� �������� � �����������
ind1 <- subset(bankruptcy, bankruptcy[,"�������"]==1, select=ID: �������)
ind0 <- subset(bankruptcy, bankruptcy[,"�������"]==0, select=ID: �������)
sampind1 <- ind1[sample(1:nrow(ind1), 53, replace=FALSE),]
sampind0 <- ind0[sample(1:nrow(ind0), 158, replace=FALSE),]

training_data <- rbind(sampind0, sampind1)
testing_data <- bankruptcy[!(bankruptcy$ID %in% training_data$ID),]
rownames(training_data)<-NULL
rownames(testing_data)<-NULL
rm(ind0, ind1, sampind0, sampind1, i)
clear_test <- subset(testing_data, select=�����������.�������:�������)

#������ ������������� ���������, ���������, ��� ������������ ���� ������ �� �����������
glm.out <- step(glm(������� ~ �����������.������� + ��������������.������� + ����������.������� + ���������������.�������, family=binomial, data=training_data))
summary(glm.out)
confint(glm.out)
exp(glm.out$coefficients)
exp(confint(glm.out))

#�������� ���������� ��������
testing_data$predicted_value_log <-  predict(glm.out, newdata = clear_test, type = "response")
convert <- function(data){if(data >= 0.5)return (1) else return (0)}
testing_data$predicted_value_log <- lapply(testing_data$predicted_value_log, convert)

#������ ������������� ������
reg_tree <- rpart(������� ~ ., data = clear_test, method = "anova")
printcp(reg_tree)
plotcp(reg_tree) # ������� ������ �����-���������
summary(reg_tree) 

rsq.rpart(reg_tree) # visualize cross-validation results    

# plot tree 
plot(reg_tree, uniform=TRUE, main="������ ���������")
text(reg_tree, use.n=TRUE, all=TRUE, cex=.8)

#������ ������
testing_data$predicted_value_regtree <- predict(reg_tree,  testing_data, type = c("vector", "prob", "class", "matrix"), na.action = na.pass)
correct <- function(data){if(data >= 0.5)return (1) else return (0)}
testing_data$predicted_value_regtree <- testing_data$predicted_value_regtree - 1
testing_data$predicted_value_regtree <- lapply(testing_data$predicted_value_regtree, correct)


#����� random forests
fit <- randomForest(������� ~  ., data=clear_test)
print(fit) # view results 
importance(fit) # importance of each predictor

#������ ������
testing_data$predicted_value_random <-predict(fit, testing_data, type="response" )


#�������� C.5.0
reg_tree_c50 <- C5.0(x = training_data[, -6], y = training_data$�������)
testing_data$predicted_value_regtree50 <- predict(reg_tree_c50,  clear_test)
summary(reg_tree_c50)




