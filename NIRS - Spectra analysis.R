library("prospectr")
library("CORElearn")
library("caret")
library("randomForest")
library("ggplot2")

dir_csvdata <- "/Path"
conf_name <- "Default"
sample_type <- "Pharmaceutical"
int_configrows_remove <- 27
int_nwavelengths <- 225

createCsvDataFrame <- function(workingDirectory, configuration) {
  
  # Retrieve list of files and sample names.
  setwd(workingDirectory)
  fileList <- list.files(pattern="*.csv")
  sample_names <- strsplit(fileList, configuration)
  sample_names <- sapply(sample_names, function(x) {
    x <- unlist(x[1])[1]
  })
  
  # Load and clean data.
  options(stringsAsFactors = FALSE)
  spectra_df <- data.frame(matrix(nrow = 0, ncol = int_nwavelengths))
  for(i in 1:length(fileList)) {
    csvdata <- read.table(fileList[i], sep=",", fill = TRUE)
    csvdata <- csvdata[int_configrows_remove:nrow(csvdata),1:2]
    colnames(csvdata) <- c("Wavelength", "Absorbance")
    if(i == 1) {
      colnames(spectra_df) <- as.integer(csvdata$Wavelength)
    }
    csvdata <- csvdata[,-1]
    spectra_df[i,] <- as.numeric(csvdata)
  }

  spectra_df["Pharmaceutical"] <- unique(sample_names)
  
  return(spectra_df)
}

# Load and structure data
setwd(dir_csvdata)
fileList <- list.files()
spectra_df <- data.frame(matrix(nrow = 0, ncol = 225))
i <- 1
for(i in 1:length(fileList)) {
  temp_dir <- paste0(dir_csvdata, fileList[i])
  temp_df <- createCsvDataFrame(temp_dir, conf_name)
  spectra_df <- rbind(spectra_df, temp_df)
}


# Preprocess
type_col <- spectra_df[,ncol(spectra_df)]
# Savitzky–Golay
spectra_df <- savitzkyGolay(spectra_df[,-ncol(spectra_df)], p = 3, w = 11, m = 1)
# SNV
spectra_df <- scale(t(spectra_df), center=TRUE)
spectra_df <- as.data.frame(t(spectra_df))
spectra_df[sample_type] <- type_col


# Feature evaluation
# MDL
MDL <- attrEval(Pharmaceutical~ ., spectra_df, estimator = "MDL")
# Gini
Gini <- attrEval(Pharmaceutical~ ., spectra_df, estimator = "Gini")
# RF
control <- trainControl(method="cv", number=10)
model <- train(Pharmaceutical~., data=spectra_df, method="rf", trControl=control)
importance <- varImp(model, scale=FALSE)
RF <- importance[[1]]$Overall
# Plotting:
# x <- Wavelengths
# y <- MDL / Gini / RF


# Number of variables vs accuracy
type_col <- ncol(spectra_df)
data_col <- ncol(spectra_df)-1
# RF function
control <- rfeControl(functions=rfFuncs, method="cv", number=10)
rfe_rf <- rfe(spectra_df[,1:data_col], spectra_df[,type_col], sizes=c(1:data_col), rfeControl=control)
# NB function
control2 <- rfeControl(functions=nbFuncs, method="cv", number=10)
rfe_nb <- rfe(spectra_df[,1:data_col], spectra_df[,type_col], sizes=c(1:data_col), rfeControl=control2)
# Plotting:
# x <- unlist(rfe_rf$results["Variables"]) // x <- unlist(rfe_nb$results["Variables"])
# y <- unlist(rfe_rf$results["Accuracy"]) // y <- unlist(rfe_nb$results["Accuracy"])


# K-Means clustering
# Cluster varience
within_vector <- c()
for(i in 1:20) {
  km1 = kmeans(spectra_df[1:data_col], i, nstart=100)
  within_vector[i] <- km1$tot.withinss/km1$totss
}
# K-means clustering and plot with dimensionality reduction.
kms <- naes(X = spectra_df[1:data_col], k = 2, pc = 2, iter.max = 100)
Clusters <- as.factor(kms$cluster)
df_pcs <- as.data.frame(kms$pc)
# Plotting:
# x <- df_pcs$PC1
# y <- df_pcs$PC2
# col = Clusters