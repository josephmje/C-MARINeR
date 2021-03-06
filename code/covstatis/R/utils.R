## utils and stolen utils from other places, documented as necessary.


##
#' @export
#'
#' @title \code{is.ss.matrix}: test if a matrix square and symmetric matrix
#'
#' @description \code{is.ss.matrix} takes a matrix and tests if it is a square and symmetric matrix
#'
#' @param x A matrix to test.
#' @param tol Tolerance precision to eliminate all abs(x) values below \code{tol}. Default is \code{.Machine$double.eps}.
#'
#' @return A boolean. TRUE if the matrix is a square and symmetric matrix, FALSE if the matrix is not.

is_ss_matrix <- function(x,tol=.Machine$double.eps){

  if(is.null(dim(x)) | !is.matrix(x)){
    stop("is.sspsd.matrix: X is not a matrix.")
  }
  x[ x^2 < tol ] <- 0

  ## square
  if(nrow(x)!=ncol(x)){
    return(FALSE)
  }
  ## symmetric
  if(!isSymmetric.matrix(x, tol=tol)){
    return(FALSE)
  }

  return(TRUE)

}


is_ss_dist_matrix <- function(x,tol=.Machine$double.eps){

  if(is.null(dim(x)) | !is.matrix(x)){
    stop("is.sspsd.matrix: X is not a matrix.")
  }
  x[ x^2 < tol ] <- 0

  ## square
  if(nrow(x)!=ncol(x)){
    return(FALSE)
  }
  ## symmetric
  if(!isSymmetric.matrix(x, tol=tol)){
    return(FALSE)
  }
  ## diagonals are 0s
  # if( !identical(diag(x),rep(0,ncol(x))) ){
  if( abs(sum(diag(x)-rep(0,ncol(x)))) > tol){
    return(FALSE)
  }
  return(TRUE)

}

#' @export
#'
#' @title \code{is.sspsd.matrix}: test if a matrix square, symmetric, and positive semi-definite (sspsd) matrix
#'
#' @description \code{is.sspsd.matrix} takes a matrix and tests if it is a square, symmetric, and positive semi-definite (sspsd) matrix
#'
#' @param x A matrix to test.
#' @param tol Tolerance precision to eliminate all abs(x) values below \code{tol}. Default is \code{.Machine$double.eps}.
#'
#' @return A boolean. TRUE if the matrix is a square, symmetric, and positive semi-definite (sspsd) matrix, FALSE if the matrix is not.

is_sspsd_matrix <- function(x,tol=.Machine$double.eps){

  if(is.null(dim(x)) | !is.matrix(x)){
    stop("is.sspsd.matrix: X is not a matrix.")
  }
  x[ x^2 < tol ] <- 0

    ## square
  if(nrow(x)!=ncol(x)){
    return(FALSE)
  }
    ## symmetric
  if(!isSymmetric.matrix(x, tol=tol)){
    return(FALSE)
  }
    ## positive semi definite
  eigen.values <- eigen(x, symmetric = T, only.values = T)$values
  if(any(eigen.values < 0 & abs(eigen.values) > tol)){
    return(FALSE)
  }

  return(TRUE)

}

## from GSVD
#' @export
#'
#' @title \code{matrix.exponent}: raise matrix to a power and rebuild lower rank version
#'
#' @description \code{matrix.exponent} takes in a matrix and will compute raise that matrix to some arbitrary power via the singular value decomposition.
#'  Additionally, the matrix can be computed for a lower rank estimate of the matrix.
#'
#' @param x data matrix
#' @param power the power to raise \code{x} by (e.g., 2 is squared)
#' @param k the number of components to retain in order to build a lower rank estimate of \code{x}
#' @param ... parameters to pass through to \code{\link{tolerance.svd}}
#'
#' @return The (possibly lower rank) raised to an arbitrary \code{power} version of \code{x}
#'
#'
#' @examples
#'  data(wine)
#'  X <- as.matrix(wine$objective)
#'  X.power_1 <- matrix.exponent(X)
#'  X / X.power_1
#'
#'  ## other examples.
#'  X.power_2 <- matrix.exponent(X,power=2)
#'  X.power_negative.1.div.2 <- matrix.exponent(X,power=-1/2)
#'
#'  X.power_negative.1 <- matrix.exponent(X,power=-1)
#'  X.power_negative.1 / (X %^% -1)
#'
#' @author Derek Beaton
#'
#' @keywords multivariate, diagonalization, eigen

#matrix.exponent <- me <- m.e <- function(x, power = 1, k = 0, ...){
matrix_exponent <- function(x, power = 1, k = 0, ...){

  ##stolen from MASS::ginv()
  if (length(dim(x)) > 2L || !(is.numeric(x) || is.complex(x)))
    stop("matrix.exponent: 'x' must be a numeric or complex matrix")
  if (!is.matrix(x))
    x <- as.matrix(x)

  k <- round(k)
  if(k<=0){
    k <- min(nrow(x),ncol(x))
  }

  ## should be tested for speed.

  #res <- tolerance.svd(x,...)
  #comp.ret <- 1:min(length(res$d),k)
  #return( (res$u[,comp.ret] * matrix(res$d[comp.ret]^power,nrow(res$u[,comp.ret]),ncol(res$u[,comp.ret]),byrow=T)) %*% t(res$v[,comp.ret]) )


  ## the special cases:
  ## power = 0
  if(power==0){
    x <- diag(1,nrow(x),ncol(x))
    attributes(x)$message.to.user = "https://www.youtube.com/watch?v=9w1y-kMPNcM"
    return( x )
  }
  ## is diagonal
  if(is.diagonal.matrix(x)){
    return( diag( diag(x)^power ) )

  }
  ## is vector
  if( any(dim(x)==1) ){
    return( x^power )
  }

  res <- tolerance.svd(x, nu = k, nv = k, ...)
  if(k > length(res$d)){
    k <- length(res$d)
  }
  return( sweep(res$u,2,res$d[1:k]^power,"*") %*% t(res$v) )

}

#' @export
#'
#' @title Matrix exponentiation
#'
#' @description takes in a matrix and will compute raise that matrix to some arbitrary power via the singular value decomposition.
#'  Additionally, the matrix can be computed for a lower rank estimate of the matrix.
#'
#' @param x data matrix
#' @param power the power to raise \code{x} by (e.g., 2 is squared)
#'
#' @return \code{x} raised to an arbitrary \code{power}
#'
#' @seealso \code{\link{matrix.exponent}}
#'
#' @examples
#'  data(wine)
#'  X <- as.matrix(wine$objective)
#'  X %^% 2 # power of 2
#'  X %^% -1 # (generalized) inverse
#'
#' @author Derek Beaton
#'
#' @keywords multivariate, diagonalization, eigen
#'
`%^%` <- function(x,power){
  matrix.exponent(x,power=power)
}


#' @export
#'
#' @title Eigendecomposition tolerance corrections
#'
#' @description takes the results of an eigen decomposition and drops vectors and values below
#' tolerance threshold
#'
#' @param eigen_tolerance results from \code{eigen()}
#' @param tol Tolerance precision to eliminate all abs(x) values below \code{tol}. Default is \code{1e-12}.
#'
#' @return \code{eigen_tolerance} corrected for tolerance (if necessary)
#'
#' @seealso \code{\link{eigen}}
#'
#'
#' @author Derek Beaton
#'
#' @keywords multivariate, diagonalization, eigen
#'
eigen_tolerance <- function(eigen_results, tol=1e-12){

  ## ensure eigen_results has $vectors and $values

  if(any(eigen_results$values < 0 & abs(eigen_results$values) > tol)){
    stop("eigen_tolerance: negative eigenvalues detected. Cannot proceed.")
  }

  ## check for low eigenvalues only.
  if(any(eigen_results$values < tol)){
    vectors_kept <- which(eigen_results$values > tol)
    eigen_results$values <- eigen_results$values[vectors_kept]
    eigen_results$vectors <- eigen_results$vectors[,vectors_kept]
  }
  eigen_results
}


### this is stolen from https://stackoverflow.com/questions/20198751/three-dimensional-array-to-list
array2list <- function(a){
  setNames(lapply(split(a, arrayInd(seq_along(a), dim(a))[, 3]),
                  array, dim = dim(a)[-3], dimnames(a)[-3]),dimnames(a)[[3]])
}
