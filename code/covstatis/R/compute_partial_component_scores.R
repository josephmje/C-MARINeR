compute_partial_component_scores <- function(cov_matrices, compromise_eigen){

  (compromise_eigen$vectors %*% diag(1/sqrt(compromise_eigen$values))) ->
    projection_matrix

  sapply(cov_matrices,
         function(table, projection){table %*% projection_matrix},
         projection=projection_matrix,
         simplify = FALSE,
         USE.NAMES = TRUE)

}
