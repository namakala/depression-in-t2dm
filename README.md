
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
    renv::settings$snapshot.type("all")

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. Setting the
snapshot to `all` will allow `renv` to track all the required packages,
including its dependencies. After restarting your R session, you should
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
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x0a52b03877696646([""Outdated""]):::outdated --- x7420bd9270f8d27d([""Up to date""]):::uptodate
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- xbf4603d6c2c2ad6b([""Stem""]):::none
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
    xb7940ee18a25ecab>"isAnomaly"]:::uptodate --> x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate
    x97296012062236b1>"getPval"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::outdated
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated --> x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::outdated
    x2f8e058a4c200eca(["pooled_glmm"]):::outdated --> x7435453e09723b05(["bias_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7435453e09723b05(["bias_glmm"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x97078af44030bc70(["subgroup_analysis"]):::outdated
    x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::outdated --> x41990854a7bce4ec(["plt_metareg_trim_glmm"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x41990854a7bce4ec(["plt_metareg_trim_glmm"]):::outdated
    xdd4b0b70c7769dbd(["file_gbd"]):::uptodate --> x0d85e8aa1f7733e8(["tbl_gbd"]):::outdated
    x0c6b15df3123c413>"readGBD"]:::uptodate --> x0d85e8aa1f7733e8(["tbl_gbd"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x0d85e8aa1f7733e8(["tbl_gbd"]):::outdated
    x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::outdated
    xe797a538520c914d(["tbl"]):::outdated --> x07c0a25d8d1269ae(["tbl_clean"]):::outdated
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated --> x072da2b9dadd30d7(["meta_trim_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x072da2b9dadd30d7(["meta_trim_nodrop"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x64501e899d71430b(["tbl_trim"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x1da53b9024b2e84a(["bias_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1da53b9024b2e84a(["bias_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xa0de17b035f48f7a(["meta_subgroup_trim"]):::outdated
    x61043ad3d4c8e37a(["subgroup_trim"]):::outdated --> xa0de17b035f48f7a(["meta_subgroup_trim"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x02cd47ce8e1b4444(["meta_subgroup_trim_glmm"]):::outdated
    xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::outdated --> x02cd47ce8e1b4444(["meta_subgroup_trim_glmm"]):::outdated
    x7cddcc2458aa2f2a(["bias_eda"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x430992bea01a7746(["meta_all"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x2e9a38145b3ac661(["meta_author"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x9779f797366ec5b8(["meta_eda"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x3b47b6779afe85cb(["meta_reg"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x67be920e14d52a62{{"raw"}}:::uptodate --> xdd4b0b70c7769dbd(["file_gbd"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x0faa046694306504(["subgroup_sub_glmm"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x0faa046694306504(["subgroup_sub_glmm"]):::outdated
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated --> x0faa046694306504(["subgroup_sub_glmm"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x8258980e0682878d(["bias_author"]):::outdated
    x631988a8d3d85fb3(["pooled_author"]):::outdated --> x8258980e0682878d(["bias_author"]):::outdated
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated --> xccb01fc1201c2f58(["bias_trim_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xccb01fc1201c2f58(["bias_trim_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x5dec9390e6ba0601(["meta_subgroup_trim_nodrop"]):::outdated
    x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::outdated --> x5dec9390e6ba0601(["meta_subgroup_trim_nodrop"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x9779f797366ec5b8(["meta_eda"]):::outdated
    x5622303d0fb3e0ca(["pooled_groups"]):::outdated --> x9779f797366ec5b8(["meta_eda"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::outdated
    x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated --> x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::outdated
    xd0cd0def3066ae2a>"mergeGBD"]:::uptodate --> x42ecac41dddf0580(["tbl_merge"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x42ecac41dddf0580(["tbl_merge"]):::outdated
    x0d85e8aa1f7733e8(["tbl_gbd"]):::outdated --> x42ecac41dddf0580(["tbl_merge"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x438aadf53305eaf8(["meta_reg_sub"]):::outdated
    xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated --> x438aadf53305eaf8(["meta_reg_sub"]):::outdated
    x438aadf53305eaf8(["meta_reg_sub"]):::outdated --> x1a5341c5a45972f9(["plt_metareg_sub"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x1a5341c5a45972f9(["plt_metareg_sub"]):::outdated
    xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated --> xf21d86b424b8c872(["bias_sub"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xf21d86b424b8c872(["bias_sub"]):::outdated
    xae2d712343e89314(["pooled_all_nodrop"]):::outdated --> x7bf28e1f0f407874(["meta_all_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7bf28e1f0f407874(["meta_all_nodrop"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x16f58f5592cc23f2(["pooled_trim"]):::outdated
    x64501e899d71430b(["tbl_trim"]):::outdated --> x16f58f5592cc23f2(["pooled_trim"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::outdated
    x2f8e058a4c200eca(["pooled_glmm"]):::outdated --> x20d407903515e4c8(["subgroup_glmm"]):::outdated
    x3b47b6779afe85cb(["meta_reg"]):::outdated --> x85d32e8dea63783a(["plt_metareg"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x85d32e8dea63783a(["plt_metareg"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::outdated
    xae2d712343e89314(["pooled_all_nodrop"]):::outdated --> x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated
    x64501e899d71430b(["tbl_trim"]):::outdated --> xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated --> x53a850c45ff9db8e(["meta_sub_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x53a850c45ff9db8e(["meta_sub_glmm"]):::outdated
    x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated --> x157d9cc65920f0ee(["bias_trim_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x157d9cc65920f0ee(["bias_trim_glmm"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> xf54d595d36ddf944(["meta_reg_sub_glmm"]):::outdated
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated --> xf54d595d36ddf944(["meta_reg_sub_glmm"]):::outdated
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::outdated
    xe797a538520c914d(["tbl"]):::outdated --> x631988a8d3d85fb3(["pooled_author"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x43a0cd95af269145(["meta_reg_glmm"]):::outdated
    x2f8e058a4c200eca(["pooled_glmm"]):::outdated --> x43a0cd95af269145(["meta_reg_glmm"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated
    x64501e899d71430b(["tbl_trim"]):::outdated --> x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated
    xae2d712343e89314(["pooled_all_nodrop"]):::outdated --> x2eba83c0e36aae3d(["bias_all_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x2eba83c0e36aae3d(["bias_all_nodrop"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x430992bea01a7746(["meta_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x430992bea01a7746(["meta_all"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x61043ad3d4c8e37a(["subgroup_trim"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x61043ad3d4c8e37a(["subgroup_trim"]):::outdated
    x16f58f5592cc23f2(["pooled_trim"]):::outdated --> x61043ad3d4c8e37a(["subgroup_trim"]):::outdated
    x272cc93b628f8f53(["meta_reg_trim"]):::outdated --> xd00ed331109076e5(["plt_metareg_trim"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xd00ed331109076e5(["plt_metareg_trim"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::outdated
    x20d407903515e4c8(["subgroup_glmm"]):::outdated --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::outdated
    x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::outdated --> x739273a4187d8c44(["plt_metareg_trim_nodrop"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x739273a4187d8c44(["plt_metareg_trim_nodrop"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x2e9a38145b3ac661(["meta_author"]):::outdated
    x631988a8d3d85fb3(["pooled_author"]):::outdated --> x2e9a38145b3ac661(["meta_author"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> xa6d646770fa86dd5(["subgroup_nodrop"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xa6d646770fa86dd5(["subgroup_nodrop"]):::outdated
    xae2d712343e89314(["pooled_all_nodrop"]):::outdated --> xa6d646770fa86dd5(["subgroup_nodrop"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xaf0034ed7fb04a01(["meta_subgroup"]):::outdated
    x97078af44030bc70(["subgroup_analysis"]):::outdated --> xaf0034ed7fb04a01(["meta_subgroup"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x6fe128cf3d613e50(["meta_subgroup_nodrop"]):::outdated
    xa6d646770fa86dd5(["subgroup_nodrop"]):::outdated --> x6fe128cf3d613e50(["meta_subgroup_nodrop"]):::outdated
    x16f58f5592cc23f2(["pooled_trim"]):::outdated --> xf4b58dbf4ed40c45(["meta_trim"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xf4b58dbf4ed40c45(["meta_trim"]):::outdated
    x948809345d27ea2b(["file_extract"]):::outdated --> xe797a538520c914d(["tbl"]):::outdated
    xb4a3d4a2fc7bb7d2>"readData"]:::uptodate --> xe797a538520c914d(["tbl"]):::outdated
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x5622303d0fb3e0ca(["pooled_groups"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::outdated
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::outdated --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::outdated
    x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::outdated
    x42ecac41dddf0580(["tbl_merge"]):::outdated --> x26e7b41b4fdef71e(["tbl_sub"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x17068972d7fcb0cd(["meta_subgroup_sub_glmm"]):::outdated
    x0faa046694306504(["subgroup_sub_glmm"]):::outdated --> x17068972d7fcb0cd(["meta_subgroup_sub_glmm"]):::outdated
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x1dce5ca2184cbbac(["subgroup_sub"]):::outdated
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x1dce5ca2184cbbac(["subgroup_sub"]):::outdated
    xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated --> x1dce5ca2184cbbac(["subgroup_sub"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x2f8e058a4c200eca(["pooled_glmm"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x2f8e058a4c200eca(["pooled_glmm"]):::outdated
    x43a0cd95af269145(["meta_reg_glmm"]):::outdated --> xacc055f19d077ef7(["plt_metareg_glmm"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xacc055f19d077ef7(["plt_metareg_glmm"]):::outdated
    x16f58f5592cc23f2(["pooled_trim"]):::outdated --> x7d90d8c3f9be815f(["bias_trim"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7d90d8c3f9be815f(["bias_trim"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated
    x26e7b41b4fdef71e(["tbl_sub"]):::outdated --> xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated --> x092b777fcac5b9ae(["bias_sub_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x092b777fcac5b9ae(["bias_sub_glmm"]):::outdated
    xf54d595d36ddf944(["meta_reg_sub_glmm"]):::outdated --> xb28deb8abfe8e234(["plt_metareg_sub_glmm"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xb28deb8abfe8e234(["plt_metareg_sub_glmm"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated
    x26e7b41b4fdef71e(["tbl_sub"]):::outdated --> xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::outdated
    xe507bce80d611fab>"mkReport"]:::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::outdated
    x5622303d0fb3e0ca(["pooled_groups"]):::outdated --> x7cddcc2458aa2f2a(["bias_eda"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x272cc93b628f8f53(["meta_reg_trim"]):::outdated
    x16f58f5592cc23f2(["pooled_trim"]):::outdated --> x272cc93b628f8f53(["meta_reg_trim"]):::outdated
    x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::outdated --> x5829432146e81511(["plt_metareg_nodrop"]):::outdated
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x5829432146e81511(["plt_metareg_nodrop"]):::outdated
    x67be920e14d52a62{{"raw"}}:::uptodate --> x948809345d27ea2b(["file_extract"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xae2d712343e89314(["pooled_all_nodrop"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> xae2d712343e89314(["pooled_all_nodrop"]):::outdated
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x3b47b6779afe85cb(["meta_reg"]):::outdated
    x0c55547544d10beb(["pooled_all"]):::outdated --> x3b47b6779afe85cb(["meta_reg"]):::outdated
    x6c2a68b24919816c(["pooled_trim_glmm"]):::outdated --> x979bec9dba5c139a(["meta_trim_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x979bec9dba5c139a(["meta_trim_glmm"]):::outdated
    x2f8e058a4c200eca(["pooled_glmm"]):::outdated --> x372094126e882570(["meta_glmm"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x372094126e882570(["meta_glmm"]):::outdated
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x0c55547544d10beb(["pooled_all"]):::outdated
    x07c0a25d8d1269ae(["tbl_clean"]):::outdated --> x0c55547544d10beb(["pooled_all"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x4d2b1e28eb09428e(["meta_subgroup_sub"]):::outdated
    x1dce5ca2184cbbac(["subgroup_sub"]):::outdated --> x4d2b1e28eb09428e(["meta_subgroup_sub"]):::outdated
    xcfebc4d08e3ac7e1(["pooled_sub"]):::outdated --> x95b985a7fe0e3acc(["meta_sub"]):::outdated
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x95b985a7fe0e3acc(["meta_sub"]):::outdated
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 170 stroke-width:0px;
```
