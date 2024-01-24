
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
  subgraph legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x3e42f6670cc1974c>"finder"]:::uptodate --> x8a64dc026076b147>"calcTE"]:::uptodate
    x3e42f6670cc1974c>"finder"]:::uptodate --> x2405da16054f81ad>"calcSE"]:::uptodate
    x8a64dc026076b147>"calcTE"]:::uptodate --> x19d56b95df0a7e85>"poolES"]:::uptodate
    x97296012062236b1>"getPval"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x4e142918b401f034>"cleanData"]:::uptodate --> xb4a3d4a2fc7bb7d2>"readData"]:::uptodate
    x6296d492a8ddad2b>"getCI"]:::uptodate --> x67d7e85e85ed33db>"reportCI"]:::uptodate
    x6296d492a8ddad2b>"getCI"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    xb7940ee18a25ecab>"isAnomaly"]:::uptodate --> x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate
    x67d7e85e85ed33db>"reportCI"]:::uptodate --> x275ceffe01854d89>"reportMeta"]:::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xee61ab83b7d675c1>"iterate"]:::uptodate
    x1f5f4b5b2ec59cf0>"iterateReport"]:::uptodate --> xe507bce80d611fab>"mkReport"]:::uptodate
    x2405da16054f81ad>"calcSE"]:::uptodate --> x19d56b95df0a7e85>"poolES"]:::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1f5f4b5b2ec59cf0>"iterateReport"]:::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x5dec9390e6ba0601(["meta_subgroup_trim_nodrop"]):::uptodate
    x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::uptodate --> x5dec9390e6ba0601(["meta_subgroup_trim_nodrop"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x71be6fd42761e6d3(["plt_pair_clean"]):::uptodate
    xb5a1412177d32e97>"vizPair"]:::uptodate --> x71be6fd42761e6d3(["plt_pair_clean"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x1dce5ca2184cbbac(["subgroup_sub"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x1dce5ca2184cbbac(["subgroup_sub"]):::uptodate
    xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate --> x1dce5ca2184cbbac(["subgroup_sub"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> xf54d595d36ddf944(["meta_reg_sub_glmm"]):::uptodate
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate --> xf54d595d36ddf944(["meta_reg_sub_glmm"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x2f8e058a4c200eca(["pooled_glmm"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x2f8e058a4c200eca(["pooled_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x4d2b1e28eb09428e(["meta_subgroup_sub"]):::uptodate
    x1dce5ca2184cbbac(["subgroup_sub"]):::uptodate --> x4d2b1e28eb09428e(["meta_subgroup_sub"]):::uptodate
    x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::uptodate --> x5829432146e81511(["plt_metareg_nodrop"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x5829432146e81511(["plt_metareg_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x6fe128cf3d613e50(["meta_subgroup_nodrop"]):::uptodate
    xa6d646770fa86dd5(["subgroup_nodrop"]):::uptodate --> x6fe128cf3d613e50(["meta_subgroup_nodrop"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x97078af44030bc70(["subgroup_analysis"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x272cc93b628f8f53(["meta_reg_trim"]):::uptodate
    x16f58f5592cc23f2(["pooled_trim"]):::uptodate --> x272cc93b628f8f53(["meta_reg_trim"]):::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::uptodate
    xe797a538520c914d(["tbl"]):::uptodate --> x631988a8d3d85fb3(["pooled_author"]):::uptodate
    x43a0cd95af269145(["meta_reg_glmm"]):::uptodate --> xacc055f19d077ef7(["plt_metareg_glmm"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xacc055f19d077ef7(["plt_metareg_glmm"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::uptodate
    x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate --> xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> xe9e91f34f1a53922(["pooled_groups_nodrop"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xe9e91f34f1a53922(["pooled_groups_nodrop"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> xe9e91f34f1a53922(["pooled_groups_nodrop"]):::uptodate
    xc97dd3bb2801d8e6(["meta_reg_nodrop_glmm"]):::uptodate --> xe056c64a94e73bd1(["plt_metareg_nodrop_glmm"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xe056c64a94e73bd1(["plt_metareg_nodrop_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x372094126e882570(["meta_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x372094126e882570(["meta_glmm"]):::uptodate
    x3b47b6779afe85cb(["meta_reg"]):::uptodate --> x85d32e8dea63783a(["plt_metareg"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x85d32e8dea63783a(["plt_metareg"]):::uptodate
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate --> x072da2b9dadd30d7(["meta_trim_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x072da2b9dadd30d7(["meta_trim_nodrop"]):::uptodate
    x272cc93b628f8f53(["meta_reg_trim"]):::uptodate --> xd00ed331109076e5(["plt_metareg_trim"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xd00ed331109076e5(["plt_metareg_trim"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x0faa046694306504(["subgroup_sub_glmm"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x0faa046694306504(["subgroup_sub_glmm"]):::uptodate
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate --> x0faa046694306504(["subgroup_sub_glmm"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::uptodate
    x5622303d0fb3e0ca(["pooled_groups"]):::uptodate --> x7cddcc2458aa2f2a(["bias_eda"]):::uptodate
    x4cfdc4b8ffc0833b>"deduplicate"]:::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::uptodate
    xe797a538520c914d(["tbl"]):::uptodate --> x07c0a25d8d1269ae(["tbl_clean"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::uptodate
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate --> x6c4c882d7c3ded46(["subgroup_trim_nodrop"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::uptodate
    x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate --> x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::uptodate
    xd0cd0def3066ae2a>"mergeGBD"]:::uptodate --> x42ecac41dddf0580(["tbl_merge"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x42ecac41dddf0580(["tbl_merge"]):::uptodate
    x0d85e8aa1f7733e8(["tbl_gbd"]):::uptodate --> x42ecac41dddf0580(["tbl_merge"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x43a0cd95af269145(["meta_reg_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x43a0cd95af269145(["meta_reg_glmm"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> xc97dd3bb2801d8e6(["meta_reg_nodrop_glmm"]):::uptodate
    x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate --> xc97dd3bb2801d8e6(["meta_reg_nodrop_glmm"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate
    x438aadf53305eaf8(["meta_reg_sub"]):::uptodate --> x1a5341c5a45972f9(["plt_metareg_sub"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x1a5341c5a45972f9(["plt_metareg_sub"]):::uptodate
    x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::uptodate --> x739273a4187d8c44(["plt_metareg_trim_nodrop"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x739273a4187d8c44(["plt_metareg_trim_nodrop"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x61043ad3d4c8e37a(["subgroup_trim"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x61043ad3d4c8e37a(["subgroup_trim"]):::uptodate
    x16f58f5592cc23f2(["pooled_trim"]):::uptodate --> x61043ad3d4c8e37a(["subgroup_trim"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::uptodate
    x20d407903515e4c8(["subgroup_glmm"]):::uptodate --> x8f6d13cb7c3e85ba(["meta_subgroup_glmm"]):::uptodate
    x42ecac41dddf0580(["tbl_merge"]):::uptodate --> x26e7b41b4fdef71e(["tbl_sub"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x9c8a002797d6e8d0(["meta_eda_nodrop"]):::uptodate
    xe9e91f34f1a53922(["pooled_groups_nodrop"]):::uptodate --> x9c8a002797d6e8d0(["meta_eda_nodrop"]):::uptodate
    xf54d595d36ddf944(["meta_reg_sub_glmm"]):::uptodate --> xb28deb8abfe8e234(["plt_metareg_sub_glmm"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> xb28deb8abfe8e234(["plt_metareg_sub_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x17068972d7fcb0cd(["meta_subgroup_sub_glmm"]):::uptodate
    x0faa046694306504(["subgroup_sub_glmm"]):::uptodate --> x17068972d7fcb0cd(["meta_subgroup_sub_glmm"]):::uptodate
    x67be920e14d52a62{{"raw"}}:::uptodate --> x948809345d27ea2b(["file_extract"]):::uptodate
    xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate --> xf21d86b424b8c872(["bias_sub"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xf21d86b424b8c872(["bias_sub"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x16f58f5592cc23f2(["pooled_trim"]):::uptodate
    x64501e899d71430b(["tbl_trim"]):::uptodate --> x16f58f5592cc23f2(["pooled_trim"]):::uptodate
    xae2d712343e89314(["pooled_all_nodrop"]):::uptodate --> x2eba83c0e36aae3d(["bias_all_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x2eba83c0e36aae3d(["bias_all_nodrop"]):::uptodate
    x16f58f5592cc23f2(["pooled_trim"]):::uptodate --> x7d90d8c3f9be815f(["bias_trim"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7d90d8c3f9be815f(["bias_trim"]):::uptodate
    x16f58f5592cc23f2(["pooled_trim"]):::uptodate --> xf4b58dbf4ed40c45(["meta_trim"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xf4b58dbf4ed40c45(["meta_trim"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x0c55547544d10beb(["pooled_all"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x0c55547544d10beb(["pooled_all"]):::uptodate
    x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate --> x2509500711bc82c3(["bias_nodrop_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x2509500711bc82c3(["bias_nodrop_glmm"]):::uptodate
    x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate --> x979bec9dba5c139a(["meta_trim_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x979bec9dba5c139a(["meta_trim_glmm"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> xa6d646770fa86dd5(["subgroup_nodrop"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xa6d646770fa86dd5(["subgroup_nodrop"]):::uptodate
    xae2d712343e89314(["pooled_all_nodrop"]):::uptodate --> xa6d646770fa86dd5(["subgroup_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xa0de17b035f48f7a(["meta_subgroup_trim"]):::uptodate
    x61043ad3d4c8e37a(["subgroup_trim"]):::uptodate --> xa0de17b035f48f7a(["meta_subgroup_trim"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate
    x26e7b41b4fdef71e(["tbl_sub"]):::uptodate --> xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate
    x64501e899d71430b(["tbl_trim"]):::uptodate --> xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x64501e899d71430b(["tbl_trim"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x2e9a38145b3ac661(["meta_author"]):::uptodate
    x631988a8d3d85fb3(["pooled_author"]):::uptodate --> x2e9a38145b3ac661(["meta_author"]):::uptodate
    x948809345d27ea2b(["file_extract"]):::uptodate --> xe797a538520c914d(["tbl"]):::uptodate
    xb4a3d4a2fc7bb7d2>"readData"]:::uptodate --> xe797a538520c914d(["tbl"]):::uptodate
    xae2d712343e89314(["pooled_all_nodrop"]):::uptodate --> x7bf28e1f0f407874(["meta_all_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7bf28e1f0f407874(["meta_all_nodrop"]):::uptodate
    x48de5fd9e99c55ba>"tblSummary"]:::uptodate --> x2c3bd46c74689a75(["desc_clean"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x2c3bd46c74689a75(["desc_clean"]):::uptodate
    x3f7928f8d55f3ece(["meta_reg_trim_glmm"]):::uptodate --> x41990854a7bce4ec(["plt_metareg_trim_glmm"]):::uptodate
    xb8df53a3923736a6>"vizMetareg"]:::uptodate --> x41990854a7bce4ec(["plt_metareg_trim_glmm"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x1da53b9024b2e84a(["bias_all"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x1da53b9024b2e84a(["bias_all"]):::uptodate
    xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate --> x95b985a7fe0e3acc(["meta_sub"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x95b985a7fe0e3acc(["meta_sub"]):::uptodate
    x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate --> x157d9cc65920f0ee(["bias_trim_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x157d9cc65920f0ee(["bias_trim_glmm"]):::uptodate
    x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate --> xe1b50824ae96aefc(["meta_nodrop_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xe1b50824ae96aefc(["meta_nodrop_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xaf0034ed7fb04a01(["meta_subgroup"]):::uptodate
    x97078af44030bc70(["subgroup_analysis"]):::uptodate --> xaf0034ed7fb04a01(["meta_subgroup"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x430992bea01a7746(["meta_all"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x430992bea01a7746(["meta_all"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x9779f797366ec5b8(["meta_eda"]):::uptodate
    x5622303d0fb3e0ca(["pooled_groups"]):::uptodate --> x9779f797366ec5b8(["meta_eda"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::uptodate
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate --> x48b3c4ea88f3ca65(["meta_reg_trim_nodrop"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::uptodate
    xae2d712343e89314(["pooled_all_nodrop"]):::uptodate --> x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate
    x64501e899d71430b(["tbl_trim"]):::uptodate --> x6c2a68b24919816c(["pooled_trim_glmm"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x3b47b6779afe85cb(["meta_reg"]):::uptodate
    x0c55547544d10beb(["pooled_all"]):::uptodate --> x3b47b6779afe85cb(["meta_reg"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x7435453e09723b05(["bias_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x7435453e09723b05(["bias_glmm"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate
    x26e7b41b4fdef71e(["tbl_sub"]):::uptodate --> xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    x2f8e058a4c200eca(["pooled_glmm"]):::uptodate --> x20d407903515e4c8(["subgroup_glmm"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> x8258980e0682878d(["bias_author"]):::uptodate
    x631988a8d3d85fb3(["pooled_author"]):::uptodate --> x8258980e0682878d(["bias_author"]):::uptodate
    x6cab7297675953ab>"fitRegression"]:::uptodate --> x438aadf53305eaf8(["meta_reg_sub"]):::uptodate
    xcfebc4d08e3ac7e1(["pooled_sub"]):::uptodate --> x438aadf53305eaf8(["meta_reg_sub"]):::uptodate
    xdd4b0b70c7769dbd(["file_gbd"]):::uptodate --> x0d85e8aa1f7733e8(["tbl_gbd"]):::uptodate
    x0c6b15df3123c413>"readGBD"]:::uptodate --> x0d85e8aa1f7733e8(["tbl_gbd"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x0d85e8aa1f7733e8(["tbl_gbd"]):::uptodate
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate --> x53a850c45ff9db8e(["meta_sub_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x53a850c45ff9db8e(["meta_sub_glmm"]):::uptodate
    x7cddcc2458aa2f2a(["bias_eda"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    xb6e22c0b3cd30b1f(["bias_eda_nodrop"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x430992bea01a7746(["meta_all"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x7bf28e1f0f407874(["meta_all_nodrop"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x2e9a38145b3ac661(["meta_author"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x9779f797366ec5b8(["meta_eda"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x9c8a002797d6e8d0(["meta_eda_nodrop"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x3b47b6779afe85cb(["meta_reg"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x8fc76a8f0c4f8433(["meta_reg_nodrop"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x543688e28a1fc6f2>"fitSubgroup"]:::uptodate --> xe122b0edd8e42abd(["subgroup_nodrop_glmm"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> xe122b0edd8e42abd(["subgroup_nodrop_glmm"]):::uptodate
    x4e7a69155c31511d(["pooled_nodrop_glmm"]):::uptodate --> xe122b0edd8e42abd(["subgroup_nodrop_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x02cd47ce8e1b4444(["meta_subgroup_trim_glmm"]):::uptodate
    xf987bdcb9b4a89cb(["subgroup_trim_glmm"]):::uptodate --> x02cd47ce8e1b4444(["meta_subgroup_trim_glmm"]):::uptodate
    xbd40d4173cdcd2f2(["pooled_sub_glmm"]):::uptodate --> x092b777fcac5b9ae(["bias_sub_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x092b777fcac5b9ae(["bias_sub_glmm"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> x819d16bc169fb30a(["meta_subgroup_nodrop_glmm"]):::uptodate
    xe122b0edd8e42abd(["subgroup_nodrop_glmm"]):::uptodate --> x819d16bc169fb30a(["meta_subgroup_nodrop_glmm"]):::uptodate
    x19d56b95df0a7e85>"poolES"]:::uptodate --> xae2d712343e89314(["pooled_all_nodrop"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> xae2d712343e89314(["pooled_all_nodrop"]):::uptodate
    xc573754fb982f8cc(["pooled_trim_nodrop"]):::uptodate --> xccb01fc1201c2f58(["bias_trim_nodrop"]):::uptodate
    x275ceffe01854d89>"reportMeta"]:::uptodate --> xccb01fc1201c2f58(["bias_trim_nodrop"]):::uptodate
    xee61ab83b7d675c1>"iterate"]:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    xe37aeeab4f19d257{{"itergroup"}}:::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    x07c0a25d8d1269ae(["tbl_clean"]):::uptodate --> x5622303d0fb3e0ca(["pooled_groups"]):::uptodate
    x67be920e14d52a62{{"raw"}}:::uptodate --> xdd4b0b70c7769dbd(["file_gbd"]):::uptodate
    xe507bce80d611fab>"mkReport"]:::uptodate --> xb6e22c0b3cd30b1f(["bias_eda_nodrop"]):::uptodate
    xe9e91f34f1a53922(["pooled_groups_nodrop"]):::uptodate --> xb6e22c0b3cd30b1f(["bias_eda_nodrop"]):::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 199 stroke-width:0px;
```
