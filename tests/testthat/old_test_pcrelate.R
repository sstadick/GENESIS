context("pcrelate tests")
library(GWASTools)

test_that("pcrelate", {

    # file path to GDS file
    gdsfile <- system.file("extdata", "HapMap_ASW_MXL_geno.gds", package="GENESIS")
    # read in GDS data
    HapMap_geno <- GdsGenotypeReader(filename = gdsfile)
    # create a GenotypeData class object
    HapMap_genoData <- GenotypeData(HapMap_geno)
    # load saved matrix of KING-robust estimates
    data("HapMap_ASW_MXL_KINGmat")
    # PC-AiR
    mypcs <- pcair(HapMap_genoData, kinobj = HapMap_ASW_MXL_KINGmat, divobj = HapMap_ASW_MXL_KINGmat, verbose=FALSE)

    myrel <- pcrelate(genoData = HapMap_genoData, pcMat = mypcs$vectors[,1:2])

    close(HapMap_genoData)	
})

test_that("pcrelate_writegds", {

    # file path to GDS file
    gdsfile <- system.file("extdata", "HapMap_ASW_MXL_geno.gds", package="GENESIS")
    # read in GDS data
    HapMap_geno <- GdsGenotypeReader(filename = gdsfile)
    # create a GenotypeData class object
    HapMap_genoData <- GenotypeData(HapMap_geno)
    # load saved matrix of KING-robust estimates
    data("HapMap_ASW_MXL_KINGmat")
    # PC-AiR
    mypcs <- pcair(HapMap_genoData, kinobj = HapMap_ASW_MXL_KINGmat, divobj = HapMap_ASW_MXL_KINGmat, verbose=FALSE)

    gds.prefix <- tempfile()
    myrel <- pcrelate(genoData = HapMap_genoData, pcMat = mypcs$vectors[,1:2], write.to.gds=TRUE, gds.prefix=gds.prefix)
    gds <- GdsGenotypeReader(paste0(gds.prefix, "_freq.gds"))
    close(gds)
    unlink(paste0(gds.prefix, "_freq.gds"))
    
    close(HapMap_genoData)
    
})

test_that("pcrelate_makegrm", {
    requireNamespace("gdsfmt")

    # file path to GDS file
    gdsfile <- system.file("extdata", "HapMap_ASW_MXL_geno.gds", package="GENESIS")
    # read in GDS data
    HapMap_geno <- GdsGenotypeReader(filename = gdsfile)
    # create a GenotypeData class object
    HapMap_genoData <- GenotypeData(HapMap_geno)
    # load saved matrix of KING-robust estimates
    data("HapMap_ASW_MXL_KINGmat")
    # PC-AiR
    mypcs <- pcair(HapMap_genoData, kinobj = HapMap_ASW_MXL_KINGmat, divobj = HapMap_ASW_MXL_KINGmat, verbose=FALSE)

    # make sure use of scan.include returns correct values
    # check with RData
    myrel <- pcrelate(genoData = HapMap_genoData, pcMat = mypcs$vectors[,1:2])
    grm <- pcrelateMakeGRM(myrel)
    scan.include <- sample(colnames(grm), floor(ncol(grm)/2))
    grm.sub <- pcrelateMakeGRM(myrel, scan.include=scan.include)
    ind <- colnames(grm) %in% scan.include
    expect_equal(grm[ind,ind], grm.sub)

    # check with gds
    gds.prefix <- tempfile()
    myrel <- pcrelate(genoData = HapMap_genoData, pcMat = mypcs$vectors[,1:2], write.to.gds=TRUE, gds.prefix=gds.prefix)
    gds <- openfn.gds(paste0(gds.prefix, "_pcrelate.gds"))

    grm <- pcrelateMakeGRM(gds)
    scan.include <- sample(colnames(grm), floor(ncol(grm)/2))
    grm.sub <- pcrelateMakeGRM(gds, scan.include=scan.include)
    ind <- colnames(grm) %in% scan.include
    expect_equal(grm[ind,ind], grm.sub)
    
    closefn.gds(gds)
    unlink(paste0(gds.prefix, "_pcrelate.gds"))
    
    close(HapMap_genoData)
    
})
