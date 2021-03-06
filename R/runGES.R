runGES <- function(X, parentsOf, variableSelMat, setOptions, directed, verbose, 
                   ...){
  
  # additional options for GES
  optionsList <- list("phase"= c("forward", "backward", "turning"),
                      "iterate"=TRUE,
                      "adaptive" = "none", 
                      "maxDegree"=integer(0),
                      "lambda" = 0.5*log(nrow(X)))
  
  # adjust according to setOptions if necessary
  optionsList <- adjustOptions(availableOptions = optionsList, 
                               optionsToSet = setOptions)
  
  score <- new("GaussL0penObsScore", 
               data = X,
               lambda = optionsList$lambda)
  G <- pcalg::ges(score, 
               fixedGaps=if(is.null(variableSelMat)) NULL else (!variableSelMat), 
               adaptive = optionsList$adaptive,
               phase = optionsList$phase,
               iterate = optionsList$iterate,
               maxDegree=optionsList$maxDegree, 
               verbose=verbose, ...)
  gesmat <- as(G$essgraph, "matrix")
  gesmat[gesmat] <- 1
  gesmat[!gesmat] <- 0
  
  if(directed){
    warning("Removing undirected edges from estimated adjacency matrix.")
    gesmat <- gesmat * (t(gesmat)==0)
  }
  
  result <- vector("list", length = length(parentsOf))
  
  for (k in 1:length(parentsOf)){
    result[[k]] <- which(gesmat[, parentsOf[k]] == 1)
    attr(result[[k]],"parentsOf") <- parentsOf[k]
  }

  if(length(parentsOf) < ncol(X)){
    gesmat <- gesmat[,parentsOf]
  }
  
  list(resList = result, resMat = gesmat)
}