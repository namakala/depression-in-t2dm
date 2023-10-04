
# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/),
[`quarto`](https://quarto.org/docs/download/), and more conveniently
[RStudio IDE](https://posit.co/downloads/) installed and running well in
your system. You simply need to fork/clone this repository using RStudio
by following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
Using terminal in linux/MacOS, you can issue the following command:

    quarto tools install tinytex

This command will install `tinytex` in your path, which is required to
compile quarto documents as latex/pdf. Afterwards, in your RStudio
command line, you can copy paste the following code to setup your
working directory:

    install.packages("renv") # Only need to run this step if `renv` is not installed

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

    renv::restore()
    renv::install()
    renv::snapshot()

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. Then, you should
be able to proceed with:

    targets::tar_make()

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `draft`
directory.

# What’s this all about?

This is the analysis pipeline for conducting analysis in an umbrella
review. The complete flow can be viewed in the following `mermaid`
diagram:

During startup - Warning messages: 1: Setting LC_COLLATE failed, using
“C” 2: Setting LC_TIME failed, using “C” 3: Setting LC_MESSAGES failed,
using “C” 4: Setting LC_MONETARY failed, using “C”

``` mermaid
graph LR
  subgraph legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x4e142918b401f034>"cleanData"]:::uptodate --> xb4a3d4a2fc7bb7d2>"readData"]:::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1f5f4b5b2ec59cf0>"iterateReport"]:::uptodate
    x1f5f4b5b2ec59cf0>"iterateReport"]:::uptodate --> xe507bce80d611fab>"mkReport"]:::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xee61ab83b7d675c1>"iterate"]:::uptodate
    x6296d492a8ddad2b>"getCI"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x6296d492a8ddad2b>"getCI"]:::uptodate --> x67d7e85e85ed33db>"reportCI"]:::uptodate
    x67d7e85e85ed33db>"reportCI"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x3e42f6670cc1974c>"finder"]:::uptodate --> x2405da16054f81ad>"calcSE"]:::uptodate
    x3e42f6670cc1974c>"finder"]:::uptodate --> x8a64dc026076b147>"calcTE"]:::uptodate
    x2405da16054f81ad>"calcSE"]:::uptodate --> x19d56b95df0a7e85>"poolES"]:::uptodate
    x8a64dc026076b147>"calcTE"]:::uptodate --> x19d56b95df0a7e85>"poolES"]:::uptodate
    x97296012062236b1>"getPval"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x7435453e09723b05(["bias_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7435453e09723b05(["bias_glmm"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x43a0cd95af269145(["meta_reg_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x43a0cd95af269145(["meta_reg_glmm"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x0c55547544d10beb(["pooled_all"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x0c55547544d10beb(["pooled_all"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::uptodate
    x5622303d0fb3e0ca(["pooled_groups"]):::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xaf0034ed7fb04a01(["meta_subgroup"]):::uptodate
    x97078af44030bc70(["subgroup_analysis"]):::uptodate --> xaf0034ed7fb04a01(["meta_subgroup"]):::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::uptodate
    xe797a538520c914d(["tbl"]):::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::uptodate
    x948809345d27ea2b(["file_extract"]):::uptodate --> xe797a538520c914d(["tbl"]):::uptodate
    xb4a3d4a2fc7bb7d2>"readData"]:::uptodate --> xe797a538520c914d(["tbl"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x3b47b6779afe85cb(["meta_reg"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x3b47b6779afe85cb(["meta_reg"]):::uptodate
    x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::uptodate
    xe797a538520c914d(["tbl"]):::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    x7cddcc2458aa2f2a(["bias_eda"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x430992bea01a7746(["meta_all"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x2e9a38145b3ac661(["meta_author"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x9779f797366ec5b8(["meta_eda"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x3b47b6779afe85cb(["meta_reg"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x3b47b6779afe85cb(["meta_reg"]):::uptodate --> x85d32e8dea63783a(["plt_metareg"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x85d32e8dea63783a(["plt_metareg"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x8258980e0682878d(["bias_author"]):::uptodate
    x631988a8d3d85fb3(["pooled_author"]):::uptodate --> x8258980e0682878d(["bias_author"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x2f8e058a4c200eca(["pooled_glmm"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x2f8e058a4c200eca(["pooled_glmm"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x9779f797366ec5b8(["meta_eda"]):::uptodate
    x5622303d0fb3e0ca(["pooled_groups"]):::uptodate --> x9779f797366ec5b8(["meta_eda"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x1da53b9024b2e84a(["bias_all"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1da53b9024b2e84a(["bias_all"]):::uptodate
    x43a0cd95af269145(["meta_reg_glmm"]):::uptodate --> xacc055f19d077ef7(["plt_metareg_glmm"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xacc055f19d077ef7(["plt_metareg_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::uptodate
    x20d407903515e4c8(["subgroup_glmm"]):::uptodate --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x372094126e882570(["meta_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x372094126e882570(["meta_glmm"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x430992bea01a7746(["meta_all"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x430992bea01a7746(["meta_all"]):::uptodate
    x67be920e14d52a62{{"raw"}}:::uptodate --> x948809345d27ea2b(["file_extract"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x2e9a38145b3ac661(["meta_author"]):::uptodate
    x631988a8d3d85fb3(["pooled_author"]):::uptodate --> x2e9a38145b3ac661(["meta_author"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x2e036cbf71f1ed8e>"rmAnomaly"]:::uptodate --> x2e036cbf71f1ed8e>"rmAnomaly"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 70 stroke-width:0px;
  linkStyle 71 stroke-width:0px;
```
