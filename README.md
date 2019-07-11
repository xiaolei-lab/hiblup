---
layout: default
---
# HIBLUP

HIBLUP (He-aI BLUP) is an user-friendly R package that provides estimated genetic value of each individual by maximizing the usage of information from pedigree records, genome, and phenotype, as well as all process-related functions, such as construction of relationship matrix, estimation of variance components with various algorithms, and estimation of SNP effects, are also implemented.

## Download
- v1.2.0
  - [Linux & macOS Online Installer](https://raw.githubusercontent.com/hiblup/hiblup/master/hiblupInstaller.sh)
  - [Windows](https://github.com/hiblup/hiblup/raw/master/hiblup_1.2.0.zip)
  - [User Manual](https://github.com/hiblup/hiblup/raw/master/hiblup-user-manual-v1.2.pdf)

## Features

- Construct relationship matrix
  - Pedigree based relationship matrix(A matrix)
  - Genome based relationship matrix(G matrix)
  - Pedigree and genome based relationship matrix(H matrix)
- Variance components estimation ( AI, EM, EMAI, AIEM, HE Regression, and **HI** )
  - Singe K model
  - Multiple K model
  - Pairs of correlated traits
  - Repeated records traits
- LMM Framework
  - BLUP
  - Pedigree BLUP(PBLUP)
  - Genomic BLUP(GBLUP)
  - Single-step BLUP(SSBLUP)

## Installation

[Microsoft R Open](https://mran.microsoft.com/download/) (MRO) could speed up the mathematical calculation of HIBLUP, it includes multi-threaded math libraries. These libraries make it possible for so many common R operations, ***such as matrix multiply/inverse, matrix decomposition, and some higher-level matrix operations***, to compute in parallel and use all of the processing power available to [reduce computation times](https://mran.microsoft.com/documents/rro/multithread/#mt-bench). For Linux and macOS, our shell script could automatically install MRO with HIBLUP package included, and no root permission requirements. For Windows, we highly suggest users to install MRO for HIBLUP. Following steps below to complete installation:
### Install on Linux or macOS
```shell
$ chmod 755 ./hiblupInstaller.sh
$ ./hiblupInstaller.sh
```
After installed successfully, restart the terminal or source the system path file, then type `hiblup` to start (needn't to `library(hiblup)`). For R script file (yourscript.r), it can be run directly by `hiblup yourscript.r` instead of `Rscript yourscript.r`
### Install on Windows
```R
> install.packages(c("RcppArmadillo", "bigmemory"))
> install.packages("hiblup_1.2.0.zip", repos = NULL)
```
After installed successfully, please `library(hiblup)` to start.

## Quick Start

The data embedded in HIBLUP was derived from an animal breeding farm, it includes a total of 2934 genetic related individuals and 573 of them were genotyped with 50K SNP Chip. The genotype was coded as 0, 1, 2 for AA, AB, BB, respectively, and two traits(t1, t2) were recorded for 800 individuals. Sire information and sex information can be treated as random effect and fixed effect, respectively. A quick start of HIBLUP to fit above model is shown below:

```R
data("hidata")
X <- model.matrix(~as.factor(Sex), data=pheno)  # fixed effects
R <- as.matrix(pheno$Sire)                      # random effects
gebv <- hiblup(pheno=pheno[,c(1,4)], geno=geno, map=map, geno.id=geno.id,
               pedigree=pedigree, vc.method=c("HI"), mode="A", CV=X, R=R,
               snp.solution=TRUE)
```

```text
SSBLUP model is selected based on provided data
Analyzed trait: t1
Number of covariate: 3
Number of random: 1
Number of individuals with phenotype: 800
Deriving GA matrix from genotype... Done within 1s
Number of genotyped individuals: 573
Number of genotyped individuals with phenotype: 175
Number of genotyped individuals without phenotype: 398
Deriving A matrix from pedigree...Done within 0s
Number of total predicted individuals: 2934
Realign index of y...Done!
Realign index of X matrix...Done!
Realign index of R matrix...Done!
Extracting A11 matrix...Done!
Mean of diagonal and Off-diagonal of PA: 1.0002 0.0248
Mean of diagonal and Off-diagonal of GA: 0.9886 -0.0017
Adjusting GA matrix: GA* = 0.99 * GA + 0.03
Weighting of A11 and GA matrix: 0.05
Calculating inverse of A11 matrix...Done within 1s
Constructing HA matrix...Done within 1s
HE Prior derived: A:0.1 e:89.08749; Done within 0s
HE adopted: TRUE
Variance components estimation:
[Iter]  Var_R1(SE)    Var_K1(SE)      Var_e(SE)      h2_R1(SE)      h2_K1(SE)
[AI] 13.958(15.0571) 1.798(7.9697) 87.218(7.4915) 0.1356(0.1270) 0.0175(0.0772)
[AI] 0.624(6.4713) 6.624(8.4325) 81.838(7.6181) 0.0070(0.0722) 0.0744(0.0934)
[AI] 2.758(0.8631) 3.910(8.5912) 84.307(7.3534) 0.0303(0.0100) 0.0430(0.0934)
[AI] 4.684(1.5499) 4.511(8.3950) 83.587(7.4085) 0.0505(0.0167) 0.0486(0.0894)
[AI] 5.613(2.2921) 5.434(8.8501) 82.817(7.6245) 0.0598(0.0238) 0.0579(0.0930)
[AI] 5.803(2.6863) 5.881(9.2503) 82.468(7.8018) 0.0616(0.0276) 0.0625(0.0967)
[AI] 5.827(2.7739) 5.994(9.4167) 82.381(7.8736) 0.0619(0.0284) 0.0636(0.0984)
[AI] 5.830(2.7858) 6.013(9.4563) 82.366(7.8904) 0.0619(0.0285) 0.0638(0.0988)
[AI] 5.831(2.7877) 6.016(9.4630) 82.363(7.8933) 0.0619(0.0286) 0.0639(0.0989)
[AI] 5.831(2.7881) 6.017(9.4641) 82.363(7.8938) 0.0619(0.0286) 0.0639(0.0989)
[AI] 5.831(2.7881) 6.017(9.4643) 82.363(7.8939) 0.0619(0.0286) 0.0639(0.0989)
[AI] 5.831(2.7881) 6.017(9.4644) 82.363(7.8939) 0.0619(0.0286) 0.0639(0.0989)
[Convergence] YES
Done within 5s
Estimated beta: 149.7262 4.366075
Estimated Vg and Ve: 6.017368 82.36306
HIBLUP DONE WITHIN TOTAL RUN TIME: 9s
HIBLUP ACCOMPLISHED SUCCESSFULLY!
```

## Authors

[Lilin Yin](https://github.com/YinLiLin)#, [Haohao Zhang](https://github.com/hyacz)#, and [**Xiaolei Liu**](https://github.com/XiaoleiLiuBio).

Questions, suggestions, and bug reports are welcome and appreciated: [xiaoleiliu@mail.hzau.edu.cn](mailto:xiaoleiliu@mail.hzau.edu.cn)

## Availability

The HIBLUP is distributed as R package (https://hiblup.github.io/) and is free of charge for academic purposes. For commercial purposes, please contact the development team.
