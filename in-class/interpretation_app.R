library(shiny)
library(cvdRiskData)
library(tidyverse)
library(keras)
library(lime)
library(caret)
library(ROCR)
library(corrr)
library(tidyquant)



model_type.keras.engine.sequential.Sequential <<- function(x, ...) {
    return("classification")
}

predict_model.keras.engine.sequential.Sequential <<- function (x, newdata, type, ...) {
    pred <- predict_proba(object = x, x = as.matrix(newdata))
    return(data.frame(Positive = pred, Negative = 1 - pred))
}


ui <- fluidPage(
    titlePanel("Neural Network Interpretation"),
    sidebarLayout(
        sidebarPanel(
            sliderInput(
                "layers",
                "Number of Layers:",
                min = 1,
                max = 5,
                value = 2
            ),
            sliderInput(
                "nodes",
                "Nodes per Layer:",
                min = 1,
                max = 500,
                value = 10
            ),
            sliderInput(
                "epochs",
                "Epochs:",
                min = 1,
                max = 25,
                value = 10
            ),
            sliderInput(
                "batch_size",
                "Batch Size:",
                min = 1,
                max = 25000,
                value = 5000
            ),
            actionButton("train", "Train Neural Network"),
            actionButton("resample", "Sample Test Cases")
        ),
        mainPanel(
            tabsetPanel(
                type = "tabs",
                tabPanel(
                    "Train Model",
                    "Training vs Validation Set Loss and Accuracy",
                    plotOutput("train_progress"),
                    "Test Set Performance",
                    plotOutput("performance")
                ),
                tabPanel(
                    "Model Interpretation",
                    tableOutput("table"),
                    plotOutput("interpret")
                ),
                tabPanel(
                    "Global Variable Importance",
                    plotOutput("forest")
                )
            )
        )
    )
)

server <- function(input, output) {
    data(cvd_patient)
    
    data <- 
        cvd_patient %>%
        mutate(tchol = 400 - tchol) %>%
        select(-patientID, -age, -race)
    
    train_idx <- createDataPartition(data$cvd, p = 0.80, list = FALSE)
    train_data <- data[train_idx, ]
    test_data <- data[-train_idx, ]
    
    train_data <- 
        train_data %>%
        downSample(train_data$cvd) %>%
        select(-Class)
    
    shuffle_idx <- sample(nrow(train_data))
    train_data <- train_data[shuffle_idx,]
    
    scale_data <- function(data, keep) {
        data[keep] %>%
            data.matrix() %>%
            apply(2, function(x) (x - min(x)) / (max(x) - min(x))) %>%
            return()
    }
    
    x_train <- scale_data(train_data, 1:9)
    y_train <- scale_data(train_data, 10)
    
    x_test <- scale_data(test_data, 1:9)
    y_test <- scale_data(test_data, 10)
    
    
    
    
    
    output$forest <-renderPlot({
        corrr_analysis <- 
            x_train %>%
            as.data.frame() %>%
            mutate(cvd = y_train) %>%
            mutate_if(is.factor, as.numeric) %>%
            correlate(quiet = T) %>%
            focus(cvd) %>%
            rename(feature = rowname) %>%
            arrange(abs(cvd)) %>%
            mutate(feature = as_factor(feature))
        
        corrr_analysis %>%
            ggplot(aes(x = cvd, y = fct_reorder(feature, desc(cvd)))) +
            geom_point() +
            geom_segment(
                aes(xend = 0, yend = feature),
                color = palette_light()[[2]],
                data = filter(corrr_analysis, cvd > 0)
            ) +
            geom_point(
                color = palette_light()[[2]],
                data = filter(corrr_analysis, cvd > 0)
            ) +
            ## commented out because there are no negative correlations
            # geom_segment(
            #     aes(xend = 0, yend = feature),
            #     color = palette_light()[[1]],
            #     data =  filter(corrr_analysis, cvd < 0)
            # ) +
            geom_point(
                color = palette_light()[[1]],
                data = filter(corrr_analysis, cvd < 0)
            ) +
            geom_vline(
                xintercept = 0,
                color = palette_light()[[5]],
                size = 1,
                linetype = 2
            ) +
            geom_vline(
                xintercept = -0.25,
                color = palette_light()[[5]],
                size = 1,
                linetype = 2
            ) +
            geom_vline(
                xintercept = 0.25,
                color = palette_light()[[5]],
                size = 1,
                linetype = 2
            ) +
            theme_tq() +
            labs(
                title = 'Global Predictors of CVD',
                subtitle = 'Negative vs. Positive Correlations',
                x = 'CVD Risk',
                y = 'Feature Importance'
            )
    })
    
    observeEvent(input$train, {
        
        Sys.setenv('KMP_DUPLICATE_LIB_OK'='T')
        
        add_layer <- function() {
            model %>%
            layer_dense(input$nodes, activation = 'relu') %>%
            layer_dropout(0.5) 
        }
        model <<-
            keras_model_sequential() %>%
            layer_dense(input$nodes, activation = 'relu', input_shape = ncol(x_train)) %>%
            layer_dropout(0.5)
        
        if (input$layers > 1) {
            for (layer in 2:input$layers) {
                model %>%
                    layer_dense(input$nodes, activation = 'relu') %>%
                    layer_dropout(0.5)
            }
        }
        
        model %>%
            layer_dense(1, activation = 'sigmoid') %>%
            compile(
                loss = "binary_crossentropy",
                optimizer = optimizer_sgd(lr = 1.0, nesterov = T, momentum = 0.9),
                metrics = c('acc')
            )

        output$train_progress <- renderPlot({
            train <-
                fit(
                    model,
                    x = x_train,
                    y = y_train,
                    validation_split = 0.20,
                    batch_size = input$batch_size,
                    epochs = input$epochs
                )
            
            plot(train)
        })
        
        output$performance <- renderPlot({
            nn_predictions <- predict_proba(model, x_test)
            nn_pr <- prediction(nn_predictions, y_test)
            
            nn_auc <- performance(nn_pr, measure = "auc")
            nn_auc <- nn_auc@y.values[[1]]
            
            nn_perf <- performance(nn_pr, measure = "tpr", x.measure = "fpr")
            nn_perf_df <- data.frame(nn_perf@x.values, nn_perf@y.values)
            colnames(nn_perf_df) <- c("x_values", "y_values")
            
            ggplot(nn_perf_df, aes(x = x_values, y = y_values)) +
                geom_line() +
                geom_abline(slope = 1, intercept = 0, color = "red") +
                annotate(
                    geom = "text",
                    x = 0.75,
                    y = 0.32,
                    label = paste('AUC: ', round(nn_auc, 3))
                ) +
                labs(
                    title = "Receiver Operating Characteristics Curve",
                    x = "1 - Specificity",
                    y = "Sensitivity"
                ) +
                theme_light()
        })
    })
    
    
    observeEvent(input$resample, {
        output$interpret <- renderPlot({
            
            explainer <- lime(as.data.frame(x_train), model, quantile_bins = FALSE)
            samples <- sample(1:nrow(x_test), 4)
            
            output$table <- renderTable({
                test_data[samples, ]
            })
            
            explanation <-
                explain(
                    as.data.frame(x_test)[samples, ],
                    explainer = explainer,
                    n_labels = 1,
                    n_features = 3
                )
    
            plot_features(explanation) +
                labs(
                    title = "LIME: Feature Importance Visualization",
                    subtitle = "Hold Out Test Set, 4 Cases Shown"
                )
        })
    })
}

shinyApp(ui = ui, server = server)
