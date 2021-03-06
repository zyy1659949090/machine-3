library(caret)
library(dplyr)
library(GGally)

"Given that the training file has been downloaded, read file into R"
#given that the training file has been downloaded, read file into r
readTrainingData <- function() {
	set.seed(1234)
	pml <- read.csv( "pml-training.csv" )
	intrain <- createDataPartition(y=pml$classe, p=0.7, list=F )
	training <- pml[intrain,]
	testing <- pml[-intrain,]
	list( training, testing)
}

readTestData <- function() {
	read.csv("pml-testing.csv")
}


filterFields <- function( pml, exercise, classe = TRUE ) { 
	exercise <- paste( '_', exercise, sep = '' )
	exercise_all <- names(pml)[ grepl( exercise, names(pml) ) & !grepl('max|min|kurto|skew|avg|stddev|amplit|total|var', names(pml) ) ]
	exercise1 <- exercise_all[ !grepl('_x|_y|_z', exercise_all) ]
	exercise2 <- exercise_all[ grepl('gyros', exercise_all) ]
	exercise3 <- exercise_all[ grepl('accel', exercise_all) ]
	exercise4 <- exercise_all[ grepl('magnet', exercise_all) ]

	if ( classe ) {
		exercise1 <- c(exercise1, 'classe')
		exercise2 <- c(exercise2, 'classe')
		exercise3 <- c(exercise3, 'classe')
		exercise4 <- c(exercise4, 'classe')
	}

	list( exercise1, exercise2, exercise3, exercise4 )
}


#Given an exercise, pull out fields for prediction.  The fields only available for groups of records (a particular window) will not be used.
exerciseFields <- function( pml, exercise ) {
	exs <- filterFields( pml, exercise, FALSE )
	total <- c()
	for( x in exs ) {
		total <- c(total, x)
	}
	total
}


#Given pml training data, pull out the fields to be used for prediction
bestFields <- function( pml ) {
	belts <- exerciseFields( pml, 'belt' )
	arms <- exerciseFields( pml, '_arm' )
	forearms <- exerciseFields( pml, 'forearm' )
	dumbbells <- exerciseFields( pml, 'dumbbell' )

	c( belts, arms, forearms, dumbbells )
}

#Writes answers to files to be uploaded
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}


#Cross validation
getTrainingTest <- function( pml ) {
	inTrain <- createDataPartition(y=pml$Species, p=0.7, list=FALSE)
	training <- pml[inTrain,]
	testing <- pml[-inTrain,]
	list( training, testing)
}


#Create model

modelPML <- function() {
	print( Sys.time() )
	pml <- readTrainingData()
	bests <- bestFields( pml )
	bests <- c( bests, 'classe' )
	pml.bests <- pml[ bests ]
	mdl <- train( classe ~ ., method = 'rf', preprocess = c('BoxCox', 'pca'), data = pml.bests )
	print( Sys.time() )
	mdl
}
