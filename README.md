
# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/), and more conveniently [RStudio
IDE](https://posit.co/downloads/) installed and running well in your
system. You simply need to fork/clone this repository using RStudio by
following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
In your RStudio command line, you can copy paste the following code to
setup your working directory:

    install.packages("renv") # Only need to run this step if `renv` is not installed

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

    renv::restore()
    renv::install()
    renv::snapshot()

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you can proceed with:

    install.packages("targets")

This step will install `targets`, which I use to track my analysis
pipeline. The `targets` package will automate each analysis step,
starting from cleaning the data up to rendering a report. Run the
following command to complete the analysis:

    targets::tar_make()

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `render`
directory.

# What’s this all about?

This is the analysis pipeline for conducting analysis in an umbrella
review. The complete flow can be viewed in the following `mermaid`
diagram:

``` mermaid
graph LR
  subgraph legend
    direction LR
    x0a52b03877696646([""Outdated""]):::outdated --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- x7420bd9270f8d27d([""Up to date""]):::uptodate
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xbf4603d6c2c2ad6b([""Stem""]):::none
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
    x2405da16054f81ad>"calcSE"]:::uptodate --> x19d56b95df0a7e85>"poolES"]:::uptodate
    x97296012062236b1>"getPval"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::outdated
    xe797a538520c914d(["tbl"]):::outdated --> x631988a8d3d85fb3(["pooled_author"]):::outdated
    x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::outdated
    xe797a538520c914d(["tbl"]):::outdated --> x07c0a25d8d1269ae(["tbl_clean"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x1da53b9024b2e84a(["bias_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1da53b9024b2e84a(["bias_all"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x430992bea01a7746(["meta_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x430992bea01a7746(["meta_all"]):::outdated
    x1da53b9024b2e84a(["bias_all"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x8258980e0682878d(["bias_author"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x7cddcc2458aa2f2a(["bias_eda"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x430992bea01a7746(["meta_all"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x2e9a38145b3ac661(["meta_author"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x9779f797366ec5b8(["meta_eda"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    xe797a538520c914d(["tbl"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x8258980e0682878d(["bias_author"]):::outdated
    x631988a8d3d85fb3(["pooled_author"]):::outdated --> x8258980e0682878d(["bias_author"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x9779f797366ec5b8(["meta_eda"]):::outdated
    x5622303d0fb3e0ca(["pooled_groups"]):::outdated --> x9779f797366ec5b8(["meta_eda"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x2e9a38145b3ac661(["meta_author"]):::outdated
    x631988a8d3d85fb3(["pooled_author"]):::outdated --> x2e9a38145b3ac661(["meta_author"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::outdated
    x5622303d0fb3e0ca(["pooled_groups"]):::outdated --> x7cddcc2458aa2f2a(["bias_eda"]):::outdated
    x67be920e14d52a62{{"raw"}}:::uptodate --> x948809345d27ea2b(["file_extract"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x0c55547544d10beb(["pooled_all"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x0c55547544d10beb(["pooled_all"]):::outdated
    x948809345d27ea2b(["file_extract"]):::outdated --> xe797a538520c914d(["tbl"]):::outdated
    xb4a3d4a2fc7bb7d2>"readData"]:::uptodate --> xe797a538520c914d(["tbl"]):::outdated
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x4fdcca5ddb678139>"test"]:::uptodate --> x4fdcca5ddb678139>"test"]:::uptodate
    x41a8499cfe76565d>"vizMeta"]:::uptodate --> x41a8499cfe76565d>"vizMeta"]:::uptodate
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 47 stroke-width:0px;
  linkStyle 48 stroke-width:0px;
  linkStyle 49 stroke-width:0px;
```
