library(rmarkdown)

filesToKnit <- list.files(pattern = ".Rmd", full.names = TRUE,recursive = TRUE)
#filesToKnit <- filesToKnit[!grepl("in-class", filesToKnit, fixed= TRUE)]

lapply(filesToKnit, function(x){rmarkdown::render(x, knit_root_dir = "../")})

solutionsToKnit <- list.files(path="../analyticsSolutions/", pattern = ".Rmd", full.names=TRUE, recursive = TRUE)

lapply(solutionsToKnit, function(x){rmarkdown::render(x, knit_root_dir = "~/Code/AnalyticsCourse/")})