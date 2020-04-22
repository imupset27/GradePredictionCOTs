#' Shiny app server function
#'
#' @param input provided by shiny
#' @param output provided by shiny
#'


# Define server logic required to draw a histogram
shinyAppServer <- function(input, output) {


  #Data Pre-Processing for the old data####
  dataset <- reactive({
    file1 <- input$uploadedfile
    if(is.null(file1)){return()}
    read_excel(path = file1$datapath,
               sheet = "olddata",
               col_names = T,
               na = "",
               trim_ws = T,
               skip = 0,
               progress = readxl_progress(),
               .name_repair = "unique"
    )
  })

  dataset2 <- reactive({
    dataset <- dataset()
    dataset[,-c(1:2,11:12)]
  })

  coursecode <- reactive({
    dataset <- dataset()
    dataset[1,1]
  })

  dataset3 <- reactive({
    dataset2 <- dataset2()
    as.data.frame(lapply(dataset2, function(x) as.numeric(as.character(x))))

  })


  dataset4 <- reactive({
    dataset3 <- dataset3()
    na.omit(
      dataset3[,
               colSums(
                 is.na(dataset3)
               ) != nrow(dataset3)
               ]
    )
  })

  training_set <- reactive({
    dataset4 <- dataset4()
    set.seed(6271)
    split=sample.split(dataset4$Total,SplitRatio = 0.8)
    subset(dataset4, split==TRUE)
  })

  test_set <- reactive({
    dataset4 <- dataset4()
    set.seed(6271)
    split=sample.split(dataset4$Total,SplitRatio = 0.8)
    subset(dataset4, split==FALSE)
  })

  regressor <- reactive({
    training_set <- training_set()
    pcr(Total ~.,
        data = training_set,
        scale = TRUE,
        validation ="CV",
        ncomp = (ncol(training_set)-2)
    )
  })



  error <- reactive({
    regressor <- regressor()
    training_set <- training_set()
    as.data.frame(
      RMSEP(
        regressor,
        estimate = "CV")[1])[,(ncol(training_set)-1)]
  })

  predicted_test_set <- reactive({
    regressor <- regressor()
    test_set <- test_set()
    dataset <- dataset()
    predicted = predict(regressor,
                        newdata = test_set,
                        ncomp = ncol(test_set)-2)
    cbind.data.frame('Course Code' = dataset[1:nrow(test_set),1],
                     'Actual' = test_set[,ncol(test_set)],
                     'Predicted' = drop(predicted))
  })

  RMSEPr <- reactive({

    y = data.frame('RMSEP'=sqrt(mean((predicted_test_set()$Actual - predicted_test_set()$Predicted)^2)))
  })

  #Data Pre-Processing for the current data####
  newdata <- reactive({
    file1 <- input$uploadedfile
    if(is.null(file1)){return()}
    read_excel(path = file1$datapath,
               sheet = "currentdata",
               col_names = T,
               na = "",
               trim_ws = T,
               skip = 0,
               progress = readxl_progress(),
               .name_repair = "unique"
    )
  })

  newdata2 <- reactive({
    newdata <- newdata()
    newdata[,-c(1:4)]
  })

  newdata3 <- reactive({
    newdata <- newdata()
    newdata2 <- newdata2()
    y <- as.data.frame(lapply(newdata2, function(x) as.numeric(as.character(x))))
    cbind.data.frame(newdata[,1:4],y)
  })


  newdata4 <- reactive({
    newdata3 <- newdata3()
    na.omit(
      newdata3[,
               colSums(
                 is.na(newdata3)
               ) != nrow(newdata3)
               ]
    )
  })

  currentdata <- reactive({
    newdata4 <- newdata4()
    newdata4[,-(1:4)]
  })


  predicted_total_marks <- reactive({
    regressor <- regressor()
    currentdata <- currentdata()
    test_set <- test_set()
    newdata4 <- newdata4()
    predicted = predict(regressor,
                        newdata = currentdata,
                        ncomp = ncol(test_set)-2)
    cbind.data.frame('Course Code' = newdata4[,1],
                     'Student ID'=newdata4[,2],
                     'Course Lecturer' = newdata4[,3],
                     'Section No.'= newdata4[,4],
                     #'Course Work1'= newdata4[,5],
                     'Predicted Total Marks' = drop(predicted)
                     #'RMSEC (error)' = error()
    )
  })

  predicted_total_marks2 <- reactive({
    regressor <- regressor()
    currentdata <- currentdata()
    test_set <- test_set()
    newdata4 <- newdata4()
    predicted = predict(regressor,
                        newdata = currentdata,
                        ncomp = ncol(test_set)-2)
    cbind.data.frame('Course Code' = newdata4[,1],
                     'Student ID'=newdata4[,2],
                     'Course Lecturer' = newdata4[,3],
                     'Section No.'= newdata4[,4],
                     'Course Work1'= newdata4[,5],
                     'Predicted Total Marks' = drop(predicted),
                     'RMSEC (error)' = error()
    )
  })

  output$counter <-
    renderText({
      if (!file.exists("counter.Rdata"))
        counter <- 0
      else
        load(file="counter.Rdata")
      counter  <- counter + 1
      save(counter, file="counter.Rdata")
      paste("Counter: ", counter, " visits")
    })

  # trgdata <-
  #   reactive({
  #     if (!file.exists("trgset.rds"))
  #       saveRDS(dataset(), "trgset.rds")
  #     else
  #       x = readRDS("trgset.rds")
  #       y = rbind(x, dataset())
  #     saveRDS(y, file="trgset.rds")
  #     })

  # observeEvent(input$uploadedfile, {
  #
  #   if (!file.exists("trgset.rds"))
  #     saveRDS(dataset(), "trgset.rds")
  #   else
  #     x = as.data.frame(readRDS("trgset.rds"))
  #     y = rbind(x, dataset())
  #   saveRDS(y, file="trgset.rds")
  #
  # })

  # saveData <<- function(data) {
  #   data <- data
  #   # Create a unique file name
  #   fileName <- sprintf("%s_%s.csv", coursecode(), digest::digest(data))
  #   # Write the file to the local system
  #   write.csv(
  #     x = data,
  #     file = file.path(paste0(getwd(),"/datasets"), fileName),
  #     row.names = FALSE
  #   )
  # }
  saveDatatrg <<- function(data) {
    data <- data
    # Create a unique file name
    fileName <- sprintf("%s_%s_%s.rds", coursecode(),"trng", digest::digest(data))
    # Write the file to the local system
    saveRDS(
      data,
      file = file.path(paste0(getwd(),"/trng"), fileName)
    )
  }

  observeEvent(input$uploadedfile, {
    saveDatatrg(dataset()[,-2])
  })

  saveDatapred <<- function(data) {
    data <- data
    # Create a unique file name
    fileName <- sprintf("%s_%s_%s.rds", coursecode(),"pred", digest::digest(data))
    # Write the file to the local system
    saveRDS(
      data,
      file = file.path(paste0(getwd(),"/pred"), fileName)
    )
  }

  observeEvent(input$uploadedfile, {
    saveDatapred(predicted_total_marks2())
  })


  output$predicted_total_marks_DL <- downloadHandler(

    filename = function() {
      paste("Predicted Total Marks - ",dataset()[1,1], ".csv", sep = "")
    },
    content = function(file) {
      write.csv(predicted_total_marks2(),file, row.names = FALSE)
    }
  )

  output$summary <- renderPrint({
    summary(regressor())
  })

  # dataset106 <- reactive({
  #   dataset <- dataset()
  # })
  #

  output$templatexlsx <- renderUI({
    #req(credentials()$user_auth)
    tags$a("Download Grade Prediction Template",
           href="Grade Prediction Template.xlsx",
           download="Grade Prediction Template.xlsx"
    )
  })

  output$guidelines <- renderUI({
    #req(credentials()$user_auth)
    tags$a("Download Guidelines",
           href="Guidlines for GPred19.pdf",
           download="Guidlines for GPred19.pdf"
    )
  })

  output$predicted_y <- renderTable({
    if(is.null(dataset())){return()}
    predicted_total_marks()
  })

  output$predicted_test_set <- renderTable({
    if(is.null(dataset())){return()}
    predicted_test_set()
  })

  output$RMSEPrediction <- renderTable({
    if(is.null(dataset())){return()}
    RMSEPr()
  })
  # output$plots <- renderPlot({
  #   par(mfrow=c(2,2))
  #   plot(
  #     RMSEP(
  #       regressor(),
  #       estimate =c("train", "CV", "test"),
  #       newdata = test_set()
  #     ),
  #     lwd = 1.2,
  #     legendpos = "topright",
  #     main = "Error of Training, Cross-Validation and Test Sets",
  #     ylab = "Root Mean Squared Error"
  #   )
  #   plot(
  #     R2(
  #       regressor(),
  #       estimate =c("train", "CV", "test"),
  #       newdata = test_set()
  #     ),
  #     lwd=1.2,
  #     legendpos = "bottomright",
  #     main = "R-square of Training, Cross-Validation and Test Sets",
  #     ylab = "R-square"
  #   )
  #   selectNcomp(regressor(),
  #               method = "randomization",
  #               plot = TRUE,
  #               main = "Optimum Number of Components",
  #               lwd = 1.2)
  #   plot(test_set()$Total,predicted_test_set()$Predicted,
  #        #xlim = c(0,100),
  #        #ylim = c(0,100),
  #        main = "Test Set Total Marks",
  #        ylab = "Predicted Mark",
  #        xlab = "Actual Mark",
  #        lwd = 1.2)
  # })

  # output$plots <- renderPlot({
  #   par(mfrow=c(2,2))
  #   plot(
  #     RMSEP(
  #       regressor(),
  #       estimate =c("train", "CV", "test"),
  #       newdata = test_set()
  #     ),
  #     lwd = 1.2,
  #     legendpos = "topright",
  #     main = "Error of Training, Cross-Validation and Test Sets",
  #     ylab = "Root Mean Squared Error"
  #   )
  #   plot(
  #     R2(
  #       regressor(),
  #       estimate =c("train", "CV", "test"),
  #       newdata = test_set()
  #     ),
  #     lwd=1.2,
  #     legendpos = "bottomright",
  #     main = "R-square of Training, Cross-Validation and Test Sets",
  #     ylab = "R-square"
  #   )
  #   selectNcomp(regressor(),
  #               method = "randomization",
  #               plot = TRUE,
  #               main = "Optimum Number of Components",
  #               lwd = 1.2)
  #   plot(test_set()$Total,predicted_test_set()$Predicted,
  #        #xlim = c(0,100),
  #        #ylim = c(0,100),
  #        main = "Test Set Total Marks",
  #        ylab = "Predicted Mark",
  #        xlab = "Actual Mark",
  #        lwd = 1.2)
  #
  #
  #   })

  output$error_plot <- renderPlot({
    plot(
      RMSEP(
        regressor(),
        estimate =c("train", "CV", "test"),
        newdata = test_set()
      ),
      lwd = 1.2,
      legendpos = "topright",
      main = "Error of Training, Cross-Validation and Test Sets",
      ylab = "Root Mean Squared Error"
    )
  })

  output$rsquare_plot <- renderPlot({
    plot(
      R2(
        regressor(),
        estimate =c("train", "CV", "test"),
        newdata = test_set()
      ),
      lwd=1.2,
      legendpos = "bottomright",
      main = "R-square of Training, Cross-Validation and Test Sets",
      ylab = "R-square"
    )
  })

  output$ncomp_plot <- renderPlot({
    selectNcomp(regressor(),
                method = "randomization",
                plot = TRUE,
                main = "Optimum Number of Components",
                lwd = 1.2)
  })

  output$scatter_plot <- renderPlot({
    plot(test_set()$Total,predicted_test_set()$Predicted,
         #xlim = c(0,100),
         #ylim = c(0,100),
         main = "Test Set Total Marks",
         ylab = "Predicted Mark",
         xlab = "Actual Mark",
         lwd = 1.2)
  })

  output$tb <- renderUI({
    if(is.null(dataset()))
      h5("")
    else
      tabsetPanel(type = "pills",
                  tabPanel(
                    "Predicted Total Marks",
                    tableOutput("predicted_y")
                  ),
                  tabPanel(
                    "Model Summary",
                    verbatimTextOutput("summary")),
                  tabPanel(
                    "Model Performance",
                    plotOutput("scatter_plot"),
                    plotOutput("error_plot"),
                    plotOutput("rsquare_plot"),
                    plotOutput("ncomp_plot"),
                    tableOutput("RMSEPrediction"),
                    tableOutput("predicted_test_set")
                  )

                  # tabPanel(
                  #   "Model Performance Graphs",
                  #   "Under Construction"
                  #   #tableOutput("SemGPA1")
                  # ),
                  # tabPanel(
                  #   "About",
                  #   h3("Predicted Total Marks - provides the predicted total marks out of 100
                  #   for each student as modelled by the machine learning which includes
                  #   the Final Marks with 20% weight only. Notes: (a) only students with
                  #   complete marks on each assessment will be fitted to the developed
                  #   model. (b) the download button below will provide a CSV file that will
                  #   include two additional columns as compared to the diplayed report on the
                  #   'Predicted Total Marks' tab. (i) COURSE WORK1 - this is supposed to be first assessment based on the
                  #   template found in sheet 'currentdata'. The purpose of this column on this
                  #   report is to compare the student ID and the marks they got in this column.
                  #   If it maches, then the predicted total mark is indeed assigned to that student, else,
                  #   please report it immidiately. You may or may not exerise to cross check the
                  #   prediction report based on this column.
                  #   (ii) RMSEP (error) - is the root mean square error
                  #   of prediction of the model that is fitted to your course. This is expected to vary from
                  #   one course to the other. Interestingly, the error  may even vary for the same course from one college to the other.
                  #   Acceptable error estimate will be decided by the concern authority. Upon getting an unacceptable range of error,
                  #   Report it at once.
                  #   "))
      )
  })

}
