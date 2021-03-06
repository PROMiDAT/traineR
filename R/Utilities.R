
#' get_test_less_predict
#'
#' @keywords internal
#'
select_on_class <- function(.data, clases = "numeric") {
  .data[, sapply(.data, function(vec, clss) any(class(vec) %in% clss), clss = clases), drop  = FALSE]
}

#' contr.dummy
#'
#' @keywords internal
#'
contr.dummy <- function (n, contrasts = TRUE) {
  if (length(n) <= 1) {
    if (is.numeric(n) && length(n) == 1 && n > 1)
      levels <- 1:n
    else stop("contrasts are not defined for 0 degrees of freedom")
  }
  else levels <- n
  lenglev <- length(levels)
  cont <- array(0, c(lenglev, lenglev), list(levels, levels))
  cont[col(cont) == row(cont)] <- 1
  cont
}

#' contr.ordinal
#'
#' @keywords internal
#'
contr.ordinal <- function (n, contrasts = TRUE) {
  if (length(n) <= 1) {
    if (is.numeric(n) && length(n) == 1 && n > 1)
      levels <- 1:n
    else stop("contrasts are not defined for 0 degrees of freedom")
  }
  else levels <- n
  lenglev <- length(levels)
  cont <- array(0.5, c(lenglev, lenglev - 1), list(levels,
                                                   NULL))
  cont[lower.tri(cont)] <- -0.5
  cont
}

#' max_col
#'
#' @keywords internal
#'
max_col <- function(m){
  base::max.col(apply(m, 1, function(x) max(x, na.rm = TRUE)) == m)
}

#' numeric_to_predict
#'
#' @keywords internal
#'
numeric_to_predict <- function(real, predic.var = NULL) {
  if(is.numeric(predic.var)) {
    predic.var <- factor(predic.var, labels = levels(real))
  }
  predic.var
}

#' type_correction
#'
#' @keywords internal
#'
type_correction <- function(model, prediction, fix){
  var_type <- model$prmdt$type
  .levels  <- model$prmdt$levels
  if(var_type != "numeric" && var_type != "integer" && fix){
    names(prediction) <- NULL
    return(factor(prediction, levels = .levels))
  }else{
    return(prediction)
  }
}

#' original_model
#'
#' @keywords internal
#'
original_model <- function(x){
  class(x) <- class(x)[!str_detect(class(x), "prmdt")]
  x$prmdt <- NULL
  return(x)
}

#' get_test_less_predict
#'
#' @keywords internal
#'
get_test_less_predict <- function(data, var.pred){
  data[,-which(colnames(data) == var.pred)]
}


#' Printing prmdt models
#'
#' @param x A prmdt models
#' @param ... optional arguments to print o format method
#'
#' @keywords internal
#'
print.prmdt <- function(x, ...){
  print(original_model(x), ...)
}

#' Printing prmdt prediction object
#'
#' @param x A prmdt prediction object
#' @param ... optional arguments to print o format method
#'
#' @keywords internal
#'
print.prediction.prmdt <- function(x, ...){
  print(x$prediction, ...)
}

#' Printing prmdt index object
#'
#' @param x A prmdt index object
#' @param ... optional arguments to print o format method
#'
#' @keywords internal
#'
print.indexes.prmdt <- function(x, ...){
  out <- c("\nConfusion Matrix:",capture.output(x$confusion.matrix))
  out <- paste(out, collapse = "\n")
  out <- paste0(out, sprintf("\n\nOverall Accuracy: %3.4f\nOverall Error: %9.4f\n", x$overall.accuracy, x$overall.error))
  out.aux <- do.call(sprintf, c(paste0(rep("%13s", length(x$category.accuracy)), collapse = ""), as.list(names(x$category.accuracy))))
  out.aux <- paste0("\nCategory Accuracy:\n\n",out.aux, "\n",
                    do.call(sprintf, c(paste0(rep("%13f", length(x$category.accuracy)), collapse = ""), as.list(as.numeric(x$category.accuracy)))))
  out <- paste0(out, out.aux)
  cat(out)
}


#' Plotting prmdt models
#'
#' @param x A prmdt models
#' @param ... optional arguments to print o format method
#'
#' @keywords internal
#'
plot.prmdt <- function(x, ...){
  x <- original_model(x)
  plot(x, ...)
}

#' Plotting prmdt ada models
#'
#' @param x A ada prmdt model
#' @param ... optional arguments to print o format method
#'
#' @return a plot of the importance of variables.
#'
#' @export
#'
varplot <- function(x, ...){
  x <- original_model(x)
  ada::varplot(x, ...)
}

