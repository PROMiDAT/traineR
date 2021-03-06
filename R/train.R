
#' create.model
#'
#' @keywords internal
#'
create.model <- function(model, formula, data,  name = NULL){
  .var                 <- as.character(formula[2])
  model$prmdt$var.pred <- .var
  model$prmdt$vars     <- formula[-2]
  model$prmdt$type     <- class(data[, .var])
  model$prmdt$levels   <- levels(data[,.var])

  if(is.null(name)){
    class(model) <- c("prmdt", class(model))
  }else{
    class(model) <- c("prmdt", name, class(model))
  }
  return(model)
}

#' train.ada
#'
#' @description Provides a wrapping function for the \code{\link[ada]{ada}}.
#'
#' @param formula  a symbolic description of the model to be fit.
#' @param data an optional data frame containing the variables in the model.
#' @param ... arguments passed to rpart.control. For stumps, use rpart.control(maxdepth=1,cp=-1,minsplit=0,xval=0). maxdepth controls the depth of
#'            trees, and cp controls the complexity of trees. The priors should also be fixed through the parms argument as discussed in the second reference.
#' @param subset an optional vector specifying a subset of observations to be used in the fitting process.
#' @param na.action a function that indicates how to process ‘NA’ values. Default=na.rpart.
#'
#' @seealso The internal function is from package \code{\link[ada]{ada}}.
#'
#' @return A object ada.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[ada]{ada}}.
#'
#' @export
#'
#' @examples
#'
#' data("Puromycin")
#'
#' n <- seq_len(nrow(Puromycin))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- Puromycin[.sample,]
#' data.test <- Puromycin[-.sample,]
#'
#' modelo.ada <- train.ada(state~., data.train)
#' modelo.ada
#' prob <- predict(modelo.ada, data.test , type = "prob")
#' prob
#' prediccion <- predict(modelo.ada, data.test , type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.ada <- function(formula, data, ..., subset, na.action = na.rpart){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(ada::ada)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  model <- eval.parent(m)
  create.model(model, formula, data, "ada.prmdt")
}

#' train.rpart
#'
#' @description Provides a wrapping function for the \code{\link[rpart]{rpart}}.
#'
#' @param formula a formula, with a response but no interaction terms. If this a a data frame, that is taken as the model frame.
#' @param data an optional data frame in which to interpret the variables named in the formula.
#' @param weights optional case weights.
#' @param subset optional expression saying that only a subset of the rows of the data should be used in the fit.
#' @param na.action the default action deletes all observations for which y is missing, but keeps those in which one or more predictors are missing.
#' @param method one of "anova", "poisson", "class" or "exp". If method is missing then the routine tries to make an intelligent guess. If y is a survival object, then method = "exp" is assumed, if y has 2 columns then method = "poisson" is assumed, if y is a factor then method = "class" is assumed, otherwise method = "anova" is assumed. It is wisest to specify the method directly, especially as more criteria may added to the function in future.
#'               Alternatively, method can be a list of functions named init, split and eval. Examples are given in the file ‘tests/usersplits.R’ in the sources, and in the vignettes ‘User Written Split Functions’.
#' @param model if logical: keep a copy of the model frame in the result? If the input value for model is a model frame (likely from an earlier call to the rpart function), then this frame is used rather than constructing new data.
#' @param x keep a copy of the x matrix in the result.
#' @param y keep a copy of the dependent variable in the result. If missing and model is supplied this defaults to FALSE.
#' @param parms optional parameters for the splitting function.
#'              Anova splitting has no parameters.
#'              Poisson splitting has a single parameter, the coefficient of variation of the prior distribution on the rates. The default value is 1.
#'              Exponential splitting has the same parameter as Poisson.
#'              For classification splitting, the list can contain any of: the vector of prior probabilities (component prior), the loss matrix (component loss) or the splitting index (component split). The priors must be positive and sum to 1. The loss matrix must have zeros on the diagonal and positive off-diagonal elements. The splitting index can be gini or information. The default priors are proportional to the data counts, the losses default to 1, and the split defaults to gini.
#' @param control a list of options that control details of the rpart algorithm. See \code{\link[rpart]{rpart.control}}.
#' @param cost a vector of non-negative costs, one for each variable in the model. Defaults to one for all variables. These are scalings to be applied when considering splits, so the improvement on splitting on a variable is divided by its cost in deciding which split to choose.
#' @param ... arguments to \code{\link[rpart]{rpart.control}} may also be specified in the call to rpart. They are checked against the list of valid arguments.
#'
#' @seealso The internal function is from package \code{\link[rpart]{rpart}}.
#'
#' @return A object rpart.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[rpart]{rpart}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.rpart <- train.rpart(Species~., data.train)
#' modelo.rpart
#' prob <- predict(modelo.rpart, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.rpart, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.rpart <- function(formula, data, weights, subset, na.action = na.rpart, method, model = TRUE, x = FALSE, y = TRUE, parms, control, cost, ...){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(rpart::rpart)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  model <- eval.parent(m)

  create.model(model, formula, data, "rpart.prmdt")
}

#' train.bayes
#'
#' @description Provides a wrapping function for the \code{\link[e1071]{naiveBayes}}.
#'
#' @param formula A formula of the form class ~ x1 + x2 + .... Interactions are not allowed.
#' @param data 	Either a data frame of predictors (categorical and/or numeric) or a contingency table.
#' @param laplace positive double controlling Laplace smoothing. The default (0) disables Laplace smoothing.
#' @param ... Currently not used.
#' @param subset For data given in a data frame, an index vector specifying the cases to be used in the training sample. (NOTE: If given, this argument must be named.)
#' @param na.action A function to specify the action to be taken if NAs are found. The default action is not to count them for the computation of the probability factors. An alternative is na.omit, which leads to rejection of cases with missing values on any required variable. (NOTE: If given, this argument must be named.)
#'
#' @seealso The internal function is from package \code{\link[e1071]{naiveBayes}}.
#'
#' @return A object bayes.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function  \code{\link[e1071]{naiveBayes}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.bayes <- train.bayes(Species ~., data.train)
#' modelo.bayes
#' prob <- predict(modelo.bayes, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.bayes, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.bayes <- function(formula, data, laplace = 0, ..., subset, na.action = na.pass){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(e1071::naiveBayes)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  model <- eval.parent(m)
  create.model(model, formula, data, "bayes.prmdt")
}

#' train.randomForest
#'
#' @description Provides a wrapping function for the \code{\link[randomForest]{randomForest}}.
#'
#' @param formula a formula describing the model to be fitted (for the print method, an randomForest object).
#' @param data an optional data frame containing the variables in the model. By default the variables are taken from the environment which randomForest is called from.
#' @param ... optional parameters to be passed to the low level function randomForest.default.
#' @param subset an index vector indicating which rows should be used. (NOTE: If given, this argument must be named.)
#' @param na.action A function to specify the action to be taken if NAs are found. (NOTE: If given, this argument must be named.)
#'
#' @seealso The internal function is from package \code{\link[randomForest]{randomForest}}.
#'
#' @return A object randomForest.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function  \code{\link[randomForest]{randomForest}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.rf <- train.randomForest(Species~., data.train)
#' modelo.rf
#' prob <- predict(modelo.rf, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.rf, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.randomForest <- function(formula, data, ..., subset, na.action = na.fail){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(randomForest::randomForest)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  if(is.null(m$importance)){
    m$importance <- TRUE
  }
  model <- eval.parent(m)
  create.model(model, formula, data, "randomForest.prmdt")
}

#' train.knn
#'
#' @description Provides a wrapping function for the \code{\link[kknn]{train.kknn}}.
#'
#' @param formula A formula object.
#' @param data Matrix or data frame.
#' @param kmax Maximum number of k, if ks is not specified.
#' @param ks A vector specifying values of k. If not null, this takes precedence over kmax.
#' @param distance Parameter of Minkowski distance.
#' @param kernel Kernel to use. Possible choices are "rectangular" (which is standard unweighted knn), "triangular", "epanechnikov" (or beta(2,2)),
#'               "biweight" (or beta(3,3)), "triweight" (or beta(4,4)), "cos", "inv", "gaussian" and "optimal".
#' @param ykernel Window width of an y-kernel, especially for prediction of ordinal classes.
#' @param scale 	logical, scale variable to have equal sd.
#' @param contrasts A vector containing the 'unordered' and 'ordered' contrasts to use.
#' @param ... Further arguments passed to or from other methods.
#'
#' @seealso The internal function is from package \code{\link[kknn]{train.kknn}}.
#'
#' @return A object knn.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[kknn]{train.kknn}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.knn <- train.knn(Species~., data.train)
#' modelo.knn
#' prob <- predict(modelo.knn, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.knn, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.knn <- function(formula, data, kmax = 11, ks = NULL, distance = 2, kernel = "optimal", ykernel = NULL,
                      scale = TRUE, contrasts = c('unordered' = "contr.dummy", ordered = "contr.ordinal"), ...){

  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(kknn::train.kknn)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  model <- eval(m, envir = parent.frame())
  create.model(model, formula, data, "knn.prmdt")
}

#' train.nnet
#'
#' @description Provides a wrapping function for the \code{\link[nnet]{nnet}}.
#'
#' @param formula A formula of the form class ~ x1 + x2 + ...
#' @param data Data frame from which variables specified in formula are preferentially to be taken.
#' @param weights (case) weights for each example – if missing defaults to 1.
#' @param ... arguments passed to or from other methods.
#' @param subset An index vector specifying the cases to be used in the training sample. (NOTE: If given, this argument must be named.)
#' @param na.action A function to specify the action to be taken if NAs are found. The default action is for the
#'                  procedure to fail. An alternative is na.omit, which leads to rejection of cases with missing
#'                  values on any required variable. (NOTE: If given, this argument must be named.)
#' @param contrasts a list of contrasts to be used for some or all of the factors appearing as variables in the model formula.
#'
#' @seealso The internal function is from package \code{\link[nnet]{nnet}}.
#'
#' @return A object nnet.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[nnet]{nnet}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.nn <- train.nnet(Species~., data.train, size = 20)
#' modelo.nn
#' prob <- predict(modelo.nn, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.nn, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.nnet <- function(formula, data, weights, ..., subset, na.action, contrasts = NULL){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(nnet::nnet)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  model <- eval.parent(m)
  create.model(model, formula, data, "nnet.prmdt")
}

#' train.neuralnet
#'
#' @description Provides a wrapping function for the \code{\link[neuralnet]{neuralnet}}.
#'
#' @param formula a symbolic description of the model to be fitted.
#' @param data a data frame containing the variables specified in formula.
#' @param hidden a vector of integers specifying the number of hidden neurons (vertices) in each layer.
#' @param threshold a numeric value specifying the threshold for the partial derivatives of the error function as stopping criteria.
#' @param stepmax the maximum steps for the training of the neural network. Reaching this maximum leads to a stop of the neural network's training process.
#' @param rep the number of repetitions for the neural network's training.
#' @param startweights a vector containing starting values for the weights. Set to NULL for random initialization.
#' @param learningrate.limit a vector or a list containing the lowest and highest limit for the learning rate. Used only for RPROP and GRPROP.
#' @param learningrate.factor a vector or a list containing the multiplication factors for the upper and lower learning rate. Used only for RPROP and GRPROP.
#' @param learningrate a numeric value specifying the learning rate used by traditional backpropagation. Used only for traditional backpropagation.
#' @param lifesign a string specifying how much the function will print during the calculation of the neural network. 'none', 'minimal' or 'full'.
#' @param lifesign.step an integer specifying the stepsize to print the minimal threshold in full lifesign mode.
#' @param algorithm a string containing the algorithm type to calculate the neural network. The
#'                  following types are possible: 'backprop', 'rprop+', 'rprop-', 'sag', or 'slr'. 'backprop'
#'                  refers to backpropagation, 'rprop+' and 'rprop-' refer to the resilient backpropagation
#'                  with and without weight backtracking, while 'sag' and 'slr' induce the usage of the modified globally
#'                  convergent algorithm (grprop). See Details for more information.
#' @param err.fct a differentiable function that is used for the calculation of the error. Alternatively, the strings 'sse'
#'                and 'ce' which stand for the sum of squared errors and the cross-entropy can be used.
#' @param act.fct a differentiable function that is used for smoothing the result of the cross product of the covariate or neurons and the weights.
#'                Additionally the strings, 'logistic' and 'tanh' are possible for the logistic function and tangent hyperbolicus.
#' @param linear.output logical. If act.fct should not be applied to the output neurons set linear output to TRUE, otherwise to FALSE.
#' @param exclude a vector or a matrix specifying the weights, that are excluded from the calculation.
#'                If given as a vector, the exact positions of the weights must be known. A matrix with n-rows and 3 columns will exclude n weights,
#'                 where the first column stands for the layer, the second column for the input neuron and the third column for the output neuron of the weight.
#' @param constant.weights a vector specifying the values of the weights that are excluded from the training process and treated as fix.
#' @param likelihood logical. If the error function is equal to the negative log-likelihood function, the
#'                   information criteria AIC and BIC will be calculated. Furthermore the usage of confidence.interval is meaningfull.
#'
#' @seealso The internal function is from package \code{\link[neuralnet]{neuralnet}}.
#'
#' @return A object neuralnet.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[neuralnet]{neuralnet}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.neuralnet <- train.neuralnet(Species~., data.train,hidden = c(10, 14, 13),
#'                                     linear.output = FALSE, threshold = 0.01, stepmax = 1e+06)
#' modelo.neuralnet
#' prob <- predict(modelo.neuralnet, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.neuralnet, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.neuralnet <- function(formula, data, hidden = 1, threshold = 0.01, stepmax = 1e+05, rep = 1, startweights = NULL, learningrate.limit = NULL,
                            learningrate.factor = list(minus = 0.5, plus = 1.2), learningrate = NULL, lifesign = "none", lifesign.step = 1000,
                            algorithm = "rprop+", err.fct = "sse", act.fct = "logistic", linear.output = TRUE, exclude = NULL, constant.weights = NULL,
                            likelihood = FALSE){
  aux_data <- head(data)
  selector <- unlist(lapply(data, is.ordered))

  if(any(selector)){
    data[,selector] <- lapply(data[,selector, drop = FALSE], function(x) factor(x, ordered = FALSE, levels = levels(x)) )
  }

  var.predict <- as.character(formula[2])
  selector <- which(colnames(data) == var.predict)
  class.names <- levels(data[,selector])

  suppressWarnings(data <- cbind(as.data.frame(dummy.data.frame(data[, -selector, drop = FALSE], drop = FALSE,
                                                                      dummy.classes = c("factor","character"))), data[,selector]))
  colnames(data) <- c(colnames(data)[-ncol(data)], var.predict)

  .vars <- all.vars(formula[-2])
  if(length(.vars) == 1 && .vars == "."){
    .colnames <- colnames(data[,-selector])
  }else{
    .colnames <- c()
    for (i in seq_along(.vars)) {
      v <- .vars[i]
      variable <- aux_data[,v]
      if(is.factor(variable)){
        .colnames <- c(.colnames, paste0(v, levels(variable)))
      }else{
        .colnames <- c(.colnames, v)
      }
    }
  }

  formula.aux <- update(formula, as.formula(paste0(var.predict,"~",paste0(.colnames[!(.colnames %in% var.predict)], collapse = "+"))))

  m <- match.call(expand.dots = FALSE)
  m$data <- quote(data)
  m[[1L]] <- quote(neuralnet::neuralnet)
  my.list <- as.list(m$...)
  m$formula <- formula.aux
  model <- eval(m, envir = environment())

  create.model(model, formula, aux_data, "neuralnet.prmdt")

}

#' train.svm
#'
#' @description Provides a wrapping function for the \code{\link[e1071]{svm}}.
#'
#' @param formula a symbolic description of the model to be fit.
#' @param data an optional data frame containing the variables in the model. By default the variables are taken from the environment which ‘svm’ is called from.
#' @param ... additional parameters for the low level fitting function svm.default
#' @param subset An index vector specifying the cases to be used in the training sample. (NOTE: If given, this argument must be named.)
#' @param na.action A function to specify the action to be taken if NAs are found. The default action is
#'                  na.omit, which leads to rejection of cases with missing values on any required variable.
#'                  An alternative is na.fail, which causes an error if NA cases are found. (NOTE: If given, this argument must be named.)
#' @param scale A logical vector indicating the variables to be scaled. If scale is of length 1, the value is
#'              recycled as many times as needed. Per default, data are scaled internally (both x and y variables) to zero mean and unit variance.
#'              The center and scale values are returned and used for later predictions.
#'
#' @seealso The internal function is from package \code{\link[e1071]{svm}}.
#'
#' @return A object svm.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[e1071]{svm}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.svm <- train.svm(Species~., data.train)
#' modelo.svm
#' prob <- predict(modelo.svm, data.test , type = "prob")
#' prob
#' prediccion <- predict(modelo.svm, data.test , type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.svm <- function(formula, data, ..., subset, na.action = na.omit, scale = TRUE){
  m <- match.call(expand.dots = FALSE)
  m[[1L]] <- quote(e1071::svm)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  m$probability <- is.null(m$probability) || m$probability
  model <- eval(m, envir = parent.frame())
  create.model(model, formula, data, "svm.prmdt")
}

#' train.xgboost
#'
#' @description Provides a wrapping function for the \code{\link[xgboost]{xgb.train}}.
#'
#' @param formula a symbolic description of the model to be fit.
#' @param data training dataset. xgb.train accepts only an xgb.DMatrix as the input. xgboost, in addition, also accepts matrix, dgCMatrix, or name of a local data file.
#' @param nrounds max number of boosting iterations.
#' @param watchlist named list of xgb.DMatrix datasets to use for evaluating model performance.
#'                  Metrics specified in either eval_metric or feval will be computed for each of these
#'                  datasets during each boosting iteration, and stored in the end as a field named evaluation_log in the resulting object.
#'                   When either verbose>=1 or cb.print.evaluation callback is engaged, the performance results are continuously printed out
#'                   during the training. E.g., specifying watchlist=list(validation1=mat1, validation2=mat2) allows to track the performance
#'                   of each round's model on mat1 and mat2.
#' @param obj customized objective function. Returns gradient and second order gradient with given prediction and dtrain.
#' @param feval custimized evaluation function. Returns list(metric='metric-name', value='metric-value') with given prediction and dtrain.
#' @param verbose If 0, xgboost will stay silent. If 1, it will print information about performance. If 2, some additional information will be printed out.
#'                Note that setting verbose > 0 automatically engages the cb.print.evaluation(period=1) callback function.
#' @param print_every_n Print each n-th iteration evaluation messages when verbose>0. Default is 1 which means all messages are printed.
#'                      This parameter is passed to the cb.print.evaluation callback.
#' @param early_stopping_rounds If NULL, the early stopping function is not triggered. If set to an integer k,
#'                              training with a validation set will stop if the performance doesn't improve for k rounds.
#'                              Setting this parameter engages the cb.early.stop callback.
#' @param maximize 	If feval and early_stopping_rounds are set, then this parameter must be set as well. When it is TRUE, it means the larger
#'                  the evaluation score the better. This parameter is passed to the cb.early.stop callback.
#' @param save_period when it is non-NULL, model is saved to disk after every save_period rounds, 0 means save at the end. The saving is handled by the cb.save.model callback.
#' @param save_name the name or path for periodically saved model file.
#' @param xgb_model a previously built model to continue the training from. Could be either an object of class xgb.Booster, or its raw data, or the name
#'                  of a file with a previously saved model.
#' @param callbacks a list of callback functions to perform various task during boosting. See callbacks. Some of the callbacks are automatically created
#'                  depending on the parameters' values. User can provide either existing or their own callback methods in order to customize the training process.
#' @param eval_metric eval_metric evaluation metrics for validation data. Users can pass a self-defined function to it. Default: metric will be assigned
#'                    according to objective(rmse for regression, and error for classification, mean average precision for ranking). List is
#'                    provided in detail section.
#' @param extra_params the list of parameters. The complete list of parameters is available at http://xgboost.readthedocs.io/en/latest/parameter.html.
#' @param booster booster which booster to use, can be gbtree or gblinear. Default: gbtree.
#' @param objective objective specify the learning task and the corresponding learning objective, users can pass a self-defined function to it. The default objective options are below:
#' + reg:linear linear regression (Default).
#' + reg:logistic logistic regression.
#' + binary:logistic logistic regression for binary classification. Output probability.
#' + binary:logitraw logistic regression for binary classification, output score before logistic transformation.
#' + num_class set the number of classes. To use only with multiclass objectives.
#' + multi:softmax set xgboost to do multiclass classification using the softmax objective. Class is represented by a number and should be from 0 to num_class - 1.
#' + multi:softprob same as softmax, but prediction outputs a vector of ndata * nclass elements, which can be further reshaped to ndata, nclass matrix. The result contains predicted probabilities of each data point belonging to each class.
#' + rank:pairwise set xgboost to do ranking task by minimizing the pairwise loss.
#' @param eta eta control the learning rate: scale the contribution of each tree by a factor of 0 < eta < 1 when it is added to the current approximation.
#'            Used to prevent overfitting by making the boosting process more conservative. Lower value for eta implies larger value for nrounds: low eta
#'            value means model more robust to overfitting but slower to compute. Default: 0.3
#' @param gamma gamma minimum loss reduction required to make a further partition on a leaf node of the tree. the larger, the more conservative
#'              the algorithm will be.gamma minimum loss reduction required to make a further partition on a leaf node of the tree. the larger, the more
#'              conservative the algorithm will be.
#' @param max_depth max_depth maximum depth of a tree. Default: 6
#' @param min_child_weight min_child_weight minimum sum of instance weight (hessian) needed in a child. If the tree partition step results in a leaf node
#'                         with the sum of instance weight less than min_child_weight, then the building process will give up further partitioning. In linear
#'                         regression mode, this simply corresponds to minimum number of instances needed to be in each node. The larger, the more conservative
#'                         the algorithm will be. Default: 1
#' @param subsample subsample subsample ratio of the training instance. Setting it to 0.5 means that xgboost randomly collected half of the data instances to
#'                  grow trees and this will prevent overfitting. It makes computation shorter (because less data to analyse). It is advised to use this parameter
#'                  with eta and increase nrounds. Default: 1
#' @param colsample_bytree colsample_bytree subsample ratio of columns when constructing each tree. Default: 1
#' @param ... other parameters to pass to params.
#'
#' @seealso The internal function is from package \code{\link[xgboost]{xgb.train}}.
#'
#' @return A object xgb.Booster.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @note the parameter information was taken from the original function \code{\link[xgboost]{xgb.train}}.
#'
#' @export
#'
#' @examples
#'
#' data("iris")
#'
#' n <- seq_len(nrow(iris))
#' .sample <- sample(n, length(n) * 0.75)
#' data.train <- iris[.sample,]
#' data.test <- iris[-.sample,]
#'
#' modelo.xg <- train.xgboost(Species~., data.train, nrounds = 79, maximize = FALSE)
#' modelo.xg
#' prob <- predict(modelo.xg, data.test, type = "prob")
#' prob
#' prediccion <- predict(modelo.xg, data.test, type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.xgboost <- function(formula, data, nrounds, watchlist = list(), obj = NULL, feval = NULL,
                          verbose = 1, print_every_n = 1L, early_stopping_rounds = NULL, maximize = NULL,
                          save_period = NULL, save_name = "xgboost.model", xgb_model = NULL, callbacks = list(),
                          eval_metric = "mlogloss",extra_params = NULL, booster = "gbtree",
                          objective = NULL, eta = 0.3, gamma=0, max_depth = 6, min_child_weight = 1, subsample = 1,
                          colsample_bytree = 1, ...){

  .colnames <- all.vars(formula[-2])
  var.predict <- as.character(formula[2])

  selector <- which(colnames(data) == var.predict)

  if(length(.colnames) == 1 && .colnames == "."){
    .colnames <- colnames(data[,-selector, drop = FALSE])
  }

  train_aux <- data %>% select(c(.colnames,var.predict)) %>% select_on_class(c("numeric","integer", "factor"))

  train_aux[] <- lapply(train_aux, as.numeric)

  if(min(train_aux[,var.predict]) != 0){
    train_aux[,var.predict] <- train_aux[,var.predict] - 1
  }

  selector <- which(colnames(train_aux) == var.predict)

  train_aux <- xgb.DMatrix(data = data.matrix(train_aux[,-selector]), label = data.matrix(train_aux[,selector]))

  if(length(watchlist) == 0){
    watchlist <- list(train = train_aux)
  }

  num.class <- length(levels(data[,var.predict]))

  if(is.null(extra_params)){
    if(is.null(objective)){
      objective <- ifelse(num.class == 2, "binary:logistic", "multi:softprob")
    }
    params <- list(booster = booster, objective = objective, eta = eta, gamma = gamma, max_depth = max_depth,
                   min_child_weight = min_child_weight, subsample = subsample, colsample_bytree = colsample_bytree)
  }else{
    params <- extra_params
  }

  if(num.class > 2){
    params$num_class <- num.class
    model <- xgb.train(params = params, data = train_aux, eval_metric = "mlogloss", nrounds = nrounds, watchlist = watchlist,
                       obj = obj, feval = feval, verbose = verbose, print_every_n = print_every_n, early_stopping_rounds = early_stopping_rounds,
                       maximize = maximize, save_period = save_period, save_name = save_name, xgb_model = xgb_model, callbacks = callbacks, ... = ...)
  }else{
    model <- xgb.train(params = params, data = train_aux, nrounds = nrounds, watchlist = watchlist, obj = obj, feval = feval, verbose = verbose,
                       print_every_n = print_every_n, early_stopping_rounds = early_stopping_rounds, maximize = maximize, save_period = save_period,
                       save_name = save_name, xgb_model = xgb_model, callbacks = callbacks, ... = ...)
  }

  create.model(model, formula, data, "xgb.Booster.prmdt")

}



#' train.glm
#'
#' @description Provides a wrapping function for the \code{\link[stats]{glm}}
#'
#' @param formula an object of class "formula" (or one that can be coerced to that class): a symbolic description of the model to be fitted. The details of model specification are given under ‘Details’.
#' @param data an optional data frame, list or environment (or object coercible by as.data.frame to a data frame) containing the variables in the model. If not found in data, the variables are taken from environment(formula), typically the environment from which glm is called.
#' @param family a description of the error distribution and link function to be used in the model. For glm this can be a character string naming a family function, a family function or the result of a call to a family function. For glm.fit only the third option is supported. (See family for details of family functions.)
#' @param weights an optional vector of ‘prior weights’ to be used in the fitting process. Should be NULL or a numeric vector.
#' @param subset an optional vector specifying a subset of observations to be used in the fitting process.
#' @param na.action a function which indicates what should happen when the data contain NAs. The default is set by the na.action setting of options, and is na.fail if that is unset. The ‘factory-fresh’ default is na.omit. Another possible value is NULL, no action. Value na.exclude can be useful.
#' @param start starting values for the parameters in the linear predictor.
#' @param etastart starting values for the linear predictor.
#' @param mustart starting values for the vector of means.
#' @param offset this can be used to specify an a priori known component to be included in the linear predictor during fitting. This should be NULL or a numeric vector of length equal to the number of cases. One or more offset terms can be included in the formula instead or as well, and if more than one is specified their sum is used. See model.offset.
#' @param control a list of parameters for controlling the fitting process. For glm.fit this is passed to glm.control.
#' @param model a logical value indicating whether model frame should be included as a component of the returned value.
#' @param method the method to be used in fitting the model. The default method "glm.fit" uses iteratively reweighted least squares (IWLS): the alternative "model.frame" returns the model frame and does no fitting.
#'               User-supplied fitting functions can be supplied either as a function or a character string naming a function, with a function which takes the same arguments as glm.fit. If specified as a character string it is looked up from within the stats namespace.
#' @param x,y For glm: logical values indicating whether the response vector and model matrix used in the fitting process should be returned as components of the returned value.
#'            For glm.fit: x is a design matrix of dimension n * p, and y is a vector of observations of length n.
#' @param singular.ok logical; if FALSE a singular fit is an error.
#' @param contrasts an optional list. See the contrasts.arg of model.matrix.default.
#' @param ... For glm: arguments to be used to form the default control argument if it is not supplied directly.
#'            For weights: further arguments passed to or from other methods.
#'
#' @seealso The internal function is from package \code{\link[stats]{glm}}.
#'
#' @seealso The internal function is from package \code{\link[stats]{glm}}.
#'
#' @return A object glm.prmdt with additional information to the model that allows to homogenize the results.
#'
#' @export
#'
#' @examples
#'
#' data("Puromycin")
#'
#' n <- seq_len(nrow(Puromycin))
#' .sample <- sample(n, length(n) * 0.65)
#' data.train <- Puromycin[.sample,]
#' data.test <- Puromycin[-.sample,]
#'
#' modelo.glm <- train.glm(state~., data.train)
#' modelo.glm
#' prob <- predict(modelo.glm, data.test , type = "prob")
#' prob
#' prediccion <- predict(modelo.glm, data.test , type = "class")
#' prediccion
#' confusion.matrix(data.test, prediccion)
#'
train.glm <- function(formula,  data, family = binomial, weights, subset, na.action, start = NULL, etastart, mustart, offset, control = list(...),
                      model = TRUE, method = "glm.fit", x = FALSE, y = TRUE, singular.ok = TRUE, contrasts = NULL, ...){
  m <- match.call(expand.dots = FALSE)
  if (is.matrix(eval.parent(m$data))){
    m$data <- as.data.frame(data)
  }
  m[[1L]] <- quote(glm)
  my.list <- as.list(m$...)
  for(.name in names(my.list)) {
    m[[.name]] <- my.list[[.name]]
  }
  m$... <- NULL
  m$family <-  substitute(family)
  model <- eval.parent(m)
  create.model(model, formula, data, "glm.prmdt")
}


