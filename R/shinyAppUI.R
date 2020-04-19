#' Shiny app server object
#'
#' @importFrom graphics hist
#' @import shiny

# create the shiny application user interface
shinyAppUI <- fluidPage(

  titlePanel(title = "MoMp GPred19 Web App"),
  windowTitle = "MoMp GPred19",
  sidebarLayout(
    sidebarPanel(
      fileInput("uploadedfile","Upload the file"),
      helpText("Upload the Excel File template with
               either XLS or XLSX extension file name on this web app.
               Prefered filename should be the
               student's ID number e.g. MATH1200.xlsx"),
      #uiOutput("templatexlsx"),
      br(),
      # helpText("Predicted Total Marks - provides the predicted total marks out of 100
      #          of each students as modelled by the machine learning which includes
      #          the Final Marks with 20% weight only. Notes: (a) only students with
      #          complete marks on each assessment will be fitted to the developed
      #          model. (b) the download button below will provide a CSV file that will
      #          include two additional columns as compared to the diplayed report on the
      #          right side. (i) COURSE WORK1 - this is supposed to be first assessment based on the
      #          template found in sheet 'currentdata'. The purpose of this column on this
      #          report is to compare the student ID and the marks they got in this column.
      #          If it maches, then the predicted total mark is indeed assigned to that student, else,
      #          please report it immidiately. You may or may not exerise to cross check the
      #          prediction report based on this column.
      #          (ii) RMSEP (error) - is the root mean square error
      #          of prediction of the model that is fitted to your course. This is expected to vary from
      #          one course to the other. Interestingly, the error  may even vary for the same course from one college to the other.
      #          Acceptable error estimate will be decided by the concern authority. Upon getting an unacceptable range of error,
      #          Report it at once.
      #          "),
      downloadButton("predicted_total_marks_DL", "Predicted Total Marks")
      # br(),
      # helpText("Semester GPA1 is for a student who had at least
      #          one 'mixing status'  semester given that the lower
      #          level is not yet completed (e.g. in diploma second year,
      #          at least one course is yet to be passed)"),
      #
      # downloadButton("downloadGPA1", "Semester GPA1"),
      #
      # helpText("Semester GPA2 is for a student who had at least
      #          one 'mixing status' semester given that the
      #          lower level is already completed (e.g. in diploma
      #          second year, all courses passed) OR both levels
      #          are already completed (e.g. Diploma 2nd and
      #          Advanced Diploma)"),
      #
      # downloadButton("downloadGPA2", "Semester GPA2"),
      # br(),
      # downloadButton("downloadLGPA", "Cumulative GPA"),
      # br(),
      # downloadButton("downloadOGPA", "Overall Cum GPA"),
      # helpText("NOTE: for a student who had NEVER
      #          mixed a semester, GPA1 and GPA2 will
      #          give the similar results."),
      # tags$hr()
      ),
    mainPanel(
      uiOutput("tb")

      #cat(paste("#", capture.output(sessionInfo()), "\n", collapse =""))

      # R version 3.5.2 (2018-12-20)
      # Platform: x86_64-w64-mingw32/x64 (64-bit)
      # Running under: Windows >= 8 x64 (build 9200)
      #
      # Matrix products: default
      #
      # locale:
      # [1] LC_COLLATE=English_Philippines.1252
      # [2] LC_CTYPE=English_Philippines.1252
      # [3] LC_MONETARY=English_Philippines.1252
      # [4] LC_NUMERIC=C
      # [5] LC_TIME=English_Philippines.1252
      #
      # attached base packages:
      # [1] stats     graphics  grDevices utils     datasets  methods
      # [7] base
      #
      # other attached packages:
      # [1] readxl_1.3.1     shiny_1.4.0      pls_2.7-2        e1071_1.7-3
      # [5] caret_6.0-86     ggplot2_3.2.1    lattice_0.20-38  caTools_1.17.1.2
      #
      # loaded via a namespace (and not attached):
      #  [1] tidyselect_0.2.5     purrr_0.3.2          reshape2_1.4.3
      #  [4] rv_2.3.4             splines_3.5.2        sourcetools_0.1.7
      #  [7] colorspace_1.4-1     generics_0.0.2       htmltools_0.4.0
      # [10] stats4_3.5.2         yaml_2.2.0           survival_3.1-7
      # [13] prodlim_2019.11.13   rlang_0.4.5          later_1.0.0
      # [16] ModelMetrics_1.2.2.2 pillar_1.3.1         glue_1.3.1
      # [19] withr_2.1.2          foreach_1.4.4        plyr_1.8.4
      # [22] lava_1.6.6           stringr_1.4.0        timeDate_3043.102
      # [25] cellranger_1.1.0     munsell_0.5.0        gtable_0.3.0
      # [28] recipes_0.1.10       codetools_0.2-16     fastmap_1.0.1
      # [31] httpuv_1.5.2         class_7.3-15         Rcpp_1.0.2
      # [34] xtable_1.8-3         promises_1.1.0       scales_1.0.0
      # [37] ipred_0.9-9          jsonlite_1.6         mime_0.7
      # [40] digest_0.6.23        stringi_1.4.3        dplyr_0.8.3
      # [43] grid_3.5.2           tools_3.5.2          bitops_1.0-6
      # [46] magrittr_1.5         lazyeval_0.2.2       tibble_2.1.1
      # [49] crayon_1.3.4         pkgconfig_2.0.2      MASS_7.3-51.4
      # [52] Matrix_1.2-17        data.table_1.12.4    pROC_1.15.3
      # [55] lubridate_1.7.4      gower_0.2.1          assertthat_0.2.1
      # [58] rstudioapi_0.10      iterators_1.0.10     R6_2.4.0
      # [61] rpart_4.1-15         nnet_7.3-12          nlme_3.1-147
      # [64] compiler_3.5.2

    )

    )

  )
